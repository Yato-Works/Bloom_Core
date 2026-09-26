#include "Win32MediaBackend.h"

Win32MediaBackend::Win32MediaBackend(QObject *parent)
    : IMediaBackend(parent)
{
    connect(&m_service, &MusicControlService::trackInfoChanged, this, [this]() {
        emit trackChanged();
        emit playbackStateChanged(m_service.isPlaying());
    });
}

void Win32MediaBackend::start()
{
    m_service.start();
}

QString Win32MediaBackend::trackTitle() const
{
    return m_service.trackTitle();
}

QString Win32MediaBackend::artistName() const
{
    return m_service.artistName();
}

bool Win32MediaBackend::isPlaying() const
{
    return m_service.isPlaying();
}

void Win32MediaBackend::playPause()
{
    m_service.togglePlayPause();
}

void Win32MediaBackend::next()
{
    m_service.next();
}

void Win32MediaBackend::previous()
{
    m_service.previous();
}
