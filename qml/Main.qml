import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

// Unified Bloom shell — a single Caelestia-style UI driven by the dynamic
// wallpaper palette. Hold Ctrl+Win to arm, hover the screen edges to reveal.
ApplicationWindow {
    id: shell
    title: "Bloom"
    color: "transparent"
    visible: false
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool

    function openSettings() { settingsModal.open() }

    Item {
        anchors.fill: parent

        // Subtle click-absorbing scrim while armed.
        Rectangle {
            id: dim
            anchors.fill: parent
            color: "transparent"
            opacity: shellController.armed ? shellController.dimOpacity : 0
            Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onPressed: function(mouse) { mouse.accepted = true }
                onClicked: function(mouse) { mouse.accepted = true }
                onWheel: function(wheel) { wheel.accepted = true }
            }
        }

        // The shell (dashboard tabs / media / performance / weather, left dock,
        // right drawer, desktop clock & spectrum).
        CaelestiaShell {
            anchors.fill: parent
            z: 40
            visible: shellController.armed
        }

        SettingsModal {
            id: settingsModal
            anchors.fill: parent
        }

        Connections {
            target: appLauncherService
            function onThemeSettingsRequested() { settingsModal.open() }
            function onSettingsRequested() { settingsModal.open() }
        }
    }
}