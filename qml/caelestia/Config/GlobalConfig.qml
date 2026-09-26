pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property var services: ({
        defaultPlayer: "Spotify",
        playerAliases: []
    })

    readonly property var utilities: ({
        toasts: {
            capsLockChanged: false,
            numLockChanged: false,
            kbLayoutChanged: false,
            nowPlaying: true
        }
    })
}
