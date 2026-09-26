#include "WindowsPlatformBackend.h"
#include <QQuickWindow>
#include <QDebug>

WindowsPlatformBackend::WindowsPlatformBackend(QObject *parent)
    : IPlatformBackend(parent)
{
    connect(&m_shellController, &ShellController::armedChanged, this, [this]() {
        emit shellArmedChanged(m_shellController.isArmed());
        emit dimOpacityChanged(m_shellController.dimOpacity());
    });
    connect(&m_shellController, &ShellController::lockedChanged, this, [this]() {
        emit shellLockedChanged(m_shellController.isLocked());
    });
}

WindowsPlatformBackend::~WindowsPlatformBackend()
{
    shutdown();
}

bool WindowsPlatformBackend::initialize()
{
    qInfo() << "WindowsPlatformBackend: initializing Win32 subsystems...";
    m_weatherService.initialize();
    m_hotkeyService.start();
    m_workspace.initialize(&m_hotkeyService);
    m_media.start();
    m_audio.startCapture();
    m_theme.initialize();
    m_shellController.start();
    return true;
}

void WindowsPlatformBackend::shutdown()
{
    m_shellController.stop();
    m_audio.stopCapture();
    m_hotkeyService.stop();
    m_weatherService.shutdown();
}

void WindowsPlatformBackend::onWindowCreated(QQuickWindow *window)
{
    if (!window) return;
    qInfo() << "WindowsPlatformBackend: attaching Win32 controllers to QQuickWindow:" << window;
    m_shellController.setWindow(window);
    m_overlayController.setWindow(window);
    m_shellController.setLocked(false);
}

void WindowsPlatformBackend::toggleShellLock()
{
    m_shellController.toggleLock();
}

void WindowsPlatformBackend::showLauncher()
{
    m_overlayController.showLauncher();
    m_shellController.armPermanent(true);
}

void WindowsPlatformBackend::armShell(bool permanent)
{
    m_shellController.armPermanent(permanent);
}

void WindowsPlatformBackend::disarmShell()
{
    m_shellController.disarm();
}

void WindowsPlatformBackend::dismissShell()
{
    m_shellController.dismiss();
}

bool WindowsPlatformBackend::isArmed() const
{
    return m_shellController.isArmed();
}

bool WindowsPlatformBackend::isLocked() const
{
    return m_shellController.isLocked();
}

qreal WindowsPlatformBackend::dimOpacity() const
{
    return m_shellController.dimOpacity();
}
