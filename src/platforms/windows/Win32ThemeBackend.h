#pragma once

#include "../include/IThemeBackend.h"
#include "../../services/WallpaperService.h"
#include "../../services/CaelestiaColours.h"

class Win32ThemeBackend final : public IThemeBackend {
    Q_OBJECT
public:
    explicit Win32ThemeBackend(QObject *parent = nullptr);
    ~Win32ThemeBackend() override = default;

    void initialize();

    [[nodiscard]] QString currentWallpaperPath() const override;
    void requestPaletteUpdate() override;

    [[nodiscard]] WallpaperService *wallpaperService() noexcept { return &m_wallpaperService; }

private:
    WallpaperService m_wallpaperService;
};
