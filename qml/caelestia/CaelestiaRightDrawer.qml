import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root

    property bool open: false
    readonly property string fontDisplay: "Rubik"

    signal requestOpenSettings()

    property bool keepAwakeEnabled: false
    property bool wifiEnabled: true
    property bool bluetoothEnabled: true
    property bool micMuted: false
    property bool nightLightEnabled: false

    width: 410
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    // Floating vertical sliders on the left of drawer
    ColumnLayout {
        anchors.right: drawerPanel.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12
        visible: root.open

        // Volume Vertical Slider
        VerticalSlider {
            value: systemInfo.volumeLevel
            icon: systemInfo.volumeMuted ? "🔇" : "🔊"
            muted: systemInfo.volumeMuted
            activeColor: Colours.m3primary
            onValueModified: newVal => systemInfo.setVolume(newVal)
            onIconClicked: systemInfo.toggleMute()
        }

        // Brightness Vertical Slider
        VerticalSlider {
            value: 80
            icon: "☀️"
            activeColor: Colours.m3secondary
            onValueModified: newVal => {}
        }
    }

    // Main Drawer Surface
    Rectangle {
        id: drawerPanel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 350
        radius: 0
        color: Colours.m3surfaceContainerLowest
        border.width: 1
        border.color: Qt.alpha(Colours.m3outlineVariant, 0.3)

        // Slide Animation — butter-smooth Caelestia bezier with a soft fade
        transform: Translate {
            x: root.open ? 0 : drawerPanel.width + 10
            Behavior on x {
                NumberAnimation {
                    duration: root.open ? 420 : 320
                    easing.type: Easing.Bezier
                    easing.bezierCurve: root.open ? [0.30, 1.22, 0.28, 1, 1, 1]
                                                  : [0.40, 0, 0.20, 1, 1, 1]
                }
            }
        }
        opacity: root.open ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: root.open ? 260 : 200; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // 1. Notifications Panel (with Dino!)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 24
                color: Colours.m3surfaceContainerLow
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: qsTr("Notifications")
                            color: Colours.m3onSurface
                            font.family: root.fontDisplay
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: qsTr("Clear")
                            color: Colours.m3primary
                            font.family: root.fontDisplay
                            font.pixelSize: 11
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Dino Graphic & Empty State
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 64
                            Layout.preferredHeight: 64
                            fillMode: Image.PreserveAspectFit
                            source: "qrc:/qt/qml/Bloom/assets/dino.png"
                            opacity: 0.75
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("No Notifications")
                            color: Colours.m3onSurfaceVariant
                            font.family: root.fontDisplay
                            font.pixelSize: 13
                            font.letterSpacing: 0.4
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // 2. Keep Awake Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 62
                radius: 18
                color: Colours.m3surfaceContainerLow
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    Rectangle {
                        width: 36; height: 36; radius: 18
                        color: root.keepAwakeEnabled ? Qt.alpha(Colours.m3primary, 0.25) : Colours.m3surfaceContainerHighest
                        Text { anchors.centerIn: parent; text: "☕"; font.pixelSize: 16 }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            text: qsTr("Keep Awake")
                            color: Colours.m3onSurface
                            font.family: root.fontDisplay
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                        Text {
                            text: root.keepAwakeEnabled ? qsTr("Preventing sleep mode") : qsTr("Normal power management")
                            color: Colours.m3onSurfaceVariant
                            font.family: root.fontDisplay
                            font.pixelSize: 10
                        }
                    }

                    // Switch Pill
                    Rectangle {
                        width: 40
                        height: 22
                        radius: 11
                        color: root.keepAwakeEnabled ? Colours.m3primary : Colours.m3surfaceContainerHighest

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: root.keepAwakeEnabled ? parent.width - width - 2 : 2
                            width: 18
                            height: 18
                            radius: 9
                            color: root.keepAwakeEnabled ? Colours.m3onPrimary : Colours.m3outline
                            Behavior on x { NumberAnimation { duration: 150 } }
                        }

                        TapHandler { onTapped: root.keepAwakeEnabled = !root.keepAwakeEnabled }
                    }
                }
            }

            // 3. Screen Recorder Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 74
                radius: 18
                color: Colours.m3surfaceContainerLow
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            width: 30; height: 30; radius: 15
                            color: Qt.alpha(Colours.m3secondaryContainer, 0.7)
                            Text { anchors.centerIn: parent; text: "🎥"; font.pixelSize: 13 }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                text: qsTr("Screen Recorder")
                                color: Colours.m3onSurface
                                font.family: root.fontDisplay
                                font.pixelSize: 11
                                font.weight: Font.Medium
                            }
                            Text {
                                text: qsTr("Recording standby")
                                color: Colours.m3onSurfaceVariant
                                font.family: root.fontDisplay
                                font.pixelSize: 9
                            }
                        }

                        Rectangle {
                            height: 24
                            radius: 12
                            color: Colours.m3secondaryContainer
                            implicitWidth: recText.implicitWidth + 16

                            Text {
                                id: recText
                                anchors.centerIn: parent
                                text: "⛶ Fullscreen"
                                color: Colours.m3onSecondaryContainer
                                font.family: root.fontDisplay
                                font.pixelSize: 10
                                font.weight: Font.Medium
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "📁"; font.pixelSize: 10 }
                        Text {
                            text: qsTr("No recordings found in gallery")
                            color: Qt.alpha(Colours.m3onSurfaceVariant, 0.7)
                            font.family: root.fontDisplay
                            font.pixelSize: 9
                        }
                    }
                }
            }

            // 4. Quick Toggles Bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                radius: 20
                color: Colours.m3surfaceContainerLow
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 6

                    // WiFi
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 14
                        color: root.wifiEnabled ? Colours.m3secondaryContainer : Colours.m3surfaceContainerHighest
                        HoverHandler { id: wHover }
                        TapHandler { onTapped: root.wifiEnabled = !root.wifiEnabled }
                        Text {
                            anchors.centerIn: parent
                            text: "📶"
                            font.pixelSize: 13
                        }
                    }

                    // Bluetooth
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 14
                        color: root.bluetoothEnabled ? Colours.m3secondaryContainer : Colours.m3surfaceContainerHighest
                        HoverHandler { id: btHover }
                        TapHandler { onTapped: root.bluetoothEnabled = !root.bluetoothEnabled }
                        Text {
                            anchors.centerIn: parent
                            text: "ᛒ"
                            color: root.bluetoothEnabled ? Colours.m3onSecondaryContainer : Colours.m3onSurfaceVariant
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }
                    }

                    // Mic
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 14
                        color: !root.micMuted ? Colours.m3secondaryContainer : Colours.m3surfaceContainerHighest
                        HoverHandler { id: micHover }
                        TapHandler { onTapped: root.micMuted = !root.micMuted }
                        Text {
                            anchors.centerIn: parent
                            text: root.micMuted ? "🎙️❌" : "🎙️"
                            font.pixelSize: 13
                        }
                    }

                    // Settings
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 14
                        color: Colours.m3surfaceContainerHighest
                        HoverHandler { id: setHover }
                        TapHandler { onTapped: root.requestOpenSettings() }
                        Text {
                            anchors.centerIn: parent
                            text: "⚙"
                            color: Colours.m3onSurfaceVariant
                            font.pixelSize: 14
                        }
                    }

                    // Night Light
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 14
                        color: root.nightLightEnabled ? Colours.m3secondaryContainer : Colours.m3surfaceContainerHighest
                        HoverHandler { id: nlHover }
                        TapHandler { onTapped: root.nightLightEnabled = !root.nightLightEnabled }
                        Text {
                            anchors.centerIn: parent
                            text: "🌙"
                            font.pixelSize: 13
                        }
                    }

                    // Mute
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 14
                        color: systemInfo.volumeMuted ? Qt.alpha(Colours.m3error, 0.3) : Colours.m3surfaceContainerHighest
                        HoverHandler { id: mutHover }
                        TapHandler { onTapped: systemInfo.toggleMute() }
                        Text {
                            anchors.centerIn: parent
                            text: systemInfo.volumeMuted ? "🔇" : "🔊"
                            font.pixelSize: 13
                        }
                    }
                }
            }
        }
    }
}
