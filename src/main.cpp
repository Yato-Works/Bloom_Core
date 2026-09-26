#include "bootstrap_log.h"
#include "crash_handler.h"
#include "core/runtime/BloomEngine.h"

#ifdef Q_OS_WIN
#include <windows.h>
#include "platforms/windows/WindowsPlatformBackend.h"
#endif

#include <QGuiApplication>
#include <QQuickStyle>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QDateTime>
#include <cstdio>

static QString g_logPath;

static void setupLogging() {
    QString logDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    if (logDir.isEmpty()) {
        logDir = QDir::homePath() + "/AppData/Local/Bloom/BloomCore/logs";
    }
    QDir().mkpath(logDir);
    g_logPath = logDir + "/bloom_core.log";

    qInstallMessageHandler([](QtMsgType type, const QMessageLogContext &context, const QString &msg) {
        if (g_logPath.isEmpty()) return;
        QFile f(g_logPath);
        if (f.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
            QByteArray logMsg = QString("[%1] %2 (%3:%4)\n").arg(
                type == QtDebugMsg ? "DEBUG" : type == QtWarningMsg ? "WARN" : "CRIT",
                msg, QString::fromUtf8(context.file ? context.file : "unknown"), QString::number(context.line)
            ).toUtf8();
            f.write(logMsg);
            f.close();
        }
    });
}

int main(int argc, char *argv[])
{
#ifdef Q_OS_WIN
    // If not attached to a console, try attaching to parent console for CLI output
    if (GetConsoleWindow() == nullptr) {
        if (AttachConsole(ATTACH_PARENT_PROCESS)) {
            FILE *fp = nullptr;
            freopen_s(&fp, "CONOUT$", "w", stdout);
            freopen_s(&fp, "CONOUT$", "w", stderr);
        }
    }
#endif

    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("BloomCore"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));
    app.setOrganizationName(QStringLiteral("Bloom"));
    app.setQuitOnLastWindowClosed(false);
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    setupLogging();
    installCrashHandler();
    BootstrapLog::write("Bloom Core process started.");

#ifdef Q_OS_WIN
    WindowsPlatformBackend backend;
#else
    #error "Platform backend not supported on this OS build."
#endif

    BloomEngine engine(&backend);
    return engine.exec(app);
}
