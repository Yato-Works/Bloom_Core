#pragma once

#include <QObject>
#include <QTimer>
#include <QVariantList>

#include <atomic>
#include <mutex>
#include <thread>
#include <vector>

/// System audio spectrum analyser.
///
/// Captures the Windows default render endpoint via WASAPI loopback (so it
/// visualises exactly what the system is playing), runs a Hann-windowed FFT
/// over the captured samples and publishes log-spaced frequency bands to QML
/// through the same `bars` / `active` API the old cava-based service used.
class CavaService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList bars READ bars NOTIFY barsChanged FINAL)
    Q_PROPERTY(bool active READ active NOTIFY activeChanged FINAL)
    Q_PROPERTY(bool hasAudio READ hasAudio NOTIFY hasAudioChanged FINAL)

public:
    explicit CavaService(QObject *parent = nullptr);
    ~CavaService() override;

    /// List of normalized frequency bar magnitudes [0.0, 1.0].
    [[nodiscard]] QVariantList bars() const noexcept { return m_bars; }

    /// Whether loopback audio capture and FFT analysis are currently running.
    [[nodiscard]] bool active() const noexcept { return m_captureActive; }

    /// Returns true if an active audio stream with non-zero signal is playing.
    /// Returns false when audio is silent, paused, or stopped.
    [[nodiscard]] bool hasAudio() const noexcept { return m_hasAudio; }

public slots:
    /// Start loopback audio capture and spectrum analysis.
    Q_INVOKABLE void start();

    /// Stop capture, release device streams, and zero-out visualizer bars.
    Q_INVOKABLE void stop();

signals:
    void barsChanged();
    void activeChanged();
    void hasAudioChanged();

private:
    void refresh();          // GUI thread: analyse latest samples, emit bars
    void simulateBars();     // Fallback when audio capture is unavailable
    void startCaptureThread();
    void stopCaptureThread();
    void captureLoop();      // Worker thread: WASAPI loopback -> sample buffer
    void analyseSamples();
    void runFft(std::vector<float> &re, std::vector<float> &im, int n);

    static constexpr int kBarCount = 96;
    static constexpr int kFftSize = 1024;

    std::thread m_thread;
    std::atomic_bool m_runThread {false};
    std::atomic_bool m_captureActive {false};
    std::atomic_bool m_everCaptured {false};
    std::atomic<int> m_sampleRate {48000};
    bool m_hasAudio {false};

    std::mutex m_sampleMutex;
    std::vector<float> m_samples;      // Mono capture buffer (recent tail)

    QTimer m_timer;
    QVariantList m_bars;

    // Analysis state (GUI thread only)
    std::vector<float> m_window;       // Hann window
    std::vector<float> m_fftRe;
    std::vector<float> m_fftIm;
    std::vector<float> m_bandRaw;      // Magnitudes for this frame
    std::vector<float> m_smoothed;     // Attack/decay smoothed output
    double m_peakHold {0.0};           // Auto-gain reference
    qreal m_simPhase {0.0};
    int m_silentFramesCount {0};
};
