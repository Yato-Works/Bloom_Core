import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom
import Quickshell.Hyprland
import Quickshell.Services.Mpris

// ============================================================================
// Bloom Core — Default Reference Shell
// Demonstrates:
// 1. Hold-to-Arm interaction model (Ctrl+Win) & DimOverlay with ESC / click dismiss
// 2. Multi-edge slide-in panels (Bloom.EdgePanel for Top, Left, and Bottom)
// 3. Smart Bottom Media & Spectrum Dock: gracefully disappears when music stops!
// 4. Virtual Desktop switching via Shortcuts and Workspace API
// 5. Embedded Smart Launcher Modal & Real-time WASAPI audio spectrum
// ============================================================================
ApplicationWindow {
    id: window
    title: "Bloom Core"
    color: "transparent"
    visible: true
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    width: Screen.width
    height: Screen.height
    x: 0
    y: 0

    readonly property string fontDisplay: "Rubik, 'Segoe UI Variable Display', 'Segoe UI', -apple-system, sans-serif"
    property bool previewMode: false

    readonly property bool armed: (typeof Core !== "undefined" && Core)
                                  ? (Core.armed || previewMode)
                                  : ((typeof shellController !== "undefined" && shellController) ? (shellController.armed || previewMode) : previewMode)

    readonly property bool locked: (typeof Core !== "undefined" && Core)
                                   ? (Core.locked || previewMode)
                                   : ((typeof shellController !== "undefined" && shellController) ? (shellController.locked || previewMode) : previewMode)

    // Detect active music playback (playing, valid track info, or audio output)
    readonly property bool hasMediaPlayback: {
        if (previewMode) return true;
        var isPlaying = (typeof Mpris !== "undefined" && Mpris && Mpris.playing)
                     || (typeof Media !== "undefined" && Media && Media.isPlaying);
        var hasTrack = (typeof Mpris !== "undefined" && Mpris && Mpris.title !== "" && Mpris.title !== "No Track")
                    || (typeof Media !== "undefined" && Media && Media.trackTitle !== "" && Media.trackTitle !== "No Track");
        var hasSound = (typeof Audio !== "undefined" && Audio && Audio.hasAudio);
        return isPlaying || (hasTrack && hasSound);
    }

    // -------------------------------------------------------------
    // Keyboard Shortcuts: ESC dismiss
    // -------------------------------------------------------------
    Shortcut {
        sequence: "Escape"
        enabled: window.armed
        onActivated: {
            if (smartLauncher.visible) {
                smartLauncher.close();
            } else {
                if (typeof Core !== "undefined" && Core && Core.dismiss) {
                    Core.dismiss();
                } else if (typeof shellController !== "undefined" && shellController) {
                    shellController.dismiss();
                }
            }
        }
    }

    Item {
        id: shellRoot
        anchors.fill: parent

        // Aesthetic desktop backdrop for GitHub preview/screenshot
        Rectangle {
            anchors.fill: parent
            visible: window.previewMode
            z: -100
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#0A0D14" }
                GradientStop { position: 0.5; color: "#111827" }
                GradientStop { position: 1.0; color: "#06080D" }
            }
            Rectangle {
                width: parent.width * 0.7
                height: parent.height * 0.7
                radius: width / 2
                anchors.centerIn: parent
                color: Qt.alpha(Colours.m3primary, 0.07)
            }
        }

        // -------------------------------------------------------------
        // 1. Core Dimming Scrim (Hold-to-Arm Feature)
        // -------------------------------------------------------------
        DimOverlay {
            id: dimOverlay
            dimColor: Qt.rgba(0.03, 0.04, 0.07, 0.70)
            duration: 220
            dismissOnClick: true
            onDismissed: {
                if (smartLauncher.visible) {
                    smartLauncher.close();
                }
            }
        }

        // -------------------------------------------------------------
        // 2. TOP EDGE PANEL (Status Bar & Workspaces)
        // -------------------------------------------------------------
        EdgePanel {
            id: topEdge
            edge: "top"
            panelThickness: 64
            revealOnArm: true
            revealOnEdgeHover: true
            edgeZoneThickness: 14

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                height: 48
                radius: 24
                color: Colours.m3surfaceContainerLowest
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    // Logo & Engine Badge
                    Row {
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter
                        Text { text: "✦"; color: Colours.m3primary; font.pixelSize: 16; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter }
                        Text {
                            text: "Bloom Core"
                            color: Colours.m3onSurface
                            font.family: window.fontDisplay
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Rectangle {
                            width: 52; height: 20; radius: 10
                            color: Qt.alpha(Colours.m3primary, 0.15)
                            anchors.verticalCenter: parent.verticalCenter
                            Text { anchors.centerIn: parent; text: "Engine"; color: Colours.m3primary; font.pixelSize: 10; font.weight: Font.Bold }
                        }
                    }

                    Rectangle { width: 1; height: 20; color: Qt.alpha(Colours.m3outlineVariant, 0.3); Layout.alignment: Qt.AlignVCenter }

                    // Virtual Desktops Switcher (Using both Workspace model & Hyprland shim)
                    Row {
                        spacing: 6
                        Layout.alignment: Qt.AlignVCenter

                        // Prev button
                        Rectangle {
                            width: 26; height: 26; radius: 13
                            color: prevHover.hovered ? Qt.alpha(Colours.m3primary, 0.15) : "transparent"
                            Text { anchors.centerIn: parent; text: "‹"; color: Colours.m3onSurface; font.pixelSize: 14; font.weight: Font.Bold }
                            HoverHandler { id: prevHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler {
                                onTapped: {
                                    if (typeof Workspace !== "undefined" && Workspace) Workspace.switchPrevious();
                                    else Hyprland.dispatch("workspace prev");
                                }
                            }
                        }

                        Repeater {
                            model: (typeof Workspace !== "undefined" && Workspace && Workspace.list) ? Workspace.list : Hyprland.workspaces.values
                            delegate: Rectangle {
                                required property var modelData
                                readonly property int wsId: modelData.id
                                readonly property bool active: (typeof Workspace !== "undefined" && Workspace)
                                                               ? (Workspace.currentWorkspace === wsId)
                                                               : (modelData.id === Hyprland.activeWsId)

                                width: 28; height: 28; radius: 14
                                color: active ? Colours.m3primary : (wsHover.hovered ? Qt.alpha(Colours.m3primary, 0.12) : "transparent")
                                border.width: 1
                                border.color: active ? Colours.m3primary : Qt.alpha(Colours.m3outlineVariant, 0.25)
                                Behavior on color { ColorAnimation { duration: 150 } }

                                HoverHandler { id: wsHover; cursorShape: Qt.PointingHandCursor }
                                TapHandler {
                                    onTapped: {
                                        if (typeof Workspace !== "undefined" && Workspace) Workspace.switchTo(wsId);
                                        else Hyprland.dispatch("workspace " + wsId);
                                    }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: String(wsId)
                                    color: active ? Colours.m3onPrimary : Colours.m3onSurfaceVariant
                                    font.family: window.fontDisplay
                                    font.pixelSize: 11
                                    font.weight: active ? Font.Bold : Font.Normal
                                }
                            }
                        }

                        // Next button
                        Rectangle {
                            width: 26; height: 26; radius: 13
                            color: nextHover.hovered ? Qt.alpha(Colours.m3primary, 0.15) : "transparent"
                            Text { anchors.centerIn: parent; text: "›"; color: Colours.m3onSurface; font.pixelSize: 14; font.weight: Font.Bold }
                            HoverHandler { id: nextHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler {
                                onTapped: {
                                    if (typeof Workspace !== "undefined" && Workspace) Workspace.switchNext();
                                    else Hyprland.dispatch("workspace next");
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Top Edge Pin Toggle
                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: topEdge.pinned ? Qt.alpha(Colours.m3primary, 0.2) : (pinHover.hovered ? Qt.alpha(Colours.m3onSurface, 0.08) : "transparent")
                        Text { anchors.centerIn: parent; text: "📌"; font.pixelSize: 12 }
                        HoverHandler { id: pinHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: topEdge.togglePin() }
                    }

                    // Host & Clock
                    Text {
                        text: ((typeof System !== "undefined" && System) ? System.hostName : "Desktop") + "  •  " + Qt.formatTime(new Date(), "hh:mm")
                        color: Colours.m3onSurfaceVariant
                        font.family: window.fontDisplay
                        font.pixelSize: 12
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }

        // -------------------------------------------------------------
        // 3. LEFT EDGE PANEL (Linux-style Quick Dock)
        // -------------------------------------------------------------
        EdgePanel {
            id: leftDock
            edge: "left"
            panelThickness: 64
            revealOnArm: true
            revealOnEdgeHover: true
            edgeZoneThickness: 14

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 8
                width: 48
                radius: 24
                color: Colours.m3surfaceContainerLowest
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 16
                    anchors.bottomMargin: 16
                    spacing: 12

                    // Launcher icon (Opens Smart Launcher)
                    Rectangle {
                        width: 36; height: 36; radius: 18
                        Layout.alignment: Qt.AlignHCenter
                        color: launchHover.hovered ? Qt.alpha(Colours.m3primary, 0.3) : Qt.alpha(Colours.m3primary, 0.15)
                        border.width: 1
                        border.color: Qt.alpha(Colours.m3primary, 0.3)
                        Text { anchors.centerIn: parent; text: "🚀"; font.pixelSize: 16 }
                        HoverHandler { id: launchHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            onTapped: {
                                smartLauncher.open();
                            }
                        }
                    }

                    Rectangle { width: 24; height: 1; color: Qt.alpha(Colours.m3outlineVariant, 0.25); Layout.alignment: Qt.AlignHCenter }

                    // Pin toggle
                    Rectangle {
                        width: 36; height: 36; radius: 18
                        Layout.alignment: Qt.AlignHCenter
                        color: leftDock.pinned ? Qt.alpha(Colours.m3primary, 0.25) : (leftPinHover.hovered ? Qt.alpha(Colours.m3onSurface, 0.08) : "transparent")
                        Text { anchors.centerIn: parent; text: "📌"; font.pixelSize: 13 }
                        HoverHandler { id: leftPinHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: leftDock.togglePin() }
                    }

                    Item { Layout.fillHeight: true }

                    // Lock toggle with visual indicator
                    Rectangle {
                        width: 36; height: 36; radius: 18
                        Layout.alignment: Qt.AlignHCenter
                        color: window.locked ? Qt.alpha(Colours.m3primary, 0.35) : (lockHover.hovered ? Qt.alpha(Colours.m3primary, 0.15) : "transparent")
                        border.width: window.locked ? 1 : 0
                        border.color: Colours.m3primary
                        Text {
                            anchors.centerIn: parent
                            text: window.locked ? "🔒" : "🔓"
                            font.pixelSize: 14
                        }
                        HoverHandler { id: lockHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            onTapped: {
                                if (typeof Core !== "undefined" && Core) Core.toggleLock();
                                else if (typeof shellController !== "undefined" && shellController) shellController.toggleLock();
                            }
                        }
                    }
                }
            }
        }

        // -------------------------------------------------------------
        // 4. BOTTOM EDGE PANEL (Media & Audio Spectrum Dock)
        // Disappears gracefully when music stops!
        // -------------------------------------------------------------
        EdgePanel {
            id: bottomDock
            edge: "bottom"
            panelThickness: 64
            // Reveal on arm ONLY if music is playing, or if explicitly hovered/pinned
            revealOnArm: window.hasMediaPlayback
            revealOnEdgeHover: true
            edgeZoneThickness: 14

            opacity: (window.hasMediaPlayback || bottomDock.pinned || bottomDock.hoverActive) ? 1.0 : 0.0
            visible: opacity > 0.001
            Behavior on opacity {
                NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                height: 48
                radius: 24
                color: Colours.m3surfaceContainerLowest
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 14

                    // Media Info
                    Row {
                        spacing: 10
                        Layout.alignment: Qt.AlignVCenter
                        Text { text: "🎵"; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
                        Text {
                            text: {
                                var t = (Mpris.title !== "" ? Mpris.title : (window.previewMode ? "Bloom Core - Ambient Dreamscape" : "No Track"));
                                var a = (Mpris.artist !== "" ? Mpris.artist : (window.previewMode ? "Bloom Audio Engine" : "Unknown"));
                                return t + " - " + a;
                            }
                            color: Colours.m3onSurface
                            font.family: window.fontDisplay
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            Layout.preferredWidth: 220
                            width: 220
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Media Controls
                    Row {
                        spacing: 6
                        Layout.alignment: Qt.AlignVCenter
                        Rectangle {
                            width: 26; height: 26; radius: 13
                            color: prevBtnHover.hovered ? Qt.alpha(Colours.m3primary, 0.15) : "transparent"
                            Text { anchors.centerIn: parent; text: "⏮"; color: Colours.m3onSurface; font.pixelSize: 11 }
                            HoverHandler { id: prevBtnHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: Mpris.defaultPlayer.previous() }
                        }
                        Rectangle {
                            width: 28; height: 28; radius: 14
                            color: playBtnHover.hovered ? Qt.alpha(Colours.m3primary, 0.25) : Qt.alpha(Colours.m3primary, 0.15)
                            Text { anchors.centerIn: parent; text: (Mpris.playing || window.previewMode) ? "⏸" : "▶"; color: Colours.m3primary; font.pixelSize: 11 }
                            HoverHandler { id: playBtnHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: Mpris.defaultPlayer.playPause() }
                        }
                        Rectangle {
                            width: 26; height: 26; radius: 13
                            color: nextBtnHover.hovered ? Qt.alpha(Colours.m3primary, 0.15) : "transparent"
                            Text { anchors.centerIn: parent; text: "⏭"; color: Colours.m3onSurface; font.pixelSize: 11 }
                            HoverHandler { id: nextBtnHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: Mpris.defaultPlayer.next() }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Real-time Audio Spectrum Bars (WASAPI Loopback)
                    // Fades to zero when silent or music stops
                    Row {
                        spacing: 2
                        Layout.alignment: Qt.AlignVCenter
                        Repeater {
                            model: 24
                            delegate: Rectangle {
                                required property int index
                                width: 3
                                height: {
                                    if (!window.hasMediaPlayback) return 0;
                                    if (typeof Audio !== "undefined" && Audio && Audio.bars && Audio.bars.length > index) {
                                        var val = Number(Audio.bars[index]);
                                        if (val > 0.01) return Math.max(2, Math.min(24, val * 24));
                                    }
                                    if (window.previewMode) {
                                        var wave = Math.sin((index * 0.38) + 1.2) * 0.5 + 0.5;
                                        return Math.max(4, wave * 22);
                                    }
                                    return 0;
                                }
                                radius: 1.5
                                color: Colours.m3primary
                                opacity: window.hasMediaPlayback ? 0.85 : 0.0
                                anchors.bottom: parent.bottom
                                Behavior on height { NumberAnimation { duration: 60 } }
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                            }
                        }
                    }

                    // Bottom Pin Toggle
                    Rectangle {
                        width: 26; height: 26; radius: 13
                        color: bottomDock.pinned ? Qt.alpha(Colours.m3primary, 0.2) : (botPinHover.hovered ? Qt.alpha(Colours.m3onSurface, 0.08) : "transparent")
                        Text { anchors.centerIn: parent; text: "📌"; font.pixelSize: 11 }
                        HoverHandler { id: botPinHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: bottomDock.togglePin() }
                    }
                }
            }
        }

        // -------------------------------------------------------------
        // 5. SMART LAUNCHER MODAL (Full app search, calculator, CLI)
        // -------------------------------------------------------------
        SmartLauncherModal {
            id: smartLauncher
            anchors.fill: parent
            z: 2000
        }

        Connections {
            target: (typeof Core !== "undefined" && Core) ? Core : null
            function onLauncherRequested() {
                smartLauncher.open();
            }
        }
    }

    Component.onCompleted: {
        var isPrev = (typeof bloomEngine !== "undefined" && bloomEngine && bloomEngine.previewMode)
                  || (typeof Core !== "undefined" && Core && Core.previewMode);
        if (isPrev) {
            previewMode = true;
            bottomDock.pinned = true;
            captureTimer.start();
        }
    }

    Timer {
        id: captureTimer
        interval: 1800
        repeat: false
        onTriggered: {
            shellRoot.grabToImage(function(result) {
                var p1 = "c:/Users/smily/Bloom_Core/assets/bloom_core_preview.png";
                var p2 = "c:/Users/smily/Bloom_Core/assets/bloom_core_hero.png";
                var p3 = "C:/Users/smily/.gemini/antigravity-ide/brain/cb9aaa05-af42-4193-9c9b-9b910d1e071f/bloom_core_preview.png";
                result.saveToFile(p1);
                result.saveToFile(p2);
                result.saveToFile(p3);
                console.log("BloomCore: Grabbed shellRoot preview screenshot to " + p1);

                // Now open SmartLauncher and capture modal screenshot
                launcherCaptureTimer.start();
            });
        }
    }

    Timer {
        id: launcherCaptureTimer
        interval: 900
        repeat: false
        onTriggered: {
            smartLauncher.open();
            launcherSettleTimer.start();
        }
    }

    Timer {
        id: launcherSettleTimer
        interval: 800
        repeat: false
        onTriggered: {
            shellRoot.grabToImage(function(result) {
                var p4 = "c:/Users/smily/Bloom_Core/assets/bloom_core_launcher.png";
                var p5 = "C:/Users/smily/.gemini/antigravity-ide/brain/cb9aaa05-af42-4193-9c9b-9b910d1e071f/bloom_core_launcher.png";
                result.saveToFile(p4);
                result.saveToFile(p5);
                console.log("BloomCore: Grabbed smartLauncher screenshot to " + p4);
            });
        }
    }
}
