import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Bloom

Item {
    id: root

        readonly property string fontDisplay: "Rubik"

    // --- Redesigned shell surface state -----------------------------------
    property bool barOpen: false            // top bar currently revealed (edge hover / armed / pinned)
    property bool panelOpen: false          // detail panel is hovering-open
    property bool panelPinned: false        // panel held open by user pin
    readonly property bool panelExpanded: panelOpen || panelPinned  // panel visible
    property bool dashboardOpen: false      // legacy alias (kept to avoid breaking external refs)
    property bool rightDrawerOpen: false
    property int activeWorkspace: (typeof workspaceController !== "undefined" && workspaceController)
                                  ? workspaceController.currentWorkspace : 1
    property string wallSrc: ""
    property real lastKeepTime: 0           // hover-grace bookkeeping
    readonly property bool windowAppeared: shellController.armed

    function toggleDashboardPinned(): void {
        // Repurposed: toggles the detail panel pin (and bar/panel reveal).
        if (root.panelPinned) {
            root.panelPinned = false;
            root.panelOpen  = false;
            root.barOpen    = false;
        } else {
            root.barOpen    = true;
            root.panelOpen  = true;
            root.panelPinned = true;
        }
    }

    function noteKeepAlive(): void { root.lastKeepTime = Date.now(); }

    onBarOpenChanged:       root.armHost()
    onPanelExpandedChanged: root.armHost()

    // Keep the host window alive while any chrome is open, then mirror back the
    // chord-re-press disarm so the panel never lingers on a hidden window.
    function armHost(): void {
        shellController.forceArmed = root.barOpen || root.panelExpanded;
    }
    Connections {
        target: shellController
        function onForceArmedChanged(): void {
            if (!shellController.forceArmed && root.panelExpanded) {
                root.panelPinned = false; root.panelOpen = false; root.barOpen = false;
            }
        }
    }

    function updateWallSrc(): void {
        try {
            const paths = wallpaperService.wallpaperPaths();
            const idx = wallpaperService.currentIndex();
            root.wallSrc = (paths && idx >= 0 && idx < paths.length) ? String(paths[idx]) : "";
        } catch (e) {
            root.wallSrc = "";
        }
    }

    function spectrumValue(index: int, count: int): real {
        if (!cavaService || !cavaService.bars || cavaService.bars.length === 0)
            return 0.0;
        const sourceIndex = Math.min(cavaService.bars.length - 1,
                                     Math.floor(index * cavaService.bars.length / count));
        return Number(cavaService.bars[sourceIndex]);
    }

    Component.onCompleted: updateWallSrc()

    Connections {
        target: wallpaperService
        function onCurrentWallpaperChanged(): void { root.updateWallSrc(); }
    }

    Shortcut {
        sequence: "Esc"
        enabled: root.barOpen || root.panelExpanded || root.rightDrawerOpen
        onActivated: {
            root.panelPinned = false;
            root.panelOpen  = false;
            root.barOpen    = false;
            root.rightDrawerOpen = false;
        }
    }



    
        // Seamless hover close: when the surface was revealed by hovering (not
    // pinned), collapse the panel / bar once the cursor leaves everything.
    Timer {
        id: hoverCloseTimer
        interval: 260
        repeat: true
        running: root.barOpen && !root.panelPinned
        onTriggered: {
            if (!topEdgeZone.containsMouse && !bloomBar.hovered
                && !controlPanel.hovered && (Date.now() - root.lastKeepTime) > 320) {
                root.panelOpen = false;
                if (!root.panelPinned)
                    root.barOpen = false;
            }
        }
    }

    // Top edge reveal zone — the bar slides in on hover, no click needed.
    // A thin but discoverable strip at the very top of the screen.
    MouseArea {
        id: topEdgeZone
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 14
        z: 70
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onEntered: { root.barOpen = true; root.noteKeepAlive(); }
        onContainsMouseChanged: root.noteKeepAlive()
    }


    // ------------------------------------------------------------- 1. Left Dock
    CaelestiaLeftDock {
        id: leftDock
        activeWorkspace: root.activeWorkspace
        z: 25
        onRequestOpenDashboard: root.toggleDashboardPinned()
        onRequestToggleLock: shellController.toggleLock()
        onRequestOpenSettings: {
            if (typeof shell !== "undefined" && shell.openSettings)
                shell.openSettings();
        }

        transform: Translate {
            x: root.windowAppeared ? 0 : -74
            Behavior on x {
                NumberAnimation {
                    duration: 520
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.30, 1.22, 0.28, 1, 1, 1]
                }
            }
        }
    }

    // ------------------------------------------------------------- 2. Top Bar + Slide-down Control Panel
    // New chrome: a slim status bar anchored to the top edge, revealed by a
    // single-pixel-ish hover strip. Detail cards slide down beneath it.
    Item {
        id: topSurface
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        width: parent.width
        height: bloomBar.height + (root.panelExpanded ? controlPanel.height : 0)
        z: 30
        clip: false

        // ---- status bar itself ----
        BloomTopBar {
            id: bloomBar
            anchors.left: parent.left
            anchors.right: parent.right
            panelOpen: root.panelOpen
            pinned: root.panelPinned
            armed: root.barOpen && root.windowAppeared
            onHoveredChanged: {
                if (bloomBar.hovered && root.barOpen)
                    root.panelOpen = true
            }
            onTogglePin: root.toggleDashboardPinned()
            onTogglePanel: root.panelOpen = !root.panelOpen
            onOpenSettings: root.rightDrawerOpen = true
        }

        // ---- detail panel below the bar ----
        BloomControlPanel {
            id: controlPanel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: bloomBar.bottom
            open: root.panelExpanded
            wallSrc: root.wallSrc
        }

        // Slide the whole stack in/out from the top edge — butter-smooth drop
        // using Caelestia's M3 emphasized bezier with a whisper of overshoot.
        transform: Translate {
            id: topSurfaceMove
            y: root.barOpen ? 0 : -(bloomBar.height + controlPanel.height + 10)
            Behavior on y {
                NumberAnimation {
                    duration: root.barOpen ? 480 : 340
                    easing.type: Easing.Bezier
                    easing.bezierCurve: root.barOpen ? [0.30, 1.22, 0.28, 1, 1, 1]
                                                     : [0.40, 0, 0.20, 1, 1, 1]
                }
            }
        }
        opacity: root.barOpen ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: root.barOpen ? 280 : 200
                easing.type: Easing.OutCubic
            }
        }
    }

    // ------------------------------------------------------------- 3. Desktop Background Elements
    // Big Minimalist Clock in Center
    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -30
        spacing: 10
        opacity: root.dashboardOpen ? 0 : 0.92
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: systemInfo.formattedTime
            color: Qt.alpha(Colours.m3onSurface, 0.92)
            font.family: root.fontDisplay
            font.pixelSize: 128
            font.weight: Font.Thin
            font.letterSpacing: 4
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: systemInfo.formattedDate
            color: Qt.alpha(Colours.m3onSurfaceVariant, 0.75)
            font.family: root.fontDisplay
            font.pixelSize: 15
            font.letterSpacing: 4
        }
    }

    // Bottom spectrum — dense mirrored capsules with a breathing gap at the
    // centre; echoes the cover-art visualiser on a wallpaper scale.
    Item {
        id: spectrum
        anchors.left: leftDock.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 28
        anchors.rightMargin: 34
        anchors.bottomMargin: 22
        height: 118
        readonly property int barCount: 96
        readonly property int centerGap: 12
        readonly property real slotW: width / barCount
        readonly property int gapStart: (barCount - centerGap) / 2
        opacity: root.dashboardOpen ? 0.14 : 0.85
        Behavior on opacity { NumberAnimation { duration: 200 } }

        transform: Translate {
            y: root.windowAppeared ? 0 : 46
            Behavior on y { NumberAnimation { duration: 380; easing.type: Easing.OutCubic } }
        }

        // Mirror the right half onto the left for a symmetric "wings" layout.
        function bandForSlot(slot: int): int {
            return slot < barCount / 2 ? slot : barCount - 1 - slot;
        }

        Repeater {
            model: spectrum.barCount
            Rectangle {
                required property int index
                readonly property bool inGap: index >= spectrum.gapStart
                                               && index < spectrum.gapStart + spectrum.centerGap
                readonly property real level: inGap ? 0
                    : root.spectrumValue(spectrum.bandForSlot(index), spectrum.barCount)
                visible: !inGap
                width: Math.max(3, Math.min(7, spectrum.slotW * 0.40))
                height: Math.max(4, level * spectrum.height)
                x: (index + 0.5) * spectrum.slotW - width / 2
                anchors.bottom: parent.bottom
                radius: width / 2
                antialiasing: true
                color: Qt.alpha(Colours.m3primary, 0.30 + level * 0.46)
                Behavior on height { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 140 } }
            }
        }
    }

    // ------------------------------------------------------------- 5. Right Drawer
    CaelestiaRightDrawer {
        id: rightDrawer
        open: root.rightDrawerOpen
        z: 40
        onRequestOpenSettings: {
            if (typeof shell !== "undefined" && shell.openSettings)
                shell.openSettings();
        }
    }
}
