import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root

    readonly property string fontDisplay: "Rubik"

    function fmtTime(sec: int): string {
        if (sec <= 0) return "0:00";
        const m = Math.floor(sec / 60);
        const s = sec % 60;
        return `${m}:${s.toString().padStart(2, "0")}`;
    }

    implicitWidth: 880
    implicitHeight: 560

    RowLayout {
        anchors.fill: parent
        spacing: 20

        // Left Panel: Big Cover Art + Glow + Bongo Cat
        Rectangle {
            Layout.preferredWidth: 360
            Layout.fillHeight: true
            radius: 30
            color: Colours.m3surfaceContainerLow
            border.width: 1
            border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                // Hero Circular Cover Art
                Item {
                    Layout.alignment: Qt.AlignHCenter
                    width: 200
                    height: 200

                    CircularProgress {
                        anchors.fill: parent
                        strokeWidth: 7
                        fgColour: Colours.m3primary
                        bgColour: Colours.m3surfaceContainerHighest
                        value: musicControl.length > 0 ? (musicControl.position / musicControl.length) : 0.0
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 170
                        height: 170
                        radius: 85
                        gradient: Gradient {
                            GradientStop { position: 0; color: Colours.m3primaryContainer }
                            GradientStop { position: 1; color: Colours.m3tertiaryContainer }
                        }
                        border.width: 1
                        border.color: Qt.alpha(Colours.m3outlineVariant, 0.3)

                        Text {
                            anchors.centerIn: parent
                            text: "♫"
                            font.pixelSize: 64
                            color: Colours.m3onPrimaryContainer
                        }
                    }
                }

                // Track details
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        Layout.fillWidth: true
                        text: musicControl.trackTitle === "" ? qsTr("No active media session") : musicControl.trackTitle
                        color: Colours.m3onSurface
                        font.family: root.fontDisplay
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: musicControl.artistName === "" ? qsTr("Play music to visualize") : musicControl.artistName
                        color: Colours.m3onSurfaceVariant
                        font.family: root.fontDisplay
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                    Text {
                        visible: musicControl.sourceApp !== ""
                        Layout.fillWidth: true
                        text: "via " + musicControl.sourceApp
                        color: Colours.m3primary
                        font.family: root.fontDisplay
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Item { Layout.fillHeight: true }

                // Bongo Cat Animated GIF
                AnimatedImage {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 65
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/qt/qml/Bloom/assets/bongocat.gif"
                    playing: musicControl.isPlaying
                    paused: !musicControl.isPlaying
                }
            }
        }

        // Right Panel: Playback Controls, Progress, Volume & CAVA Spectrum
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 30
            color: Colours.m3surfaceContainerLow
            border.width: 1
            border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 20

                // Top Status Header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: qsTr("Now Playing")
                        color: Colours.m3primary
                        font.family: root.fontDisplay
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: musicControl.isPlaying ? qsTr("Playing") : qsTr("Paused")
                        color: Colours.m3onSurfaceVariant
                        font.family: root.fontDisplay
                        font.pixelSize: 12
                    }
                }

                // CAVA Audio Visualizer Bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    radius: 20
                    color: Colours.m3surfaceContainerHighest
                    clip: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 4

                        Repeater {
                            model: cavaService.bars
                            Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: Math.max(6, modelData * 90)
                                Layout.alignment: Qt.AlignBottom
                                radius: 3
                                color: Qt.alpha(Colours.m3primary, 0.5 + modelData * 0.5)
                            }
                        }
                    }
                }

                // Seekable Progress Bar
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        id: progTrack
                        Layout.fillWidth: true
                        height: 8
                        radius: 4
                        color: Colours.m3surfaceContainerHighest

                        Rectangle {
                            width: musicControl.length > 0
                                ? parent.width * Math.min(1.0, musicControl.position / musicControl.length)
                                : 0
                            height: parent.height
                            radius: 4
                            color: Colours.m3primary
                            Behavior on width { NumberAnimation { duration: 150 } }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: root.fmtTime(musicControl.position)
                            color: Colours.m3onSurfaceVariant
                            font.family: root.fontDisplay
                            font.pixelSize: 11
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.fmtTime(musicControl.length)
                            color: Colours.m3onSurfaceVariant
                            font.family: root.fontDisplay
                            font.pixelSize: 11
                        }
                    }
                }

                // Main Playback Controls
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 24

                    // Shuffle toggle
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: musicControl.shuffle ? Qt.alpha(Colours.m3primary, 0.25) : "transparent"
                        HoverHandler { id: shufHover }
                        TapHandler { onTapped: musicControl.shuffle = !musicControl.shuffle }
                        Text {
                            anchors.centerIn: parent
                            text: "🔀"
                            color: musicControl.shuffle ? Colours.m3primary : Colours.m3onSurfaceVariant
                            font.pixelSize: 16
                        }
                    }

                    // Previous
                    Rectangle {
                        width: 44; height: 44; radius: 22
                        color: prevBtnHover.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.15) : "transparent"
                        HoverHandler { id: prevBtnHover }
                        TapHandler { onTapped: musicControl.previous() }
                        Text {
                            anchors.centerIn: parent
                            text: "⏮"
                            color: Colours.m3onSurface
                            font.pixelSize: 18
                        }
                    }

                    // Play/Pause Hero Button
                    Rectangle {
                        width: 56; height: 56; radius: 28
                        color: Colours.m3primary
                        HoverHandler { id: playBtnHover }
                        scale: playBtnHover.hovered ? 1.08 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120 } }
                        TapHandler { onTapped: musicControl.playPause() }
                        Text {
                            anchors.centerIn: parent
                            text: musicControl.isPlaying ? "⏸" : "▶"
                            color: Colours.m3onPrimary
                            font.pixelSize: 22
                        }
                    }

                    // Next
                    Rectangle {
                        width: 44; height: 44; radius: 22
                        color: nextBtnHover.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.15) : "transparent"
                        HoverHandler { id: nextBtnHover }
                        TapHandler { onTapped: musicControl.next() }
                        Text {
                            anchors.centerIn: parent
                            text: "⏭"
                            color: Colours.m3onSurface
                            font.pixelSize: 18
                        }
                    }

                    // Repeat toggle
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: musicControl.loopState > 0 ? Qt.alpha(Colours.m3primary, 0.25) : "transparent"
                        HoverHandler { id: repHover }
                        TapHandler {
                            onTapped: {
                                musicControl.loopState = (musicControl.loopState + 1) % 3;
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: musicControl.loopState === 1 ? "🔂" : "🔁"
                            color: musicControl.loopState > 0 ? Colours.m3primary : Colours.m3onSurfaceVariant
                            font.pixelSize: 16
                        }
                    }
                }

                // Volume Bar
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text: systemInfo.volumeMuted ? "🔇" : "🔊"
                        font.pixelSize: 14
                        TapHandler { onTapped: systemInfo.toggleMute() }
                    }

                    Rectangle {
                        id: volTrack
                        Layout.fillWidth: true
                        height: 20
                        radius: 10
                        color: Colours.m3surfaceContainerHighest

                        Rectangle {
                            x: 2; y: 2
                            width: Math.max(0, (parent.width - 4) * systemInfo.volumeLevel / 100)
                            height: parent.height - 4
                            radius: 8
                            color: systemInfo.volumeMuted ? Colours.m3outline : Colours.m3primary
                            Behavior on width { NumberAnimation { duration: 90 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: mouse => systemInfo.setVolume(Math.max(0, Math.min(100, mouse.x / parent.width * 100)))
                            onPositionChanged: mouse => {
                                if (pressed)
                                    systemInfo.setVolume(Math.max(0, Math.min(100, mouse.x / parent.width * 100)));
                            }
                        }
                    }

                    Text {
                        text: systemInfo.volumeLevel + "%"
                        color: Colours.m3onSurfaceVariant
                        font.family: root.fontDisplay
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}
