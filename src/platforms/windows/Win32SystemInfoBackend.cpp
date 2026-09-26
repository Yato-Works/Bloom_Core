#include "Win32SystemInfoBackend.h"

Win32SystemInfoBackend::Win32SystemInfoBackend(QObject *parent)
    : ISystemInfoBackend(parent)
{
    connect(&m_service, &SystemInfoService::metricsChanged, this, &ISystemInfoBackend::metricsChanged);
    connect(&m_service, &SystemInfoService::metricsChanged, this, &ISystemInfoBackend::audioEndpointChanged);
}

int Win32SystemInfoBackend::cpuUsage() const
{
    return m_service.cpuUsage();
}

int Win32SystemInfoBackend::memoryUsage() const
{
    return m_service.memoryUsage();
}

QString Win32SystemInfoBackend::memorySummary() const
{
    return m_service.memorySummary();
}

bool Win32SystemInfoBackend::hasBattery() const
{
    return m_service.hasBattery();
}

int Win32SystemInfoBackend::batteryPercent() const
{
    return m_service.batteryPercent();
}

bool Win32SystemInfoBackend::batteryCharging() const
{
    return m_service.batteryCharging();
}

int Win32SystemInfoBackend::volumeLevel() const
{
    return m_service.volumeLevel();
}

bool Win32SystemInfoBackend::volumeMuted() const
{
    return m_service.volumeMuted();
}

void Win32SystemInfoBackend::setVolume(int level)
{
    m_service.setVolume(level);
}

void Win32SystemInfoBackend::toggleMute()
{
    m_service.toggleMute();
}

QString Win32SystemInfoBackend::hostName() const
{
    return m_service.hostName();
}

QString Win32SystemInfoBackend::uptime() const
{
    return m_service.uptime();
}
