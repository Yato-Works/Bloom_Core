#pragma once

#include "../include/IWorkspaceBackend.h"
#include "../../services/WorkspaceController.h"
#include "../../services/WorkspaceService.h"
#include "../../services/ShortcutWorkspaceSwitcher.h"
#include "../../services/ExperimentalWorkspaceSwitcher.h"
#include "../../services/GlobalHotkeyService.h"

class Win32WorkspaceBackend final : public IWorkspaceBackend {
    Q_OBJECT
public:
    explicit Win32WorkspaceBackend(QObject *parent = nullptr);
    ~Win32WorkspaceBackend() override = default;

    void initialize(GlobalHotkeyService *hotkeySvc);

    [[nodiscard]] int currentWorkspace() const override;
    [[nodiscard]] int workspaceCount() const override;
    [[nodiscard]] bool isSwitching() const override;

    void switchTo(int workspaceIndex) override;
    void switchNext() override;
    void switchPrevious() override;

    [[nodiscard]] WorkspaceController *controller() noexcept { return &m_controller; }
    [[nodiscard]] WorkspaceService *workspaceService() noexcept { return &m_workspaceService; }

private:
    WorkspaceService m_workspaceService;
    ShortcutWorkspaceSwitcher m_shortcutSwitcher;
    ExperimentalWorkspaceSwitcher m_experimentalSwitcher;
    WorkspaceController m_controller;
};
