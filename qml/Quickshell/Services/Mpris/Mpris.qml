pragma Singleton
import QtQuick

// ============================================================================
// Quickshell.Services.Mpris — MPRIS Media Compatibility Bridge for Windows
// Adapts Linux MPRIS D-Bus player controls by delegating to Bloom Core's MediaModel.
// ============================================================================
QtObject {
    id: root

    readonly property var backend: (typeof bloomMedia !== "undefined" && bloomMedia)
                                   ? bloomMedia
                                   : ((typeof musicControl !== "undefined" && musicControl) ? musicControl : null)

    readonly property string title: backend ? backend.trackTitle : ""
    readonly property string artist: backend ? backend.artistName : ""
    readonly property bool playing: backend ? backend.isPlaying : false

    readonly property var defaultPlayer: ({
        identity: "WindowsMedia",
        uniqueId: "win-media-1",
        canControl: true,
        get trackTitle() { return root.title },
        get trackArtist() { return root.artist },
        get isPlaying() { return root.playing },
        get playbackState() { return root.playing ? 1 : 2 },
        metadata: {
            "xesam:title": root.title,
            "xesam:artist": [root.artist]
        },
        play: function() {
            if (!root.backend) return;
            if (typeof root.backend.playPause === "function") root.backend.playPause();
            else if (typeof root.backend.togglePlayPause === "function") root.backend.togglePlayPause();
        },
        pause: function() {
            if (!root.backend) return;
            if (typeof root.backend.playPause === "function") root.backend.playPause();
            else if (typeof root.backend.togglePlayPause === "function") root.backend.togglePlayPause();
        },
        playPause: function() {
            if (!root.backend) return;
            if (typeof root.backend.playPause === "function") root.backend.playPause();
            else if (typeof root.backend.togglePlayPause === "function") root.backend.togglePlayPause();
        },
        next: function() { if (root.backend) root.backend.next(); },
        previous: function() { if (root.backend) root.backend.previous(); }
    })

    readonly property var players: ({
        get values() {
            return [root.defaultPlayer];
        }
    })
}
