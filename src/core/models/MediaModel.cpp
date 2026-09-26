#include "MediaModel.h"

MediaModel::MediaModel(IMediaBackend *backend, QObject *parent)
    : QObject(parent)
    , m_backend(backend)
{
    if (m_backend) {
        connect(m_backend, &IMediaBackend::trackChanged, this, &MediaModel::trackChanged);
        connect(m_backend, &IMediaBackend::playbackStateChanged, this, &MediaModel::playbackStateChanged);
    }
}

QString MediaModel::trackTitle() const
{
    return m_backend ? m_backend->trackTitle() : QString();
}

QString MediaModel::artistName() const
{
    return m_backend ? m_backend->artistName() : QString();
}

bool MediaModel::isPlaying() const
{
    return m_backend ? m_backend->isPlaying() : false;
}

void MediaModel::playPause()
{
    if (m_backend) {
        m_backend->playPause();
    }
}

void MediaModel::next()
{
    if (m_backend) {
        m_backend->next();
    }
}

void MediaModel::previous()
{
    if (m_backend) {
        m_backend->previous();
    }
}
