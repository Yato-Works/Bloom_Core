#pragma once

#include <QObject>
#include <QString>

/// Abstract interface for wallpaper detection and dynamic palette generation.
class IThemeBackend : public QObject {
    Q_OBJECT
public:
    explicit IThemeBackend(QObject *parent = nullptr) : QObject(parent) {}
    ~IThemeBackend() override;

    [[nodiscard]] virtual QString currentWallpaperPath() const = 0;
    virtual void requestPaletteUpdate() = 0;

signals:
    void wallpaperChanged(const QString &path);
    void paletteReady();
};
