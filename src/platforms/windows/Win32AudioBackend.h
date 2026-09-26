#pragma once

#include "../include/IAudioBackend.h"
#include "../../services/CavaService.h"

class Win32AudioBackend final : public IAudioBackend {
    Q_OBJECT
public:
    explicit Win32AudioBackend(QObject *parent = nullptr);
    ~Win32AudioBackend() override = default;

    [[nodiscard]] QList<qreal> spectrumBars() const override;
    [[nodiscard]] bool isCapturing() const override;
    [[nodiscard]] bool hasAudio() const override;

    void startCapture() override;
    void stopCapture() override;

    [[nodiscard]] CavaService *service() noexcept { return &m_service; }

private:
    CavaService m_service;
};
