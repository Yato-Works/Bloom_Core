import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Caelestia

// ============================================================================
// Arch Linux / Hyprland Sample Shell — ported directly to Windows with Bloom Core
// Note: This file uses ONLY Linux Arch / Quickshell imports & components!
// ============================================================================
PanelWindow {
    id: archWindow
    name: "caelestia-arch-sample"
    color: "transparent"

    // Wayland Layer Shell properties (bridged transparently on Windows)
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Normal

    width: Screen.width
    height: 64

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        radius: 18
        color: Colours.m3surfaceContainerLow
        border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 16

            Row {
                spacing: 8
                Layout.alignment: Qt.AlignVCenter
                Text { text: "🐧"; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: "Arch Linux QML Bridge"
                    color: Colours.m3primary
                    font.pixelSize: 13
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle { width: 1; height: 22; color: Qt.alpha(Colours.m3outlineVariant, 0.3); Layout.alignment: Qt.AlignVCenter }

            // Hyprland Workspaces (1..5)
            Row {
                spacing: 6
                Layout.alignment: Qt.AlignVCenter
                Repeater {
                    model: Hyprland.workspaces.values
                    delegate: Rectangle {
                        required property var modelData
                        readonly property bool active: modelData.id === Hyprland.activeWsId
                        width: 26; height: 26; radius: 13
                        color: active ? Colours.m3primary : "transparent"
                        border.color: Colours.m3primary
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: modelData.name
                            color: active ? Colours.m3onPrimary : Colours.m3primary
                            font.pixelSize: 11
                            font.bold: active
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Hyprland.dispatch("workspace " + modelData.id)
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Pipewire Audio Volume Bridge
            Row {
                spacing: 6
                Layout.alignment: Qt.AlignVCenter
                Text { text: "🔊"; font.pixelSize: 12 }
                Text {
                    text: Math.round(Pipewire.defaultAudioSink.volume * 100) + "%"
                    color: Colours.m3secondary
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            Rectangle { width: 1; height: 22; color: Qt.alpha(Colours.m3outlineVariant, 0.3); Layout.alignment: Qt.AlignVCenter }

            // MPRIS Media Player Bridge
            Row {
                spacing: 8
                Layout.alignment: Qt.AlignVCenter
                readonly property var player: Mpris.players.values[0]

                Text {
                    text: player && player.isPlaying ? "▶" : "⏸"
                    color: Colours.m3primary
                    font.pixelSize: 11
                }
                Text {
                    text: (player && player.trackTitle !== "")
                          ? player.trackTitle + (player.trackArtist !== "" ? " - " + player.trackArtist : "")
                          : "No Media"
                    color: Colours.m3onSurface
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    width: 160
                }
            }
        }
    }
}
