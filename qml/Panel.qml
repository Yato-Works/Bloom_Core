import QtQuick
import QtQuick.Window

Window {
    id: root
    visible: true
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"

    property string anchorEdge: "top"
    property int panelThickness: 48
    property int exclusiveZone: panelThickness

    x: 0
    y: (anchorEdge === "bottom") ? (Screen.height - height) : 0
    width: (anchorEdge === "top" || anchorEdge === "bottom") ? Screen.width : panelThickness
    height: (anchorEdge === "top" || anchorEdge === "bottom") ? panelThickness : Screen.height
}
