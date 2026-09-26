#pragma once

#include "../include/IMediaBackend.h"
#include "../../services/MusicControlService.h"

class Win32MediaBackend final : public IMediaBackend {
    Q_OBJECT
public:
    explicit Win32MediaBackend(QObject *parent = nullptr);
    ~Win32MediaBackend() override = default;

    void start();

    [[nodiscard]] QString trackTitle() const override;
    [[nodiscard]] QString artistName() const override;
    [[nodiscard]] bool isPlaying() const override;

    void playPause() override;
    void next() override;
    void previous() override;

    [[nodiscard]] MusicControlService *service() noexcept { return &m_service; }

private:
    MusicControlService m_service;
};
