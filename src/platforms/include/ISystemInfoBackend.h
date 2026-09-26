#pragma once

#include <QObject>
#include <QString>

/// Abstract interface for hardware, system metrics, and audio endpoint state.
class ISystemInfoBackend : public QObject {
    Q_OBJECT
public:
    explicit ISystemInfoBackend(QObject *parent = nullptr) : QObject(parent) {}
    ~ISystemInfoBackend() override;

    [[nodiscard]] virtual int cpuUsage() const = 0;
    [[nodiscard]] virtual int memoryUsage() const = 0;
    [[nodiscard]] virtual QString memorySummary() const = 0;

    [[nodiscard]] virtual bool hasBattery() const = 0;
    [[nodiscard]] virtual int batteryPercent() const = 0;
    [[nodiscard]] virtual bool batteryCharging() const = 0;

    [[nodiscard]] virtual int volumeLevel() const = 0;
    [[nodiscard]] virtual bool volumeMuted() const = 0;
    virtual void setVolume(int level) = 0;
    virtual void toggleMute() = 0;

    [[nodiscard]] virtual QString hostName() const = 0;
    [[nodiscard]] virtual QString uptime() const = 0;

signals:
    void metricsChanged();
    void audioEndpointChanged();
};
