import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: popup
    color: "transparent"
    visible: false
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Popup
    default property alias contentData: popupHolder.data
    Item {
        id: popupHolder
        anchors.fill: parent
    }
}
