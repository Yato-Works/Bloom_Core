import QtQuick
import QtQuick.Controls

// ============================================================================
// PanelWindow — Quickshell Wayland Layer Shell Shim for Windows
// Maps Linux PanelWindow to Windows Frameless Top-Level Window
// ============================================================================
ApplicationWindow {
    id: win

    title: win.name !== "" ? win.name : "Bloom Panel"
    color: "transparent"
    visible: true
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool

    property var screen: null
    property string name: ""

    property LayershellConfig WlrLayershell: LayershellConfig {}

    property var surfaceFormat: ({
        opaque: false
    })

    // Content container
    default property alias contentData: contentHolder.data

    Item {
        id: contentHolder
        anchors.fill: parent

        // Expose attached mock properties if queried by children
        property var Config: ({
            screen: win.screen ? win.screen.name : "PrimaryDisplay",
            background: { wallpaperEnabled: true },
            border: { thickness: 1, rounding: 12 },
            dashboard: { enabled: true, dragThreshold: 10 },
            launcher: { enabled: true, dragThreshold: 10 },
            session: { enabled: true, dragThreshold: 10 },
            sidebar: { enabled: true, dragThreshold: 10 }
        })
        property var Tokens: ({
            screen: win.screen ? win.screen.name : "PrimaryDisplay"
        })
    }
}
