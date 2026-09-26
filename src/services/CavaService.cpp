#include "CavaService.h"

#include <QDebug>
#include <QRandomGenerator>
#include <QThread>
#include <QtMath>
#include <algorithm>
#include <cmath>

#ifdef Q_OS_WIN
#  include <windows.h>
#  include <mmdeviceapi.h>
#  include <audioclient.h>
#  include <endpointvolume.h>

// GUID declarations to ensure linkage in MinGW / MSVC
#  ifndef __uuidof
#    define __uuidof(type) IID_##type
#  endif
static const CLSID CLSID_MMDeviceEnumerator_Val = { 0xBCDE0395, 0xE52F, 0x467C, { 0x8E, 0x3D, 0xC4, 0x57, 0x92, 0x91, 0x69, 0x2E } };
static const IID IID_IMMDeviceEnumerator_Val = { 0xA95664D2, 0x9614, 0x4F35, { 0xA7, 0x46, 0xDE, 0x8D, 0xB6, 0x36, 0x17, 0xE6 } };
static const IID IID_IAudioClient_Val = { 0x1CB9AD4C, 0xDBFA, 0x4c32, { 0xB1, 0x78, 0xC2, 0xF5, 0x68, 0xA7, 0x03, 0xB2 } };
static const IID IID_IAudioCaptureClient_Val = { 0xC8ADBD64, 0xE71E, 0x48a0, { 0xA4, 0xDE, 0x18, 0x5C, 0x39, 0x5C, 0xD3, 0x17 } };
static const GUID KSDATAFORMAT_SUBTYPE_IEEE_FLOAT_Val = { 0x00000003, 0x0000, 0x0010, { 0x80, 0x00, 0x00, 0xAA, 0x00, 0x38, 0x9B, 0x71 } };
#endif

CavaService::CavaService(QObject *parent)
    : QObject(parent)
    , m_bars(kBarCount, 0.0)
    , m_window(kFftSize)
    , m_fftRe(kFftSize)
    , m_fftIm(kFftSize)
    , m_bandRaw(kBarCount, 0.0f)
    , m_smoothed(kBarCount, 0.0f)
{
    // Precompute Hann window
    for (int i = 0; i < kFftSize; ++i) {
        m_window[i] = 0.5f * (1.0f - std::cos(2.0f * static_cast<float>(M_PI) * i / (kFftSize - 1)));
    }

    connect(&m_timer, &QTimer::timeout, this, &CavaService::refresh);
    m_timer.setInterval(16); // ~60fps
}

CavaService::~CavaService()
{
    m_timer.stop();
    stopCaptureThread();
}

void CavaService::start()
{
    if (m_captureActive) {
        return;
    }
    m_captureActive = true;
    emit activeChanged();

    startCaptureThread();
    m_timer.start();
    qInfo() << "CavaService: started (WASAPI loopback mode)";
}

void CavaService::stop()
{
    if (!m_captureActive) {
        return;
    }
    m_captureActive = false;
    m_timer.stop();
    stopCaptureThread();
    emit activeChanged();

    // Reset bars to zero
    std::fill(m_smoothed.begin(), m_smoothed.end(), 0.0f);
    m_bars.clear();
    m_bars.reserve(kBarCount);
    for (int i = 0; i < kBarCount; ++i) {
        m_bars.append(0.0);
    }
    emit barsChanged();

    if (m_hasAudio) {
        m_hasAudio = false;
        emit hasAudioChanged();
    }
    qInfo() << "CavaService: stopped";
}

void CavaService::refresh()
{
    if (!m_captureActive) {
        return;
    }

    if (m_everCaptured) {
        analyseSamples();
    } else {
        // Fallback or waiting for audio packets
        simulateBars();
    }

    m_bars.clear();
    m_bars.reserve(kBarCount);
    for (int i = 0; i < kBarCount; ++i) {
        m_bars.append(m_smoothed[i]);
    }
    emit barsChanged();
}

void CavaService::simulateBars()
{
    m_simPhase += 0.15;
    for (int i = 0; i < kBarCount; ++i) {
        double base = std::sin(m_simPhase + i * 0.2) * 0.5 + 0.5;
        double noise = QRandomGenerator::global()->generateDouble() * 0.3;
        double target = std::min(1.0, std::max(0.0, base + noise));

        double attack = 0.3;
        double decay = 0.15;
        if (target > m_smoothed[i]) {
            m_smoothed[i] += static_cast<float>((target - m_smoothed[i]) * attack);
        } else {
            m_smoothed[i] += static_cast<float>((target - m_smoothed[i]) * decay);
        }
    }
}

void CavaService::startCaptureThread()
{
    if (m_runThread) {
        return;
    }
    m_runThread = true;
    m_thread = std::thread(&CavaService::captureLoop, this);
}

void CavaService::stopCaptureThread()
{
    if (!m_runThread) {
        return;
    }
    m_runThread = false;
    if (m_thread.joinable()) {
        m_thread.join();
    }
}

void CavaService::captureLoop()
{
#ifdef Q_OS_WIN
    while (m_runThread) {
        HRESULT hr = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
        const bool coInited = SUCCEEDED(hr);

        IMMDeviceEnumerator *enumerator = nullptr;
        hr = CoCreateInstance(CLSID_MMDeviceEnumerator_Val, nullptr, CLSCTX_ALL,
                              IID_IMMDeviceEnumerator_Val, reinterpret_cast<void**>(&enumerator));
        if (FAILED(hr) || !enumerator) {
            qWarning() << "CavaService: failed to create IMMDeviceEnumerator, retrying...";
            if (coInited) CoUninitialize();
            for (int i = 0; i < 20 && m_runThread; ++i) Sleep(100);
            continue;
        }

        IMMDevice *device = nullptr;
        hr = enumerator->GetDefaultAudioEndpoint(eRender, eConsole, &device);
        if (FAILED(hr) || !device) {
            enumerator->Release();
            if (coInited) CoUninitialize();
            for (int i = 0; i < 15 && m_runThread; ++i) Sleep(100);
            continue;
        }

        IAudioClient *audioClient = nullptr;
        hr = device->Activate(IID_IAudioClient_Val, CLSCTX_ALL, nullptr, reinterpret_cast<void**>(&audioClient));
        if (FAILED(hr) || !audioClient) {
            device->Release();
            enumerator->Release();
            if (coInited) CoUninitialize();
            for (int i = 0; i < 15 && m_runThread; ++i) Sleep(100);
            continue;
        }

        WAVEFORMATEX *pwfx = nullptr;
        hr = audioClient->GetMixFormat(&pwfx);
        if (FAILED(hr) || !pwfx) {
            audioClient->Release();
            device->Release();
            enumerator->Release();
            if (coInited) CoUninitialize();
            for (int i = 0; i < 15 && m_runThread; ++i) Sleep(100);
            continue;
        }

        m_sampleRate = pwfx->nSamplesPerSec;
        const int channels = pwfx->nChannels;
        const bool isFloat = (pwfx->wFormatTag == WAVE_FORMAT_IEEE_FLOAT)
            || (pwfx->wFormatTag == WAVE_FORMAT_EXTENSIBLE
                && reinterpret_cast<WAVEFORMATEXTENSIBLE*>(pwfx)->SubFormat == KSDATAFORMAT_SUBTYPE_IEEE_FLOAT_Val);
        const int bitsPerSample = pwfx->wBitsPerSample;

        hr = audioClient->Initialize(AUDCLNT_SHAREMODE_SHARED,
                                    AUDCLNT_STREAMFLAGS_LOOPBACK,
                                    1000000 /* 100ms */, 0, pwfx, nullptr);
        if (FAILED(hr)) {
            CoTaskMemFree(pwfx);
            audioClient->Release();
            device->Release();
            enumerator->Release();
            if (coInited) CoUninitialize();
            for (int i = 0; i < 15 && m_runThread; ++i) Sleep(100);
            continue;
        }

        IAudioCaptureClient *captureClient = nullptr;
        hr = audioClient->GetService(IID_IAudioCaptureClient_Val, reinterpret_cast<void**>(&captureClient));
        if (FAILED(hr) || !captureClient) {
            CoTaskMemFree(pwfx);
            audioClient->Release();
            device->Release();
            enumerator->Release();
            if (coInited) CoUninitialize();
            for (int i = 0; i < 15 && m_runThread; ++i) Sleep(100);
            continue;
        }

        audioClient->Start();
        m_everCaptured = true;

        std::vector<float> tempMono;
        tempMono.reserve(4096);
        bool deviceInvalidated = false;

        while (m_runThread && !deviceInvalidated) {
            UINT32 packetLength = 0;
            hr = captureClient->GetNextPacketSize(&packetLength);
            if (FAILED(hr)) {
                // Device invalidated (e.g. headphone unplugged / default device changed)
                deviceInvalidated = true;
                break;
            }
            if (packetLength == 0) {
                Sleep(8);
                continue;
            }

            BYTE *pData = nullptr;
            UINT32 numFramesAvailable = 0;
            DWORD flags = 0;
            hr = captureClient->GetBuffer(&pData, &numFramesAvailable, &flags, nullptr, nullptr);
            if (FAILED(hr)) {
                deviceInvalidated = true;
                break;
            }

            if (numFramesAvailable > 0) {
                tempMono.clear();
                const bool silent = (flags & AUDCLNT_BUFFERFLAGS_SILENT) != 0;

                if (silent) {
                    tempMono.assign(numFramesAvailable, 0.0f);
                } else if (isFloat && bitsPerSample == 32) {
                    const float *samples = reinterpret_cast<const float*>(pData);
                    for (UINT32 f = 0; f < numFramesAvailable; ++f) {
                        float sum = 0.0f;
                        for (int c = 0; c < channels; ++c) {
                            sum += samples[f * channels + c];
                        }
                        tempMono.push_back(sum / channels);
                    }
                } else if (bitsPerSample == 16) {
                    const int16_t *samples = reinterpret_cast<const int16_t*>(pData);
                    for (UINT32 f = 0; f < numFramesAvailable; ++f) {
                        float sum = 0.0f;
                        for (int c = 0; c < channels; ++c) {
                            sum += samples[f * channels + c] / 32768.0f;
                        }
                        tempMono.push_back(sum / channels);
                    }
                } else if (bitsPerSample == 24) {
                    // 24-bit signed PCM (3 bytes per sample)
                    const uint8_t *bytes = pData;
                    for (UINT32 f = 0; f < numFramesAvailable; ++f) {
                        float sum = 0.0f;
                        for (int c = 0; c < channels; ++c) {
                            size_t idx = (static_cast<size_t>(f) * channels + c) * 3;
                            int32_t val = (bytes[idx]) | (bytes[idx + 1] << 8) | (static_cast<int8_t>(bytes[idx + 2]) << 16);
                            sum += static_cast<float>(val) / 8388608.0f;
                        }
                        tempMono.push_back(sum / channels);
                    }
                } else if (!isFloat && bitsPerSample == 32) {
                    const int32_t *samples = reinterpret_cast<const int32_t*>(pData);
                    for (UINT32 f = 0; f < numFramesAvailable; ++f) {
                        float sum = 0.0f;
                        for (int c = 0; c < channels; ++c) {
                            sum += static_cast<float>(samples[f * channels + c]) / 2147483648.0f;
                        }
                        tempMono.push_back(sum / channels);
                    }
                } else {
                    tempMono.assign(numFramesAvailable, 0.0f);
                }

                captureClient->ReleaseBuffer(numFramesAvailable);

                // Push to recent sample buffer
                {
                    std::lock_guard<std::mutex> lock(m_sampleMutex);
                    m_samples.insert(m_samples.end(), tempMono.begin(), tempMono.end());
                    if (m_samples.size() > static_cast<size_t>(kFftSize * 4)) {
                        m_samples.erase(m_samples.begin(), m_samples.end() - (kFftSize * 2));
                    }
                }
            }
            Sleep(5);
        }

        audioClient->Stop();
        captureClient->Release();
        CoTaskMemFree(pwfx);
        audioClient->Release();
        device->Release();
        enumerator->Release();
        if (coInited) CoUninitialize();

        if (deviceInvalidated && m_runThread) {
            qInfo() << "CavaService: audio endpoint invalidated, reconnecting in 300ms...";
            Sleep(300);
        }
    }
#else
    m_everCaptured = false;
#endif
}

void CavaService::runFft(std::vector<float> &re, std::vector<float> &im, int n)
{
    int j = 0;
    for (int i = 0; i < n - 1; ++i) {
        if (i < j) {
            std::swap(re[i], re[j]);
            std::swap(im[i], im[j]);
        }
        int k = n >> 1;
        while (k <= j) {
            j -= k;
            k >>= 1;
        }
        j += k;
    }

    for (int len = 2; len <= n; len <<= 1) {
        const double ang = -2.0 * M_PI / len;
        const float wlen_re = static_cast<float>(std::cos(ang));
        const float wlen_im = static_cast<float>(std::sin(ang));
        const int half = len >> 1;
        for (int i = 0; i < n; i += len) {
            float w_re = 1.0f;
            float w_im = 0.0f;
            for (int k = 0; k < half; ++k) {
                const float u_re = re[i + k];
                const float u_im = im[i + k];
                const float v_re = re[i + k + half] * w_re - im[i + k + half] * w_im;
                const float v_im = re[i + k + half] * w_im + im[i + k + half] * w_re;
                re[i + k] = u_re + v_re;
                im[i + k] = u_im + v_im;
                re[i + k + half] = u_re - v_re;
                im[i + k + half] = u_im - v_im;
                const float next_w_re = w_re * wlen_re - w_im * wlen_im;
                const float next_w_im = w_re * wlen_im + w_im * wlen_re;
                w_re = next_w_re;
                w_im = next_w_im;
            }
        }
    }
}

void CavaService::analyseSamples()
{
    std::vector<float> localSamples;
    {
        std::lock_guard<std::mutex> lock(m_sampleMutex);
        if (m_samples.size() >= static_cast<size_t>(kFftSize)) {
            localSamples.assign(m_samples.end() - kFftSize, m_samples.end());
        }
    }

    if (localSamples.size() < static_cast<size_t>(kFftSize)) {
        // Not enough samples yet
        for (int i = 0; i < kBarCount; ++i) {
            m_smoothed[i] *= 0.8f;
            if (m_smoothed[i] < 0.001f) m_smoothed[i] = 0.0f;
        }
        return;
    }

    // Check peak amplitude to detect silence / paused state
    float maxAmp = 0.0f;
    for (int i = 0; i < kFftSize; ++i) {
        maxAmp = std::max(maxAmp, std::abs(localSamples[i]));
    }

    const bool silent = (maxAmp < 0.001f);
    if (silent) {
        m_silentFramesCount++;
    } else {
        m_silentFramesCount = 0;
    }

    const bool hasAudioNow = (m_silentFramesCount < 10);
    if (m_hasAudio != hasAudioNow) {
        m_hasAudio = hasAudioNow;
        emit hasAudioChanged();
    }

    if (silent) {
        // Decay to zero smoothly when audio is stopped or silent
        for (int i = 0; i < kBarCount; ++i) {
            m_smoothed[i] *= 0.72f;
            if (m_smoothed[i] < 0.002f) {
                m_smoothed[i] = 0.0f;
            }
        }
        return;
    }

    // Apply Hann window and copy into FFT real buffer
    for (int i = 0; i < kFftSize; ++i) {
        m_fftRe[i] = localSamples[i] * m_window[i];
        m_fftIm[i] = 0.0f;
    }

    // Compute FFT
    runFft(m_fftRe, m_fftIm, kFftSize);

    // Map frequency bins to logarithmic bars (40Hz to 16000Hz)
    const float sampleRate = static_cast<float>(m_sampleRate.load());
    const float minFreq = 40.0f;
    const float maxFreq = std::min(16000.0f, sampleRate * 0.48f);
    const float logMin = std::log10(minFreq);
    const float logMax = std::log10(maxFreq);

    float framePeak = 0.001f;

    for (int b = 0; b < kBarCount; ++b) {
        const float fStart = std::pow(10.0f, logMin + (logMax - logMin) * b / kBarCount);
        const float fEnd = std::pow(10.0f, logMin + (logMax - logMin) * (b + 1) / kBarCount);

        int binStart = static_cast<int>(fStart * kFftSize / sampleRate);
        int binEnd = static_cast<int>(fEnd * kFftSize / sampleRate);
        binStart = std::clamp(binStart, 1, kFftSize / 2 - 1);
        binEnd = std::clamp(binEnd, binStart + 1, kFftSize / 2);

        float magSum = 0.0f;
        for (int k = binStart; k < binEnd; ++k) {
            float mag = std::sqrt(m_fftRe[k] * m_fftRe[k] + m_fftIm[k] * m_fftIm[k]);
            magSum += mag;
        }
        float avgMag = (magSum / (binEnd - binStart)) / (kFftSize / 4);

        // Pre-emphasis for higher frequencies (audio tends to roll off)
        float boost = 1.0f + 1.8f * (static_cast<float>(b) / kBarCount);
        avgMag *= boost;

        m_bandRaw[b] = avgMag;
        framePeak = std::max(framePeak, avgMag);
    }

    // Auto-gain with smooth hold
    if (framePeak > m_peakHold) {
        m_peakHold = framePeak;
    } else {
        m_peakHold = m_peakHold * 0.985 + framePeak * 0.015;
    }
    m_peakHold = std::max(0.04, m_peakHold);

    // Update smoothed bars
    for (int b = 0; b < kBarCount; ++b) {
        float norm = std::clamp(static_cast<float>(m_bandRaw[b] / m_peakHold), 0.0f, 1.0f);
        // Non-linear perception curve
        norm = std::sqrt(norm);

        const float attack = 0.45f;
        const float decay = 0.18f;
        if (norm > m_smoothed[b]) {
            m_smoothed[b] += (norm - m_smoothed[b]) * attack;
        } else {
            m_smoothed[b] += (norm - m_smoothed[b]) * decay;
        }

        if (m_smoothed[b] < 0.005f) {
            m_smoothed[b] = 0.0f;
        }
    }
}