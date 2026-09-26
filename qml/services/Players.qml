pragma Singleton
import QtQuick

QtObject {
    id: root
    readonly property var backend: (typeof bloomMedia !== "undefined" && bloomMedia) ? bloomMedia : ((typeof musicControl !== "undefined" && musicControl) ? musicControl : null)
    readonly property string trackTitle: backend ? backend.trackTitle : ""
    readonly property string artistName: backend ? backend.artistName : ""
    readonly property bool isPlaying: backend ? backend.isPlaying : false
    function togglePlayPause() {
        if (!backend) return;
        if (typeof backend.playPause === "function") backend.playPause();
        else if (typeof backend.togglePlayPause === "function") backend.togglePlayPause();
    }
    function next() { if (backend) backend.next(); }
    function previous() { if (backend) backend.previous(); }
}
