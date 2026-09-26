import QtQuick
import QtQuick.Controls
import Bloom

// ============================================================================
// Bloom.EdgePanel — Linux-style Slide-in Edge Panel & Dock Component
// Supports Top Bar, Bottom Dock, Left Drawer, and Right Control Center
// with automatic Edge Hover reveal, Win+Ctrl Hold-to-Arm reveal, and smooth animations.
// ============================================================================
Item {
    id: root

    // -------------------------------------------------------------
    // Configuration
    // -------------------------------------------------------------
    // "top" | "bottom" | "left" | "right"
    property string edge: "top"
    property int panelThickness: 48
    property int edgeZoneThickness: 12
    property int autoCloseDelay: 280

    property bool opened: false
    property bool pinned: false
    property bool revealOnArm: true
    property bool revealOnEdgeHover: true
    property int slideDuration: 320

    // Content container slot
    default property alias contentData: panelContent.data

    // -------------------------------------------------------------
    // State Tracking
    // -------------------------------------------------------------
    readonly property bool armed: (typeof Core !== "undefined" && Core)
                                  ? Core.armed
                                  : ((typeof shellController !== "undefined" && shellController) ? shellController.armed : false)

    property bool edgeHovered: false
    property bool panelHovered: false
    property bool hoverActive: false

    readonly property bool isRevealed: opened || pinned
                                      || (revealOnArm && armed)
                                      || (revealOnEdgeHover && (edgeHovered || panelHovered || hoverActive))

    function open(): void { root.opened = true; }
    function close(): void { root.opened = false; root.pinned = false; root.hoverActive = false; }
    function toggle(): void { root.opened = !root.opened; }
    function togglePin(): void { root.pinned = !root.pinned; if (root.pinned) root.opened = true; }

    anchors.fill: parent
    z: 50

    // -------------------------------------------------------------
    // Auto-Close Grace Timer
    // -------------------------------------------------------------
    Timer {
        id: graceCloseTimer
        interval: root.autoCloseDelay
        repeat: false
        onTriggered: {
            if (!root.edgeHovered && !root.panelHovered) {
                root.hoverActive = false;
            }
        }
    }

    // -------------------------------------------------------------
    // 1. Edge Trigger Zone (Hover Strip at the very edge of screen)
    // -------------------------------------------------------------
    MouseArea {
        id: edgeStrip
        z: 100
        hoverEnabled: root.revealOnEdgeHover
        acceptedButtons: Qt.NoButton

        x: (root.edge === "right") ? (parent.width - root.edgeZoneThickness) : 0
        y: (root.edge === "bottom") ? (parent.height - root.edgeZoneThickness) : 0
        width: (root.edge === "left" || root.edge === "right") ? root.edgeZoneThickness : parent.width
        height: (root.edge === "top" || root.edge === "bottom") ? root.edgeZoneThickness : parent.height

        onEntered: {
            graceCloseTimer.stop();
            root.edgeHovered = true;
            root.hoverActive = true;
        }
        onExited: {
            root.edgeHovered = false;
            if (!root.panelHovered) {
                graceCloseTimer.restart();
            }
        }
    }

    // -------------------------------------------------------------
    // 2. Sliding Panel Surface
    // -------------------------------------------------------------
    Item {
        id: panelSurface
        z: 90

        // Fixed dimension based on edge
        width: (root.edge === "left" || root.edge === "right") ? root.panelThickness : parent.width
        height: (root.edge === "top" || root.edge === "bottom") ? root.panelThickness : parent.height

        // Slide coordinates calculation
        property real targetX: {
            if (root.edge === "left") {
                return root.isRevealed ? 0 : -root.panelThickness;
            } else if (root.edge === "right") {
                return root.isRevealed ? (parent.width - root.panelThickness) : parent.width;
            } else {
                return 0;
            }
        }

        property real targetY: {
            if (root.edge === "top") {
                return root.isRevealed ? 0 : -root.panelThickness;
            } else if (root.edge === "bottom") {
                return root.isRevealed ? (parent.height - root.panelThickness) : parent.height;
            } else {
                return 0;
            }
        }

        x: targetX
        y: targetY

        Behavior on x {
            NumberAnimation {
                duration: root.slideDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: root.slideDuration
                easing.type: Easing.OutCubic
            }
        }

        // Detect hover over the active panel body
        MouseArea {
            id: panelBodyHover
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: {
                graceCloseTimer.stop();
                root.panelHovered = true;
                root.hoverActive = true;
            }
            onExited: {
                root.panelHovered = false;
                if (!root.edgeHovered) {
                    graceCloseTimer.restart();
                }
            }
        }

        // Inner item holding children
        Item {
            id: panelContent
            anchors.fill: parent
        }
    }
}
