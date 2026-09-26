#pragma once

#include "../include/IPlatformBackend.h"
#include "Win32WorkspaceBackend.h"
#include "Win32MediaBackend.h"
#include "Win32AudioBackend.h"
#include "Win32ThemeBackend.h"
#include "Win32SystemInfoBackend.h"
#include "../../services/GlobalHotkeyService.h"
#include "../../services/WeatherService.h"
#include "../../services/AppLauncherService.h"
#include "../../services/ConfigService.h"
#include "../../services/ShellController.h"
#include "../../services/OverlayController.h"
#include "../../services/ExperimentalWorkspaceSwitcher.h"
#include "../../services/AIService.h"
#include "../../services/NotionService.h"

class WindowsPlatformBackend final : public IPlatformBackend {
    Q_OBJECT
public:
    explicit WindowsPlatformBackend(QObject *parent = nullptr);
    ~WindowsPlatformBackend() override;

    [[nodiscard]] QString platformName() const override { return QStringLiteral("windows"); }

    bool initialize() override;
    void shutdown() override;

    [[nodiscard]] IWorkspaceBackend *workspaceBackend() override { return &m_workspace; }
    [[nodiscard]] IMediaBackend *mediaBackend() override { return &m_media; }
    [[nodiscard]] IAudioBackend *audioBackend() override { return &m_audio; }
    [[nodiscard]] IThemeBackend *themeBackend() override { return &m_theme; }
    [[nodiscard]] ISystemInfoBackend *systemInfoBackend() override { return &m_systemInfo; }

    // Platform hooks
    void onWindowCreated(QQuickWindow *window) override;
    void toggleShellLock() override;
    void showLauncher() override;
    void armShell(bool permanent) override;
    void disarmShell() override;
    void dismissShell() override;

    [[nodiscard]] bool isArmed() const override;
    [[nodiscard]] bool isLocked() const override;
    [[nodiscard]] qreal dimOpacity() const override;

    // Direct access to legacy/extended services for backward compatibility
    [[nodiscard]] Win32WorkspaceBackend *winWorkspace() noexcept { return &m_workspace; }
    [[nodiscard]] Win32MediaBackend *winMedia() noexcept { return &m_media; }
    [[nodiscard]] Win32AudioBackend *winAudio() noexcept { return &m_audio; }
    [[nodiscard]] Win32ThemeBackend *winTheme() noexcept { return &m_theme; }
    [[nodiscard]] Win32SystemInfoBackend *winSystemInfo() noexcept { return &m_systemInfo; }
    [[nodiscard]] GlobalHotkeyService *hotkeyService() noexcept { return &m_hotkeyService; }
    [[nodiscard]] WeatherService *weatherService() noexcept { return &m_weatherService; }
    [[nodiscard]] AppLauncherService *appLauncherService() noexcept { return &m_appLauncherService; }
    [[nodiscard]] ConfigService *configService() noexcept { return &m_configService; }
    [[nodiscard]] ShellController *shellController() noexcept { return &m_shellController; }
    [[nodiscard]] OverlayController *overlayController() noexcept { return &m_overlayController; }
    [[nodiscard]] ExperimentalWorkspaceSwitcher *experimentalSwitcher() noexcept { return &m_experimentalSwitcher; }
    [[nodiscard]] AIService *aiService() noexcept { return &m_aiService; }
    [[nodiscard]] NotionService *notionService() noexcept { return &m_notionService; }

private:
    Win32WorkspaceBackend m_workspace;
    Win32MediaBackend m_media;
    Win32AudioBackend m_audio;
    Win32ThemeBackend m_theme;
    Win32SystemInfoBackend m_systemInfo;
    GlobalHotkeyService m_hotkeyService;
    WeatherService m_weatherService;
    AppLauncherService m_appLauncherService;
    ConfigService m_configService;
    ShellController m_shellController;
    OverlayController m_overlayController;
    ExperimentalWorkspaceSwitcher m_experimentalSwitcher;
    AIService m_aiService;
    NotionService m_notionService;
};
