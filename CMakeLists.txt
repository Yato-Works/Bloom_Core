cmake_minimum_required(VERSION 3.21)
project(BloomCore VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

if (MSVC)
    add_compile_options(/Zc:__cplusplus /utf-8)
endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 QuickLayouts QuickDialogs2 Network)

qt_standard_project_setup(REQUIRES 6.5)
qt_policy(SET QTP0004 NEW)

qt_add_executable(BloomCore
    src/main.cpp
    src/crash_handler.cpp
    src/core/runtime/BloomEngine.cpp
    src/core/models/WorkspaceModel.cpp
    src/core/models/MediaModel.cpp
    src/core/models/AudioModel.cpp
    src/core/models/SystemModel.cpp
    src/platforms/PlatformInterfaces.cpp
    src/platforms/include/IPlatformBackend.h
    src/platforms/include/IWorkspaceBackend.h
    src/platforms/include/IMediaBackend.h
    src/platforms/include/IAudioBackend.h
    src/platforms/include/IThemeBackend.h
    src/platforms/include/ISystemInfoBackend.h
    src/platforms/windows/WindowsPlatformBackend.cpp
    src/platforms/windows/Win32WorkspaceBackend.cpp
    src/platforms/windows/Win32MediaBackend.cpp
    src/platforms/windows/Win32AudioBackend.cpp
    src/platforms/windows/Win32ThemeBackend.cpp
    src/platforms/windows/Win32SystemInfoBackend.cpp
    src/services/ConfigService.cpp
    src/services/MusicControlService.cpp
    src/services/OverlayController.cpp
    src/services/ShellController.cpp
    src/services/ServiceManager.cpp
    src/services/SystemInfoService.cpp
    src/services/WeatherService.cpp
    src/services/ThemeBridge.cpp
    src/services/WallpaperService.cpp
    src/services/WorkspaceService.cpp
    src/services/WorkspaceController.cpp
    src/services/ShortcutWorkspaceSwitcher.cpp
    src/services/ExperimentalWorkspaceSwitcher.cpp
    src/services/AIService.cpp
    src/services/NotionService.cpp
    src/services/AppLauncherService.cpp
    src/services/CaelestiaColours.cpp
    src/services/CaelestiaTokens.cpp
    src/services/CaelestiaConfig.cpp
    src/services/PaletteEngine.cpp
    src/services/CavaService.cpp
    src/services/GlobalHotkeyService.cpp
)

qt_add_qml_module(BloomCore
    URI Bloom
    VERSION 1.0
    RESOURCES
        assets/dino.png
        assets/bongocat.gif
    QML_FILES
        qml/Window.qml
        qml/Panel.qml
        qml/EdgePanel.qml
        qml/DimOverlay.qml
        qml/Main.qml
        qml/demo/DefaultShell.qml
        qml/services/Shell.qml
        qml/services/Workspaces.qml
        qml/services/SysInfo.qml
        qml/services/Players.qml
        qml/services/Audio.qml
        qml/services/Weather.qml
        qml/services/AppLauncher.qml
        qml/components/GlassPanel.qml
        qml/components/SidebarItem.qml
        qml/components/WallpaperSelector.qml
        qml/components/MetricRing.qml
        qml/components/ForecastItem.qml
        qml/components/MaterialIcon.qml
        qml/components/SmartLauncherModal.qml
        qml/components/BloomCalculatorModal.qml
        qml/components/BloomDashboardModal.qml
        qml/components/BloomLockScreen.qml
        qml/components/ClockTab.qml
        qml/components/WeatherTab.qml
        qml/components/MediaTab.qml
        qml/components/SystemHealthTab.qml
        qml/components/ThemePopover.qml
        qml/components/SettingsModal.qml
        qml/components/DashboardCard.qml
        qml/components/ControlStack.qml
        qml/components/QuickSettingIcon.qml
        qml/components/ForecastDayItem.qml
        qml/components/WeatherCard.qml
        qml/components/SystemInfoCard.qml
        qml/components/CalendarSpectrumCard.qml
        qml/components/SystemResourcesTab.qml
        qml/components/ResourceCard.qml
        qml/components/IOGraphCard.qml
        qml/components/MediaPlayerTab.qml
        qml/components/ControlBtn.qml
        qml/components/LauncherTab.qml
        qml/components/AppGridItem.qml
        qml/components/CalendarDetailTab.qml
        qml/components/NotificationItem.qml
        qml/components/PowerVolumeControls.qml
        qml/components/PowerActionBtn.qml
        qml/components/BluetoothPanel.qml
        qml/components/BluetoothDevice.qml
        qml/components/PowerProfileSelector.qml
        qml/components/ProfileBtn.qml
        qml/components/ToggleCard.qml
        qml/components/ScreenRecorderCard.qml
        qml/components/RecorderBtn.qml
        qml/components/QuickToggleBtn.qml
        qml/components/SwitchButton.qml
        qml/caelestia/CaelestiaShell.qml
        qml/caelestia/CaelestiaLeftDock.qml
        qml/caelestia/CaelestiaRightDrawer.qml
        qml/caelestia/VerticalSlider.qml
        qml/caelestia/CircularProgress.qml
        qml/caelestia/DashTab.qml
        qml/caelestia/CaelestiaMediaTab.qml
        qml/caelestia/PerfTab.qml
        qml/caelestia/WeatherDetailTab.qml
        qml/caelestia/BloomShellStyle.qml
        qml/caelestia/BloomSparkline.qml
        qml/caelestia/BloomMonthGrid.qml
        qml/caelestia/BloomTopBar.qml
        qml/caelestia/BloomAppLauncher.qml
        qml/caelestia/BloomControlPanel.qml
)

target_include_directories(BloomCore PRIVATE src src/core src/services src/platforms)
target_link_libraries(BloomCore PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::QuickLayouts Qt6::QuickDialogs2 Qt6::Network)

if (WIN32)
    target_link_libraries(BloomCore PRIVATE user32 ole32 dbghelp)
    
    # 実行時に相対参照される assets および qml をビルド-dirへ配置
    add_custom_command(TARGET BloomCore POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${CMAKE_CURRENT_SOURCE_DIR}/assets $<TARGET_FILE_DIR:BloomCore>/assets
        COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${CMAKE_CURRENT_SOURCE_DIR}/qml $<TARGET_FILE_DIR:BloomCore>/qml
    )
    
    # windeployqtを環境非依存で検索
    find_program(WINDEPLOYQT_EXECUTABLE
        NAMES windeployqt
        HINTS ${QT6_INSTALL_DIR}/bin ${CMAKE_PREFIX_PATH}/bin
    )
    if (WINDEPLOYQT_EXECUTABLE)
        add_custom_command(TARGET BloomCore POST_BUILD
            COMMAND ${WINDEPLOYQT_EXECUTABLE} --compiler-runtime --qmldir ${CMAKE_CURRENT_SOURCE_DIR}/qml $<TARGET_FILE:BloomCore>
        )
    else()
        message(WARNING "windeployqt not found. Manual deployment may be required.")
    endif()
endif()

set_target_properties(BloomCore PROPERTIES WIN32_EXECUTABLE FALSE)
