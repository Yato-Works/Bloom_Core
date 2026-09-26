pragma Singleton
import QtQuick

// ============================================================================
// Quickshell — Windows Compatibility Bridge Singleton
// Emulates the root Quickshell engine interface for QML files ported from Linux.
// ============================================================================
QtObject {
    id: root

    readonly property string version: "0.1.0-bloom-win"
    readonly property string platform: "windows"

    // Quickshell.env("VAR_NAME")
    function env(name: string): string {
        if (!name) return ""
        if (typeof config !== "undefined" && config) {
            // Check if config exposes env helper
        }
        return ""
    }

    // Screens interface
    readonly property var screens: {
        return [
            {
                name: "PrimaryDisplay",
                x: 0,
                y: 0,
                width: Screen.width,
                height: Screen.height,
                scale: Screen.devicePixelRatio
            }
        ]
    }
}
