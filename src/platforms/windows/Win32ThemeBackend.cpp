#include "Win32ThemeBackend.h"

Win32ThemeBackend::Win32ThemeBackend(QObject *parent)
    : IThemeBackend(parent)
{
    connect(&m_wallpaperService, &WallpaperService::currentWallpaperChanged, this, [this]() {
        emit wallpaperChanged(m_wallpaperService.currentWallpaperPath());
        requestPaletteUpdate();
    });
}

void Win32ThemeBackend::initialize()
{
    requestPaletteUpdate();
}

QString Win32ThemeBackend::currentWallpaperPath() const
{
    return m_wallpaperService.currentWallpaperPath();
}

void Win32ThemeBackend::requestPaletteUpdate()
{
    if (auto *colours = CaelestiaColours::instance()) {
        colours->applyWallpaperPalette(m_wallpaperService.currentWallpaperPath());
        emit paletteReady();
    }
}
