#include "SystemModel.h"

SystemModel::SystemModel(ISystemInfoBackend *backend, QObject *parent)
    : QObject(parent)
    , m_backend(backend)
{
    if (m_backend) {
        connect(m_backend, &ISystemInfoBackend::metricsChanged, this, &SystemModel::metricsChanged);
        connect(m_backend, &ISystemInfoBackend::audioEndpointChanged, this, &SystemModel::audioEndpointChanged);
    }
}

int SystemModel::cpuUsage() const
{
    return m_backend ? m_backend->cpuUsage() : 0;
}

int SystemModel::memoryUsage() const
{
    return m_backend ? m_backend->memoryUsage() : 0;
}

QString SystemModel::memorySummary() const
{
    return m_backend ? m_backend->memorySummary() : QString();
}

bool SystemModel::hasBattery() const
{
    return m_backend ? m_backend->hasBattery() : false;
}

int SystemModel::batteryPercent() const
{
    return m_backend ? m_backend->batteryPercent() : 100;
}

bool SystemModel::batteryCharging() const
{
    return m_backend ? m_backend->batteryCharging() : false;
}

int SystemModel::volumeLevel() const
{
    return m_backend ? m_backend->volumeLevel() : 50;
}

bool SystemModel::volumeMuted() const
{
    return m_backend ? m_backend->volumeMuted() : false;
}

QString SystemModel::hostName() const
{
    return m_backend ? m_backend->hostName() : QStringLiteral("Bloom-Host");
}

QString SystemModel::uptime() const
{
    return m_backend ? m_backend->uptime() : QStringLiteral("0m");
}

void SystemModel::setVolume(int level)
{
    if (m_backend) {
        m_backend->setVolume(level);
    }
}

void SystemModel::toggleMute()
{
    if (m_backend) {
        m_backend->toggleMute();
    }
}
