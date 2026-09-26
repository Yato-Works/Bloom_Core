#pragma once

#include "../include/ISystemInfoBackend.h"
#include "../../services/SystemInfoService.h"

class Win32SystemInfoBackend final : public ISystemInfoBackend {
    Q_OBJECT
public:
    explicit Win32SystemInfoBackend(QObject *parent = nullptr);
    ~Win32SystemInfoBackend() override = default;

    [[nodiscard]] int cpuUsage() const override;
    [[nodiscard]] int memoryUsage() const override;
    [[nodiscard]] QString memorySummary() const override;

    [[nodiscard]] bool hasBattery() const override;
    [[nodiscard]] int batteryPercent() const override;
    [[nodiscard]] bool batteryCharging() const override;

    [[nodiscard]] int volumeLevel() const override;
    [[nodiscard]] bool volumeMuted() const override;
    void setVolume(int level) override;
    void toggleMute() override;

    [[nodiscard]] QString hostName() const override;
    [[nodiscard]] QString uptime() const override;

    [[nodiscard]] SystemInfoService *service() noexcept { return &m_service; }

private:
    SystemInfoService m_service;
};
