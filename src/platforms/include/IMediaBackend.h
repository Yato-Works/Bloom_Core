#pragma once

#include <QObject>
#include <QString>

/// Abstract interface for media player sessions.
/// Implemented by Windows (Win32 window titles / WinRT GSMTC) and Linux (MPRIS D-Bus).
class IMediaBackend : public QObject {
    Q_OBJECT
public:
    explicit IMediaBackend(QObject *parent = nullptr) : QObject(parent) {}
    ~IMediaBackend() override;

    [[nodiscard]] virtual QString trackTitle() const = 0;
    [[nodiscard]] virtual QString artistName() const = 0;
    [[nodiscard]] virtual bool isPlaying() const = 0;

    virtual void playPause() = 0;
    virtual void next() = 0;
    virtual void previous() = 0;

signals:
    void trackChanged();
    void playbackStateChanged(bool isPlaying);
};
