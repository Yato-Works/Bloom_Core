import QtQuick
import QtQuick.Controls
import Bloom

Item {
    id: root

    property int value: 50           // 0 to 100
    property string icon: "🔊"
    property color activeColor: Colours.m3primary
    property bool muted: false

    signal valueModified(int newVal)
    signal iconClicked()

    readonly property string fontDisplay: "Rubik"

    width: 38
    height: 140

    Rectangle {
        id: track
        anchors.fill: parent
        radius: 19
        color: Colours.m3surfaceContainerHighest
        border.width: 1
        border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)
        clip: true

        // Vertical fill from bottom up
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.max(0, parent.height * (root.muted ? 0 : root.value) / 100.0)
            radius: 19
            color: root.muted ? Colours.m3outline : root.activeColor
            Behavior on height { NumberAnimation { duration: 90 } }
        }

        // Rounded handle pill riding the fill edge (reference-style slider)
        Rectangle {
            visible: !root.muted
            anchors.horizontalCenter: parent.horizontalCenter
            width: 26
            height: 26
            radius: 13
            color: root.activeColor
            border.width: 2
            border.color: track.color
            y: {
                const fill = track.height * (root.muted ? 0 : root.value) / 100.0;
                return Math.max(4, Math.min(track.height - 30, track.height - fill - 26));
            }
            Behavior on y { NumberAnimation { duration: 90 } }
        }

        // Top/Bottom Icon
        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 6
            width: 26
            height: 26
            radius: 13
            color: Colours.m3surface

            Text {
                anchors.centerIn: parent
                text: root.icon
                font.pixelSize: 13
            }

            TapHandler { onTapped: root.iconClicked() }
        }

        // Percentage text at bottom
        Text {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 8
            text: root.muted ? "MUTE" : (root.value + "%")
            color: Colours.m3onSurface
            font.family: root.fontDisplay
            font.pixelSize: 9
            font.weight: Font.Bold
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => {
                const fraction = 1.0 - (mouse.y / track.height);
                root.valueModified(Math.max(0, Math.min(100, Math.round(fraction * 100))));
            }
            onPositionChanged: mouse => {
                if (pressed) {
                    const fraction = 1.0 - (mouse.y / track.height);
                    root.valueModified(Math.max(0, Math.min(100, Math.round(fraction * 100))));
                }
            }
            onWheel: wheel => {
                const step = wheel.angleDelta.y > 0 ? 5 : -5;
                root.valueModified(Math.max(0, Math.min(100, root.value + step)));
            }
        }
    }
}
