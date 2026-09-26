#pragma once

#include <QObject>
#include <QList>
#include "../../platforms/include/IAudioBackend.h"

/// QML Model exposing audio spectrum visualizer (CAVA / Pipewire FFT).
class AudioModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(QList<qreal> bars READ bars NOTIFY spectrumUpdated)
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY capturingChanged)
    Q_PROPERTY(bool hasAudio READ hasAudio NOTIFY hasAudioChanged)
public:
    explicit AudioModel(IAudioBackend *backend, QObject *parent = nullptr);

    [[nodiscard]] QList<qreal> bars() const;
    [[nodiscard]] bool active() const;
    [[nodiscard]] bool hasAudio() const;
    void setActive(bool enable);

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();

signals:
    void spectrumUpdated();
    void capturingChanged(bool active);
    void hasAudioChanged(bool hasAudio);

private:
    IAudioBackend *m_backend;
};
