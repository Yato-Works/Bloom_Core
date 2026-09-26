#include "Win32AudioBackend.h"

Win32AudioBackend::Win32AudioBackend(QObject *parent)
    : IAudioBackend(parent)
{
    connect(&m_service, &CavaService::barsChanged, this, &IAudioBackend::spectrumUpdated);
    connect(&m_service, &CavaService::activeChanged, this, [this]() {
        emit capturingChanged(m_service.active());
    });
    connect(&m_service, &CavaService::hasAudioChanged, this, [this]() {
        emit hasAudioChanged(m_service.hasAudio());
    });
}

bool Win32AudioBackend::hasAudio() const
{
    return m_service.hasAudio();
}

QList<qreal> Win32AudioBackend::spectrumBars() const
{
    const auto &varBars = m_service.bars();
    QList<qreal> result;
    result.reserve(varBars.size());
    for (const auto &v : varBars) {
        result.append(v.toReal());
    }
    return result;
}

bool Win32AudioBackend::isCapturing() const
{
    return m_service.active();
}

void Win32AudioBackend::startCapture()
{
    m_service.start();
}

void Win32AudioBackend::stopCapture()
{
    m_service.stop();
}
