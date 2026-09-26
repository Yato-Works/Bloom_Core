pragma Singleton
import QtQuick

// ============================================================================
// Quickshell.Services.Pipewire — Audio Endpoint Bridge for Windows
// Adapts Linux Pipewire sink controls by delegating to Bloom Core's SystemModel.
// ============================================================================
QtObject {
    id: root

    readonly property var backend: (typeof bloomSystem !== "undefined" && bloomSystem)
                                   ? bloomSystem
                                   : ((typeof systemInfo !== "undefined" && systemInfo) ? systemInfo : null)

    readonly property real volume: backend ? (backend.volumeLevel / 100.0) : 0.5
    readonly property bool muted: backend ? backend.volumeMuted : false

    readonly property var defaultAudioSink: ({
        get volume() { return root.volume; },
        get muted() { return root.muted; },
        setVolume: function(v) {
            if (root.backend) {
                root.backend.setVolume(Math.round(Math.max(0, Math.min(1, v)) * 100));
            }
        },
        toggleMute: function() {
            if (root.backend) {
                root.backend.toggleMute();
            }
        }
    })
}
