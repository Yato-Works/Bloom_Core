#pragma once

#include <QObject>
#include <QString>
#include "../../platforms/include/ISystemInfoBackend.h"

/// QML Model exposing system metrics, battery, volume and hostname.
class SystemModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(int cpuUsage READ cpuUsage NOTIFY metricsChanged)
    Q_PROPERTY(int memoryUsage READ memoryUsage NOTIFY metricsChanged)
    Q_PROPERTY(QString memorySummary READ memorySummary NOTIFY metricsChanged)
    Q_PROPERTY(bool hasBattery READ hasBattery NOTIFY metricsChanged)
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY metricsChanged)
    Q_PROPERTY(bool batteryCharging READ batteryCharging NOTIFY metricsChanged)
    Q_PROPERTY(int volumeLevel READ volumeLevel WRITE setVolume NOTIFY audioEndpointChanged)
    Q_PROPERTY(bool volumeMuted READ volumeMuted NOTIFY audioEndpointChanged)
    Q_PROPERTY(QString hostName READ hostName CONSTANT)
    Q_PROPERTY(QString uptime READ uptime NOTIFY metricsChanged)
public:
    explicit SystemModel(ISystemInfoBackend *backend, QObject *parent = nullptr);

    [[nodiscard]] int cpuUsage() const;
    [[nodiscard]] int memoryUsage() const;
    [[nodiscard]] QString memorySummary() const;
    [[nodiscard]] bool hasBattery() const;
    [[nodiscard]] int batteryPercent() const;
    [[nodiscard]] bool batteryCharging() const;
    [[nodiscard]] int volumeLevel() const;
    [[nodiscard]] bool volumeMuted() const;
    [[nodiscard]] QString hostName() const;
    [[nodiscard]] QString uptime() const;

    Q_INVOKABLE void setVolume(int level);
    Q_INVOKABLE void toggleMute();

signals:
    void metricsChanged();
    void audioEndpointChanged();

private:
    ISystemInfoBackend *m_backend;
};
