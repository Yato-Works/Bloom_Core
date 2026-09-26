#include "Win32WorkspaceBackend.h"

Win32WorkspaceBackend::Win32WorkspaceBackend(QObject *parent)
    : IWorkspaceBackend(parent)
{
    connect(&m_controller, &WorkspaceController::currentWorkspaceChanged, this, [this]() {
        emit currentWorkspaceChanged(m_controller.currentWorkspace());
    });
    connect(&m_controller, &WorkspaceController::isSwitchingChanged, this, [this]() {
        emit isSwitchingChanged(m_controller.isSwitching());
    });
}

void Win32WorkspaceBackend::initialize(GlobalHotkeyService *hotkeySvc)
{
    m_shortcutSwitcher.setHotkeyService(hotkeySvc);
    m_shortcutSwitcher.initialize();
    m_experimentalSwitcher.initialize();

    m_controller.setHotkeyService(hotkeySvc);
    m_controller.setWorkspaceService(&m_workspaceService);
    m_controller.setShortcutSwitcher(&m_shortcutSwitcher);
    m_controller.setExperimentalSwitcher(&m_experimentalSwitcher);
    if (m_experimentalSwitcher.isAvailable()) {
        m_controller.setSwitchingMode(QStringLiteral("experimental"));
    } else {
        m_controller.setSwitchingMode(QStringLiteral("standard"));
    }

    if (hotkeySvc) {
        connect(hotkeySvc, &GlobalHotkeyService::switchPrevRequested, &m_controller, &WorkspaceController::switchPrevious);
        connect(hotkeySvc, &GlobalHotkeyService::switchNextRequested, &m_controller, &WorkspaceController::switchNext);
        connect(hotkeySvc, &GlobalHotkeyService::jumpRequested, &m_controller, [this](int idx) {
            if (idx >= 1 && idx <= 9) {
                m_controller.switchTo(idx);
            }
        });
    }

    m_workspaceService.startTracking();
}

int Win32WorkspaceBackend::currentWorkspace() const
{
    return m_controller.currentWorkspace();
}

int Win32WorkspaceBackend::workspaceCount() const
{
    if (m_experimentalSwitcher.isAvailable()) {
        int cnt = m_experimentalSwitcher.workspaceCount();
        if (cnt > 0) return cnt;
    }
    return 5;
}

bool Win32WorkspaceBackend::isSwitching() const
{
    return m_controller.isSwitching();
}

void Win32WorkspaceBackend::switchTo(int workspaceIndex)
{
    m_controller.switchTo(workspaceIndex);
}

void Win32WorkspaceBackend::switchNext()
{
    m_controller.switchNext();
}

void Win32WorkspaceBackend::switchPrevious()
{
    m_controller.switchPrevious();
}
