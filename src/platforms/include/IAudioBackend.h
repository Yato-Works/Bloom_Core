#pragma once

#include <QObject>
#include <QList>

/// Abstract interface for audio spectrum visualizer (CAVA/FFT/Pipewire).
class IAudioBackend : public QObject {
    Q_OBJECT
public:
    explicit IAudioBackend(QObject *parent = nullptr) : QObject(parent) {}
    ~IAudioBackend() override;

    [[nodiscard]] virtual QList<qreal> spectrumBars() const = 0;
    [[nodiscard]] virtual bool isCapturing() const = 0;
    [[nodiscard]] virtual bool hasAudio() const { return false; }

    virtual void startCapture() = 0;
    virtual void stopCapture() = 0;

signals:
    void spectrumUpdated();
    void capturingChanged(bool active);
    void hasAudioChanged(bool hasAudio);
};
