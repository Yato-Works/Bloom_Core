#include "CaelestiaColours.h"

CaelestiaColours *CaelestiaColours::s_instance = nullptr;

CaelestiaColours::CaelestiaColours(QObject *parent)
    : QObject(parent)
{
    s_instance = this;
    assign(PaletteEngine::fallback());
}

CaelestiaColours *CaelestiaColours::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(jsEngine);
    if (!s_instance)
        s_instance = new CaelestiaColours();
    if (qmlEngine)
        qmlEngine->setObjectOwnership(s_instance, QQmlEngine::CppOwnership);
    return s_instance;
}

CaelestiaColours *CaelestiaColours::instance()
{
    if (!s_instance)
        s_instance = new CaelestiaColours();
    return s_instance;
}

void CaelestiaColours::applyWallpaperPalette(const QString &wallpaperPath)
{
    if (wallpaperPath.isEmpty()) {
        resetToDefault();
        return;
    }
    bool ok = false;
    const PaletteEngine::M3Palette extracted = PaletteEngine::extract(wallpaperPath, &ok);
    if (!ok)
        return; // keep the current palette on transient failures
    assign(extracted);
}

void CaelestiaColours::resetToDefault()
{
    assign(PaletteEngine::fallback());
}

void CaelestiaColours::assign(const PaletteEngine::M3Palette &p)
{
    bool changed = false;
    const auto set = [&changed](QColor &dst, const QColor &src) {
        if (dst != src) {
            dst = src;
            changed = true;
        }
    };
    set(m_background, p.background);
    set(m_onBackground, p.onBackground);
    set(m_surface, p.surface);
    set(m_surfaceDim, p.surfaceDim);
    set(m_surfaceBright, p.surfaceBright);
    set(m_surfaceContainerLowest, p.surfaceContainerLowest);
    set(m_surfaceContainerLow, p.surfaceContainerLow);
    set(m_surfaceContainer, p.surfaceContainer);
    set(m_surfaceContainerHigh, p.surfaceContainerHigh);
    set(m_surfaceContainerHighest, p.surfaceContainerHighest);
    set(m_onSurface, p.onSurface);
    set(m_surfaceVariant, p.surfaceVariant);
    set(m_onSurfaceVariant, p.onSurfaceVariant);
    set(m_inverseSurface, p.inverseSurface);
    set(m_inverseOnSurface, p.inverseOnSurface);
    set(m_outline, p.outline);
    set(m_outlineVariant, p.outlineVariant);
    set(m_shadow, p.shadow);
    set(m_scrim, p.scrim);
    set(m_surfaceTint, p.surfaceTint);
    set(m_primary, p.primary);
    set(m_onPrimary, p.onPrimary);
    set(m_primaryContainer, p.primaryContainer);
    set(m_onPrimaryContainer, p.onPrimaryContainer);
    set(m_inversePrimary, p.inversePrimary);
    set(m_secondary, p.secondary);
    set(m_onSecondary, p.onSecondary);
    set(m_secondaryContainer, p.secondaryContainer);
    set(m_onSecondaryContainer, p.onSecondaryContainer);
    set(m_tertiary, p.tertiary);
    set(m_onTertiary, p.onTertiary);
    set(m_tertiaryContainer, p.tertiaryContainer);
    set(m_onTertiaryContainer, p.onTertiaryContainer);
    set(m_error, p.error);
    set(m_onError, p.onError);
    set(m_errorContainer, p.errorContainer);
    set(m_onErrorContainer, p.onErrorContainer);
    set(m_success, p.success);
    set(m_onSuccess, p.onSuccess);
    set(m_successContainer, p.successContainer);
    set(m_onSuccessContainer, p.onSuccessContainer);
    set(m_primaryFixed, p.primaryFixed);
    set(m_primaryFixedDim, p.primaryFixedDim);
    set(m_onPrimaryFixed, p.onPrimaryFixed);
    set(m_onPrimaryFixedVariant, p.onPrimaryFixedVariant);
    set(m_secondaryFixed, p.secondaryFixed);
    set(m_secondaryFixedDim, p.secondaryFixedDim);
    set(m_onSecondaryFixed, p.onSecondaryFixed);
    set(m_onSecondaryFixedVariant, p.onSecondaryFixedVariant);
    set(m_tertiaryFixed, p.tertiaryFixed);
    set(m_tertiaryFixedDim, p.tertiaryFixedDim);
    set(m_onTertiaryFixed, p.onTertiaryFixed);
    set(m_onTertiaryFixedVariant, p.onTertiaryFixedVariant);

    if (changed)
        emit paletteChanged();
}