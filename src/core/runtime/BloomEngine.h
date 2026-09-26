#pragma once

#include <QObject>
#include <QQmlApplicationEngine>
#include <QLocalServer>
#include <memory>

class IPlatformBackend;
class WorkspaceModel;
class MediaModel;
class AudioModel;
class SystemModel;
class QGuiApplication;

/// Master runtime engine for Bloom Core.
/// Encapsulates QML runtime, IPC, CLI handling, shell lifecycle,
/// and delegates OS-specific operations to IPlatformBackend.
class BloomEngine : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString platform READ platform CONSTANT)
    Q_PROPERTY(bool armed READ isArmed NOTIFY armedChanged)
    Q_PROPERTY(bool locked READ isLocked NOTIFY lockedChanged)
    Q_PROPERTY(bool previewMode READ previewMode CONSTANT)
    Q_PROPERTY(qreal dimOpacity READ dimOpacity NOTIFY dimOpacityChanged)
public:
    explicit BloomEngine(IPlatformBackend *backend, QObject *parent = nullptr);
    ~BloomEngine() override;

    [[nodiscard]] QString version() const;
    [[nodiscard]] QString platform() const;
    [[nodiscard]] bool isArmed() const;
    [[nodiscard]] bool isLocked() const;
    [[nodiscard]] bool previewMode() const noexcept { return m_previewMode; }
    [[nodiscard]] qreal dimOpacity() const;

signals:
    void armedChanged();
    void lockedChanged();
    void dimOpacityChanged();
    void launcherRequested();

public:

    /// Runs application initialization, CLI parsing, IPC setup, and starts QML shell.
    int exec(QGuiApplication &app);

    /// Reloads current shell QML dynamically
    Q_INVOKABLE void reload();

    /// Shell controls (delegates to backend)
    Q_INVOKABLE void toggleLock();
    Q_INVOKABLE void showLauncher();
    Q_INVOKABLE void armPermanent(bool permanent);
    Q_INVOKABLE void disarm();
    Q_INVOKABLE void dismiss();

    // Core model accessors
    [[nodiscard]] WorkspaceModel *workspace() const noexcept { return m_workspaceModel.get(); }
    [[nodiscard]] MediaModel *media() const noexcept { return m_mediaModel.get(); }
    [[nodiscard]] AudioModel *audio() const noexcept { return m_audioModel.get(); }
    [[nodiscard]] SystemModel *system() const noexcept { return m_systemModel.get(); }

private:
    void setupIpc(bool singleInstanceDisabled);
    void setupQmlEngine();
    bool loadShell(const QString &requestedPath);

    IPlatformBackend *m_backend;
    QQmlApplicationEngine m_qmlEngine;
    QLocalServer m_localServer;
    QString m_currentShellPath;

    std::unique_ptr<WorkspaceModel> m_workspaceModel;
    std::unique_ptr<MediaModel> m_mediaModel;
    std::unique_ptr<AudioModel> m_audioModel;
    std::unique_ptr<SystemModel> m_systemModel;
    bool m_previewMode {false};
};
