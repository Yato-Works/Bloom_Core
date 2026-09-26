#include "BloomEngine.h"
#include "../models/WorkspaceModel.h"
#include "../models/MediaModel.h"
#include "../models/AudioModel.h"
#include "../models/SystemModel.h"
#include "../../platforms/include/IPlatformBackend.h"

#ifdef Q_OS_WIN
#include "../../platforms/windows/WindowsPlatformBackend.h"
#endif

#include "../../services/ThemeBridge.h"
#include "../../services/CaelestiaColours.h"
#include "../../services/CaelestiaTokens.h"

#include <QGuiApplication>
#include <QQmlContext>
#include <QQuickWindow>
#include <QQuickStyle>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QLocalSocket>
#include <QFileInfo>
#include <QDir>
#include <QDebug>

BloomEngine::BloomEngine(IPlatformBackend *backend, QObject *parent)
    : QObject(parent)
    , m_backend(backend)
{
    if (m_backend) {
        m_workspaceModel = std::make_unique<WorkspaceModel>(m_backend->workspaceBackend(), this);
        m_mediaModel = std::make_unique<MediaModel>(m_backend->mediaBackend(), this);
        m_audioModel = std::make_unique<AudioModel>(m_backend->audioBackend(), this);
        m_systemModel = std::make_unique<SystemModel>(m_backend->systemInfoBackend(), this);

        connect(m_backend, &IPlatformBackend::shellArmedChanged, this, &BloomEngine::armedChanged);
        connect(m_backend, &IPlatformBackend::shellLockedChanged, this, &BloomEngine::lockedChanged);
        connect(m_backend, &IPlatformBackend::dimOpacityChanged, this, &BloomEngine::dimOpacityChanged);
    }
}

BloomEngine::~BloomEngine()
{
    if (m_backend) {
        m_backend->shutdown();
    }
}

QString BloomEngine::version() const
{
    return QStringLiteral("0.1.0");
}

QString BloomEngine::platform() const
{
    return m_backend ? m_backend->platformName() : QStringLiteral("unknown");
}

bool BloomEngine::isArmed() const
{
    return m_backend ? m_backend->isArmed() : false;
}

bool BloomEngine::isLocked() const
{
    return m_backend ? m_backend->isLocked() : false;
}

qreal BloomEngine::dimOpacity() const
{
    return m_backend ? m_backend->dimOpacity() : 0.0;
}

void BloomEngine::reload()
{
    if (m_currentShellPath.isEmpty()) return;
    qInfo() << "BloomEngine: reloading shell:" << m_currentShellPath;
    m_qmlEngine.clearComponentCache();
    loadShell(m_currentShellPath);
}

void BloomEngine::toggleLock()
{
    if (m_backend) {
        m_backend->toggleShellLock();
    }
}

void BloomEngine::showLauncher()
{
    if (m_backend) {
        m_backend->showLauncher();
    }
    emit launcherRequested();
}

void BloomEngine::armPermanent(bool permanent)
{
    if (m_backend) {
        m_backend->armShell(permanent);
    }
}

void BloomEngine::disarm()
{
    if (m_backend) {
        m_backend->disarmShell();
    }
}

void BloomEngine::dismiss()
{
    if (m_backend) {
        m_backend->dismissShell();
    }
}

int BloomEngine::exec(QGuiApplication &app)
{
    // -------------------------------------------------------------
    // CLI Options
    // -------------------------------------------------------------
    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("Bloom Core — Desktop Shell Runtime & Linux QML Bridge"));
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption shellOpt(QStringList() << "s" << "shell",
                                QStringLiteral("Path to custom shell QML file to execute."),
                                QStringLiteral("file"));
    parser.addOption(shellOpt);

    QCommandLineOption noSingleInstOpt(QStringLiteral("no-single-instance"),
                                       QStringLiteral("Allow multiple instances of Bloom Core."));
    parser.addOption(noSingleInstOpt);

    QCommandLineOption showOpt(QStringLiteral("show"),
                               QStringLiteral("Signal running instance to arm and show."));
    parser.addOption(showOpt);

    QCommandLineOption toggleOpt(QStringLiteral("toggle"),
                                 QStringLiteral("Signal running instance to toggle lock state."));
    parser.addOption(toggleOpt);

    QCommandLineOption reloadOpt(QStringLiteral("reload"),
                                 QStringLiteral("Signal running instance to reload current shell."));
    parser.addOption(reloadOpt);

    QCommandLineOption previewOpt(QStringLiteral("preview"),
                                  QStringLiteral("Run in aesthetic preview mode for screenshots / asset generation."));
    parser.addOption(previewOpt);

    parser.addPositionalArgument(QStringLiteral("shell_path"),
                                 QStringLiteral("Path to shell QML file (optional)."),
                                 QStringLiteral("[shell_path]"));

    parser.process(app);

    m_previewMode = parser.isSet(previewOpt) || qEnvironmentVariableIntValue("BLOOM_PREVIEW") != 0;

    const bool singleInstanceDisabled = parser.isSet(noSingleInstOpt)
                                     || qEnvironmentVariableIntValue("BLOOM_NO_SINGLE_INSTANCE") != 0;
    const QString serverName = QStringLiteral("BloomCore_SingleInstance_Server");

    // Single instance client check
    if (!singleInstanceDisabled) {
        QLocalSocket socket;
        socket.connectToServer(serverName);
        if (socket.waitForConnected(400)) {
            if (parser.isSet(toggleOpt)) {
                socket.write("TOGGLE\n");
            } else if (parser.isSet(reloadOpt)) {
                socket.write("RELOAD\n");
            } else {
                socket.write("SHOW\n");
            }
            socket.waitForBytesWritten(400);
            socket.disconnectFromServer();
            qInfo() << "BloomEngine: existing instance notified. Exiting secondary process.";
            return 0;
        }
    }

    // Initialize platform backend
    if (m_backend && !m_backend->initialize()) {
        qCritical() << "BloomEngine: FATAL - platform backend initialization failed.";
        return 1;
    }

    // Setup IPC server
    setupIpc(singleInstanceDisabled);

    // Setup QML engine and register models & bridges
    setupQmlEngine();

    // Determine Shell QML to load
    QString shellPath;
    if (parser.isSet(shellOpt)) {
        shellPath = parser.value(shellOpt);
    } else if (!parser.positionalArguments().isEmpty()) {
        shellPath = parser.positionalArguments().first();
    }

    if (shellPath.isEmpty()) {
        const QString userConfig = QDir::homePath() + "/.config/bloom/shell.qml";
        if (QFileInfo::exists(userConfig)) {
            shellPath = userConfig;
        }
    }

    if (!loadShell(shellPath)) {
        qCritical() << "BloomEngine: FATAL - failed to load shell.";
        return 1;
    }

    if (m_previewMode || parser.isSet(showOpt) || parser.isSet(toggleOpt)
        || qEnvironmentVariableIntValue("BLOOM_LOCKED") != 0
        || qEnvironmentVariableIntValue("BLOOM_ARMED") != 0) {
        toggleLock();
    }

    qInfo() << "BloomEngine: entering main event loop for platform:" << platform();
    return app.exec();
}

void BloomEngine::setupIpc(bool singleInstanceDisabled)
{
    if (singleInstanceDisabled) return;

    const QString serverName = QStringLiteral("BloomCore_SingleInstance_Server");
    QLocalServer::removeServer(serverName);
    if (m_localServer.listen(serverName)) {
        connect(&m_localServer, &QLocalServer::newConnection, this, [this]() {
            QLocalSocket *client = m_localServer.nextPendingConnection();
            if (client) {
                connect(client, &QLocalSocket::readyRead, this, [this, client]() {
                    const QByteArray data = client->readAll();
                    if (data.contains("TOGGLE")) {
                        toggleLock();
                    } else if (data.contains("SHOW")) {
                        showLauncher();
                    } else if (data.contains("RELOAD")) {
                        reload();
                    } else if (data.contains("QUIT")) {
                        QCoreApplication::quit();
                    }
                });
            }
        });
    }
}

void BloomEngine::setupQmlEngine()
{
    const QString appDirPath = QCoreApplication::applicationDirPath();
    m_qmlEngine.addImportPath(appDirPath + "/qml");
    m_qmlEngine.addImportPath(appDirPath);
    m_qmlEngine.addImportPath(QStringLiteral(":/qt/qml"));
    m_qmlEngine.addImportPath(QStringLiteral(":/Bloom"));

    // Register pure Core Singletons under `Bloom` namespace
    qmlRegisterSingletonInstance("Bloom", 1, 0, "Core", this);
    if (m_workspaceModel) {
        qmlRegisterSingletonInstance("Bloom", 1, 0, "Workspace", m_workspaceModel.get());
    }
    if (m_mediaModel) {
        qmlRegisterSingletonInstance("Bloom", 1, 0, "Media", m_mediaModel.get());
    }
    if (m_audioModel) {
        qmlRegisterSingletonInstance("Bloom", 1, 0, "Audio", m_audioModel.get());
    }
    if (m_systemModel) {
        qmlRegisterSingletonInstance("Bloom", 1, 0, "System", m_systemModel.get());
    }

    auto *ctx = m_qmlEngine.rootContext();

    // Canonical context properties
    ctx->setContextProperty(QStringLiteral("bloomEngine"), this);
    ctx->setContextProperty(QStringLiteral("bloomWorkspace"), m_workspaceModel.get());
    ctx->setContextProperty(QStringLiteral("bloomMedia"), m_mediaModel.get());
    ctx->setContextProperty(QStringLiteral("bloomAudio"), m_audioModel.get());
    ctx->setContextProperty(QStringLiteral("bloomSystem"), m_systemModel.get());
    ctx->setContextProperty(QStringLiteral("applicationDirPath"), appDirPath);

    // Setup ThemeBridge & Dynamic Wallpaper Palette
    static ThemeBridge themeBridge;
    ctx->setContextProperty(QStringLiteral("Theme"), &themeBridge);

    if (auto *colours = CaelestiaColours::instance()) {
        qmlRegisterSingletonInstance("Bloom", 1, 0, "Colours", colours);
        qmlRegisterSingletonInstance("Caelestia", 1, 0, "Colours", colours);
        ctx->setContextProperty(QStringLiteral("Colours"), colours);

        if (m_backend && m_backend->themeBackend()) {
            auto *themeBackend = m_backend->themeBackend();
            auto refreshPalette = [colours, themeBackend]() {
                colours->applyWallpaperPalette(themeBackend->currentWallpaperPath());
            };
            connect(themeBackend, &IThemeBackend::wallpaperChanged, colours, refreshPalette);
            refreshPalette();
        }
    }

    static CaelestiaTokens caelestiaTokens;
    qmlRegisterSingletonInstance("Bloom", 1, 0, "Tokens", &caelestiaTokens);
    qmlRegisterSingletonInstance("Caelestia", 1, 0, "Tokens", &caelestiaTokens);
    ctx->setContextProperty(QStringLiteral("Tokens"), &caelestiaTokens);

#ifdef Q_OS_WIN
    // Platform-specific backward compatibility context properties for existing Windows reference shell
    if (auto *win = dynamic_cast<WindowsPlatformBackend*>(m_backend)) {
        ctx->setContextProperty(QStringLiteral("weatherService"), win->weatherService());
        ctx->setContextProperty(QStringLiteral("overlayController"), win->overlayController());
        ctx->setContextProperty(QStringLiteral("shellController"), win->shellController());
        ctx->setContextProperty(QStringLiteral("systemInfo"), win->winSystemInfo()->service());
        ctx->setContextProperty(QStringLiteral("musicControl"), win->winMedia()->service());
        ctx->setContextProperty(QStringLiteral("config"), win->configService());
        ctx->setContextProperty(QStringLiteral("wallpaperService"), win->winTheme()->wallpaperService());
        ctx->setContextProperty(QStringLiteral("workspaceService"), win->winWorkspace()->workspaceService());
        ctx->setContextProperty(QStringLiteral("workspaceController"), win->winWorkspace()->controller());
        ctx->setContextProperty(QStringLiteral("hotkeyService"), win->hotkeyService());
        ctx->setContextProperty(QStringLiteral("experimentalSwitcher"), win->experimentalSwitcher());
        ctx->setContextProperty(QStringLiteral("aiService"), win->aiService());
        ctx->setContextProperty(QStringLiteral("notionService"), win->notionService());
        ctx->setContextProperty(QStringLiteral("appLauncherService"), win->appLauncherService());
        ctx->setContextProperty(QStringLiteral("cavaService"), win->winAudio()->service());

        ConfigService *config = win->configService();
        themeBridge.setThemeByName(config->themeName());
        connect(&themeBridge, &ThemeBridge::themeChanged, config, [config]() {
            config->setThemeName(themeBridge.themeName());
        });
    }
#endif
}

bool BloomEngine::loadShell(const QString &requestedPath)
{
    m_currentShellPath = requestedPath;

    if (!m_currentShellPath.isEmpty() && QFileInfo::exists(m_currentShellPath)) {
        qInfo() << "BloomEngine: loading custom shell from" << m_currentShellPath;
        m_qmlEngine.load(QUrl::fromLocalFile(QFileInfo(m_currentShellPath).absoluteFilePath()));
    } else {
        qInfo() << "BloomEngine: loading default reference shell module";
        m_qmlEngine.loadFromModule("Bloom", "DefaultShell");
    }

    const QList<QObject*> roots = m_qmlEngine.rootObjects();
    if (roots.isEmpty()) {
        qCritical() << "BloomEngine: no root objects created from QML.";
        return false;
    }

    for (QObject *root : roots) {
        if (auto *window = qobject_cast<QQuickWindow*>(root)) {
            if (m_backend) {
                m_backend->onWindowCreated(window);
            }
        }
    }

    return true;
}
