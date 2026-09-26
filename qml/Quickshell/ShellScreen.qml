import QtQuick

QtObject {
    id: screenObj
    property string name: "PrimaryDisplay"
    property int x: 0
    property int y: 0
    property int width: Screen.width
    property int height: Screen.height
    property real scale: Screen.devicePixelRatio
}
