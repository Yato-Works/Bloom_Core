import QtQuick
import QtQuick.Window

Window {
    id: root
    visible: true
    flags: Qt.FramelessWindowHint | Qt.Window
    color: "transparent"

    property bool focusable: true
    property bool exclusive: false
}
