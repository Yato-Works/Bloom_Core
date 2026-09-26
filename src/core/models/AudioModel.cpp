#include "AudioModel.h"

AudioModel::AudioModel(IAudioBackend *backend, QObject *parent)
    : QObject(parent)
    , m_backend(backend)
{
    if (m_backend) {
        connect(m_backend, &IAudioBackend::spectrumUpdated, this, &AudioModel::spectrumUpdated);
        connect(m_backend, &IAudioBackend::capturingChanged, this, &AudioModel::capturingChanged);
        connect(m_backend, &IAudioBackend::hasAudioChanged, this, &AudioModel::hasAudioChanged);
    }
}

bool AudioModel::hasAudio() const
{
    return m_backend ? m_backend->hasAudio() : false;
}

QList<qreal> AudioModel::bars() const
{
    return m_backend ? m_backend->spectrumBars() : QList<qreal>();
}

bool AudioModel::active() const
{
    return m_backend ? m_backend->isCapturing() : false;
}

void AudioModel::setActive(bool enable)
{
    if (!m_backend) return;
    if (enable) {
        m_backend->startCapture();
    } else {
        m_backend->stopCapture();
    }
}

void AudioModel::start()
{
    if (m_backend) {
        m_backend->startCapture();
    }
}

void AudioModel::stop()
{
    if (m_backend) {
        m_backend->stopCapture();
    }
}
