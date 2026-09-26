// BloomTopBar — the full-width, edge-anchored status bar that slides down on
// top-edge hover. Left: logo + app launcher. Center: compact status widgets.
// Right: compact media controls + date / time + pin.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    BloomShellStyle { id: st }

    // Mirror of CaelestiaShell surface state.
    property bool launcherOpen: false
    property bool panelOpen: false
    property bool pinned: false
    property bool armed: false            // keep-alive gate for sparklines
    readonly property bool hovered: barHover.hovered

    signal toggleLauncher()
    signal togglePanel()
    signal togglePin()
    signal openSettings()

    // Launcher dropdown is self-managed from the launcher button.
    onToggleLauncher: root.launcherOpen = !root.launcherOpen

    width: parent.width
    height: st.barHeight

    // Full-surface hover catch-all (buttons' own HoverHandlers still fire).
    HoverHandler { id: barHover }

    Rectangle {
        anchors.fill: parent
        color: st.barColor
        border.width: 1
        border.color: st.lineSoft
    }

    // Compact status chip used in the center group: label + sparkline + value.
    component StatusChip: Item {
        id: c
        required property string label
        required property string value
        required property color sparkColor
        property color sparkFill: Qt.rgba(0.933, 0.70, 0.82, 0.12)
        required property bool armed
        Layout.preferredHeight: st.chipHeight
        Layout.preferredWidth: 134
        Rectangle {
            anchors.fill: parent; anchors.margins: 1; radius: st.radiusSharp
            color: st.cardColor; border.width: 1; border.color: st.lineSoft
        }
        RowLayout {
            anchors.fill: parent; anchors.margins: 5; spacing: 6
            Text {
                text: c.label; color: st.textLow; font.family: st.fontMono; font.pixelSize: 9
                Layout.alignment: Qt.AlignVCenter
            }
            BloomSparkline {
                Layout.preferredWidth: 54; Layout.preferredHeight: 16
                lineColor: c.sparkColor; fillColor: c.sparkFill; sampling: c.armed
                Layout.alignment: Qt.AlignVCenter
            }
            Text {
                text: c.value; color: st.textHi; font.family: st.fontMono; font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 2
        clip: false

        // ---- LEFT ----
        Row {
            id: leftGroup
            spacing: 10
            Text {
                text: "\u2726"; color: st.pink; font.pixelSize: 15
                font.family: st.fontUi; font.weight: Font.Bold
                verticalAlignment: Text.AlignVCenter
                width: 30; height: 30
                transform: Translate { y: -1 }
            }
            Text { text: "Bloom"; color: st.textHi; font.family: st.fontUi; font.pixelSize: 13; font.weight: Font.DemiBold }
            Rectangle { width: 1; height: 22; color: st.lineSoft }
            Item {
                id: btnLaunch; width: st.iconBtnSize; height: st.iconBtnSize
                Rectangle {
                    anchors.fill: parent; anchors.margins: 2; radius: st.radiusSharp
                    color: root.launcherOpen ? st.pinkSoft : (launchHover.hovered ? "rgba(1,1,1,0.07)" : "transparent")
                    border.width: root.launcherOpen ? 1 : 0; border.color: st.pink
                    Behavior on color { ColorAnimation { duration: 140 } }
                    Behavior on border.width { NumberAnimation { duration: 120 } }
                    HoverHandler { id: launchHover }
                    TapHandler { onTapped: root.toggleLauncher() }
                    Text {
                        anchors.centerIn: parent
                        text: "\uD83D\xDD04"
                        color: root.launcherOpen ? st.pink : st.textMid
                        font.pixelSize: 15
                        font.family: "Segoe UI Emoji", st.fontUi
                    }
                }
            }
            Rectangle { width: 1; height: 22; color: st.lineSoft }
            Row {
                id: ws
                spacing: 4
                Repeater {
                    model: 5
                    delegate: Rectangle {
                        required property int index
                        readonly property bool active: workspaceController.currentWorkspace === (index + 1)
                        width: 24; height: 24; radius: st.radiusSharp
                        color: active ? st.pinkSoft : (wsHover.hovered ? "rgba(1,1,1,0.06)" : "transparent")
                        border.color: active ? st.pink : "transparent"; border.width: 1
                        HoverHandler { id: wsHover }
                        TapHandler { onTapped: workspaceController.switchTo(index + 1) }
                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            color: active ? st.pink : st.textLow
                            font.family: st.fontMono; font.pixelSize: 10
                            font.weight: active ? Font.Bold : Font.Normal
                        }
                    }
                }
            }
        }
        Item { Layout.fillWidth: true }
        // ---- CENTER ----
        RowLayout { id: centerGroup; spacing: 10
            StatusChip { label: "CPU"; value: systemInfo.cpuUsage + "%"
                sparkColor: systemInfo.cpuUsage > 85 ? st.bad : st.pink; armed: root.armed }
            StatusChip { label: "RAM"; value: systemInfo.memoryUsage + "%"
                sparkColor: st.blue; sparkFill: Qt.rgba(0.575, 0.70, 0.950, 0.13); armed: root.armed }
            StatusChip { label: "NET"; value: "LAN"
                sparkColor: st.green; sparkFill: Qt.rgba(0.337, 0.70, 0.43, 0.10); armed: root.armed }
            // weather summary
            Item {
                Layout.preferredHeight: st.chipHeight; Layout.preferredWidth: 156
                Rectangle { anchors.fill: parent; anchors.margins: 1; radius: st.radiusSharp;
                    color: st.cardColor; border.width: 1; border.color: st.lineSoft }
                RowLayout { anchors.fill: parent; anchors.margins: 6; spacing: 6
                    Text { text: st.weatherGlyph(weatherService.condition); font.pixelSize: 13;
                        font.family: "Segoe UI Emoji", st.fontUi; color: st.pink }
                    Text {
                        text: (weatherService.temperature === "" ? "23" : weatherService.temperature)
                              + "\u00B0 "
                              + (weatherService.condition === "" ? "" : weatherService.condition)
                        color: st.textMid; font.family: st.fontUi; font.pixelSize: 11; font.weight: Font.DemiBold
                        elide: Text.ElideRight; width: 120
                    }
                }
            }
            // calendar summary
            Item {
                Layout.preferredHeight: st.chipHeight; Layout.preferredWidth: 110
                Rectangle { anchors.fill: parent; anchors.margins: 1; radius: st.radiusSharp;
                    color: st.cardColor; border.width: 1; border.color: st.lineSoft }
                RowLayout { anchors.fill: parent; anchors.margins: 6; spacing: 6
                    Text { text: "\uD83D\x94\x8B"; font.pixelSize: 11; color: st.pink
                          font.family: "Segoe UI Emoji", st.fontUi }
                    Column {
                        Text { text: systemInfo.formattedTime; color: st.textHi; font.family: st.fontMono; font.pixelSize: 11 }
                        Text { text: st.shortDate(new Date()); color: st.textLow; font.family: st.fontMono; font.pixelSize: 9 }
                    }
                }
            }
        }
        Item { Layout.fillWidth: true }
        // ---- RIGHT ----
        Row { id: rightGroup; spacing: 8
            Item { width: 18 }
            Rectangle {
                id: mPrev
                width: st.iconBtnSize - 4; height: st.iconBtnSize - 4; radius: st.radiusSharp
                color: mPrevH.hovered ? st.pinkSoft : st.cardColor
                border.width: 1; border.color: st.lineSoft
                HoverHandler { id: mPrevH }
                TapHandler { onTapped: musicControl.previous() }
                Text { anchors.centerIn: parent; text: "\u23EE"; color: st.textMid; font.pixelSize: 11 }
            }
            Rectangle {
                id: mPlay
                width: st.iconBtnSize - 4; height: st.iconBtnSize - 4; radius: st.radiusSharp
                color: musicControl.isPlaying ? st.pink : (mPlayH.hovered ? st.pinkSoft : st.cardColor)
                border.color: musicControl.isPlaying ? st.pink : st.lineSoft; border.width: 1
                HoverHandler { id: mPlayH }
                TapHandler { onTapped: musicControl.togglePlayPause() }
                Text { anchors.centerIn: parent; text: musicControl.isPlaying ? "\u23F8" : "\u25B6";
                    color: musicControl.isPlaying ? "#2b0e1b" : st.textHi; font.pixelSize: 10 }
            }
            Rectangle {
                id: mNext
                width: st.iconBtnSize - 4; height: st.iconBtnSize - 4; radius: st.radiusSharp
                color: mNextH.hovered ? st.pinkSoft : st.cardColor
                border.width: 1; border.color: st.lineSoft
                HoverHandler { id: mNextH }
                TapHandler { onTapped: musicControl.next() }
                Text { anchors.centerIn: parent; text: "\u23ED"; color: st.textMid; font.pixelSize: 11 }
            }
            Text {
                text: musicControl.trackTitle === "" ? "Nothing Playing"
                      : (musicControl.trackTitle + (musicControl.artistName !== "" ? " \u00B7 " + musicControl.artistName : ""))
                color: musicControl.trackTitle === "" ? st.textLow : st.textHi
                font.family: st.fontUi; font.pixelSize: 11
                elide: Text.ElideRight; width: 150
            }
        }
        Rectangle { width: 1; height: 22; color: st.lineSoft }
        Item { width: 12 }
        Row { spacing: 8
            Text { text: systemInfo.volumeMuted ? "\uD83D\xDD07" : "\uD83D\xDD0A"
                color: st.textMid; font.pixelSize: 13
                MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: systemInfo.toggleMute() } }
            Item { width: 44; height: 3; visible: root.armed }
            Item {
                width: 44; height: 3
                Rectangle { anchors.fill: parent; radius: 2; color: st.lineSoft }
                Rectangle { height: parent.height; width: parent.width * (systemInfo.volumeMuted ? 0 : systemInfo.volumeLevel / 100); radius: 2; color: st.pink }
            }
            Text { text: systemInfo.formattedTime
                color: st.textHi; font.family: st.fontMono; font.pixelSize: 12; font.weight: Font.DemiBold }
        }
        // pin toggle (keeps the detail panel open)
        Item { width: 10 }
        Rectangle {
            id: pinBtn
            width: 28; height: 28; radius: st.radiusSharp
            color: root.pinned ? st.pinkSoft : (pinHover.hovered ? "rgba(1,1,1,0.07)" : st.cardColor)
            border.width: root.pinned ? 1 : 0; border.color: st.pink
            HoverHandler { id: pinHover }
            TapHandler { onTapped: root.togglePin() }
            Text { anchors.centerIn: parent; text: root.pinned ? "\uD83D\x94\xCC" : "\uD83D\x94\x8E";
                color: root.pinned ? st.pink : st.textLow; font.pixelSize: 13 }
        }
    } // /RowLayout

    BloomAppLauncher {
        id: launcher
        open: root.launcherOpen
        // btnLaunch lives inside the RowLayout (not a parent/sibling), so
        // anchor via a mapped position instead of anchors.
        x: btnLaunch.mapToItem(root, 0, 0).x
        y: btnLaunch.mapToItem(root, 0, btnLaunch.height).y + 4
        z: 50
    }
} // /root


