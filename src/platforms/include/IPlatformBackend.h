#pragma once

#include <QObject>
#include <QString>

class QQuickWindow;

#include "IWorkspaceBackend.h"
#include "IMediaBackend.h"
#include "IAudioBackend.h"
#include "IThemeBackend.h"
#include "ISystemInfoBackend.h"

/// Master platform backend interface.
/// Encapsulates all OS-specific integrations (Windows, Wayland, macOS).
class IPlatformBackend : public QObject {
    Q_OBJECT
public:
    explicit IPlatformBackend(QObject *parent = nullptr) : QObject(parent) {}
    ~IPlatformBackend() override;

    [[nodiscard]] virtual QString platformName() const = 0;

    virtual bool initialize() = 0;
    virtual void shutdown() = 0;

    [[nodiscard]] virtual IWorkspaceBackend *workspaceBackend() = 0;
    [[nodiscard]] virtual IMediaBackend *mediaBackend() = 0;
    [[nodiscard]] virtual IAudioBackend *audioBackend() = 0;
    [[nodiscard]] virtual IThemeBackend *themeBackend() = 0;
    [[nodiscard]] virtual ISystemInfoBackend *systemInfoBackend() = 0;

    // Window hooks and high-level shell actions
    virtual void onWindowCreated(QQuickWindow * /*window*/) {}
    virtual void toggleShellLock() {}
    virtual void showLauncher() {}
    virtual void armShell(bool /*permanent*/) {}
    virtual void disarmShell() {}
    virtual void dismissShell() {}

    [[nodiscard]] virtual bool isArmed() const { return false; }
    [[nodiscard]] virtual bool isLocked() const { return false; }
    [[nodiscard]] virtual qreal dimOpacity() const { return 0.0; }

signals:
    void shellArmedChanged(bool armed);
    void shellLockedChanged(bool locked);
    void dimOpacityChanged(qreal opacity);
};
