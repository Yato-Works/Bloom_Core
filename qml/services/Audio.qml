pragma Singleton
import QtQuick

QtObject {
    id: root
    readonly property var backend: (typeof bloomAudio !== "undefined" && bloomAudio) ? bloomAudio : ((typeof cavaService !== "undefined" && cavaService) ? cavaService : null)
    readonly property var bars: (backend && backend.bars) ? backend.bars : []
    readonly property bool active: backend ? backend.active : false
    readonly property bool hasAudio: backend ? (backend.hasAudio !== undefined ? backend.hasAudio : true) : false
}
