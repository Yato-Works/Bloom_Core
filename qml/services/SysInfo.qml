pragma Singleton
import QtQuick

QtObject {
    id: root
    readonly property var backend: (typeof bloomSystem !== "undefined" && bloomSystem) ? bloomSystem : ((typeof systemInfo !== "undefined" && systemInfo) ? systemInfo : null)
    readonly property int cpuUsage: backend ? backend.cpuUsage : 0
    readonly property int memoryUsage: backend ? backend.memoryUsage : 0
    readonly property string memorySummary: backend ? backend.memorySummary : ""
    readonly property bool hasBattery: backend ? backend.hasBattery : false
    readonly property int batteryPercent: backend ? backend.batteryPercent : 100
    readonly property bool batteryCharging: backend ? backend.batteryCharging : false
    readonly property string formattedTime: (backend && backend.formattedTime) ? backend.formattedTime : ""
    readonly property string formattedDate: (backend && backend.formattedDate) ? backend.formattedDate : ""
    readonly property string hostName: backend ? backend.hostName : "Desktop"
    readonly property string uptime: backend ? backend.uptime : ""
    readonly property int volumeLevel: backend ? backend.volumeLevel : 50
    readonly property bool volumeMuted: backend ? backend.volumeMuted : false
    function setVolume(v) { if (backend) backend.setVolume(v); }
    function toggleMute() { if (backend) backend.toggleMute(); }
}
