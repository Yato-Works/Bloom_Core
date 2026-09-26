pragma Singleton
import QtQuick

// Quickshell.Wayland.WlrLayershell bridge
QtObject {
    id: root
    property int exclusionMode: 0
    property int layer: 2
    property int keyboardFocus: 0
    property string namespace: ""
}
