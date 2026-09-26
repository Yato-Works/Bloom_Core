#pragma once

#include <QObject>
#include <QTimer>
#include <QString>
#include <QVariant>

class MusicControlService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString trackTitle READ trackTitle NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(QString artistName READ artistName NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(int position READ position NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(int length READ length NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(QString sourceApp READ sourceApp NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool canSeek READ canSeek NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool positionSupported READ positionSupported NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool canGoPrevious READ canGoPrevious NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool canGoNext READ canGoNext NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool canTogglePlaying READ canTogglePlaying NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool shuffleSupported READ shuffleSupported NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool shuffle READ shuffle WRITE setShuffle NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool loopSupported READ loopSupported NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(int loopState READ loopState WRITE setLoopState NOTIFY trackInfoChanged FINAL)

public:
    enum LoopState { None = 0, Track = 1, Playlist = 2 };
    Q_ENUM(LoopState)

    explicit MusicControlService(QObject *parent = nullptr);
    ~MusicControlService() override;

    [[nodiscard]] QString trackTitle() const noexcept { return m_trackTitle; }
    [[nodiscard]] QString artistName() const noexcept { return m_artistName; }
    [[nodiscard]] bool isPlaying() const noexcept { return m_isPlaying; }
    [[nodiscard]] int position() const noexcept { return m_position; }
    [[nodiscard]] int length() const noexcept { return m_length; }
    [[nodiscard]] QString sourceApp() const noexcept { return m_sourceApp; }
    [[nodiscard]] bool canSeek() const noexcept { return m_canSeek; }
    [[nodiscard]] bool positionSupported() const noexcept { return m_positionSupported; }
    [[nodiscard]] bool canGoPrevious() const noexcept { return m_canGoPrevious; }
    [[nodiscard]] bool canGoNext() const noexcept { return m_canGoNext; }
    [[nodiscard]] bool canTogglePlaying() const noexcept { return m_canTogglePlaying; }
    [[nodiscard]] bool shuffleSupported() const noexcept { return m_shuffleSupported; }
    [[nodiscard]] bool shuffle() const noexcept { return m_shuffle; }
    void setShuffle(bool s) { m_shuffle = s; emit trackInfoChanged(); }
    [[nodiscard]] bool loopSupported() const noexcept { return m_loopSupported; }
    [[nodiscard]] int loopState() const noexcept { return m_loopState; }
    void setLoopState(int s) { m_loopState = s; emit trackInfoChanged(); }

    Q_INVOKABLE void playPause();
    Q_INVOKABLE void togglePlayPause();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
    Q_INVOKABLE void positionChanged();

    void start();

signals:
    void trackInfoChanged();

private:
    void refresh();

    QTimer m_refreshTimer;
    QString m_trackTitle;
    QString m_artistName;
    bool m_isPlaying {false};
    int m_position {0};
    int m_length {0};
    QString m_sourceApp;
    bool m_canSeek {true};
    bool m_positionSupported {true};
    bool m_canGoPrevious {true};
    bool m_canGoNext {true};
    bool m_canTogglePlaying {true};
    bool m_shuffleSupported {false};
    bool m_shuffle {false};
    bool m_loopSupported {false};
    int m_loopState {None};
};
