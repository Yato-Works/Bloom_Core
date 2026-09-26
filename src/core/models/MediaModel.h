#pragma once

#include <QObject>
#include <QString>
#include "../../platforms/include/IMediaBackend.h"

/// QML Model exposing abstract media session.
class MediaModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString trackTitle READ trackTitle NOTIFY trackChanged)
    Q_PROPERTY(QString artistName READ artistName NOTIFY trackChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY playbackStateChanged)
public:
    explicit MediaModel(IMediaBackend *backend, QObject *parent = nullptr);

    [[nodiscard]] QString trackTitle() const;
    [[nodiscard]] QString artistName() const;
    [[nodiscard]] bool isPlaying() const;

    Q_INVOKABLE void playPause();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();

signals:
    void trackChanged();
    void playbackStateChanged();

private:
    IMediaBackend *m_backend;
};
