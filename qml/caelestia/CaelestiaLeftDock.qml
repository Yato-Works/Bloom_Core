import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

// Caelestia-style left rail — quick toggles (Bluetooth / Wi-Fi / Mic /
// Night light), live workspaces, lock. Bluetooth opens a small popover
// with Enabled / Discovering switches, exactly like the reference shell.
Item {
    id: root

    property int activeWorkspace: 1
    readonly property string fontDisplay: "Rubik"

    // Quick-toggle state (local stand-ins for Windows radios)
    property bool bluetoothEnabled: true
    property bool bluetoothDiscovering: false
    property bool wifiEnabled: true
    property bool micMuted: false
    property bool nightLightEnabled: false
    property bool btPopoverOpen: false

    signal requestOpenDashboard()
    signal requestToggleLock()
    signal requestOpenSettings()

    width: 54
    height: 404
    anchors.left: parent.left
    anchors.leftMargin: 14
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
        anchors.fill: parent
        radius: 27
        color: Colours.m3surfaceContainerLowest
        border.width: 1
        border.color: Qt.alpha(Colours.m3outlineVariant, 0.24)
    }

    // Reusable toggle icon button
    component RailButton: Rectangle {
        id: railBtn
        property string glyph: ""
        property bool active: false
        property bool danger: false
        signal activated()

        Layout.alignment: Qt.AlignHCenter
        width: 38
        height: 38
        radius: 19
        color: active ? Colours.m3secondaryContainer
            : (hover.hovered ? Qt.alpha(Colours.m3primary, 0.14) : "transparent")
        Behavior on color { ColorAnimation { duration: 150 } }
        scale: hover.hovered ? 1.08 : 1
        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: railBtn.activated() }

        Text {
            anchors.centerIn: parent
            text: railBtn.glyph
            color: railBtn.danger && hover.hovered ? Colours.m3error
                 : railBtn.active ? Colours.m3onSecondaryContainer
                 : Colours.m3onSurfaceVariant
            font.family: root.fontDisplay
            font.pixelSize: 15
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 11
        anchors.bottomMargin: 11
        spacing: 6

        // Dashboard button
        RailButton {
            glyph: "✦"
            active: true
            onActivated: root.requestOpenDashboard()
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 2
            width: 22
            height: 1
            color: Qt.alpha(Colours.m3outlineVariant, 0.35)
        }

        // Bluetooth — opens the popover with Enabled / Discovering switches
        RailButton {
            id: btBtn
            glyph: "ᛒ"
            active: root.bluetoothEnabled || root.btPopoverOpen
            onActivated: {
                root.btPopoverOpen = !root.btPopoverOpen;
                if (root.btPopoverOpen && root.bluetoothEnabled)
                    root.bluetoothDiscovering = true;
            }
        }

        // Wi-Fi
        RailButton {
            glyph: "📶"
            active: root.wifiEnabled
            onActivated: root.wifiEnabled = !root.wifiEnabled
        }

        // Mic
        RailButton {
            glyph: root.micMuted ? "🔇" : "🎙"
            active: !root.micMuted
            onActivated: root.micMuted = !root.micMuted
        }

        // Night light
        RailButton {
            glyph: "🌙"
            active: root.nightLightEnabled
            onActivated: root.nightLightEnabled = !root.nightLightEnabled
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 2
            width: 22
            height: 1
            color: Qt.alpha(Colours.m3outlineVariant, 0.35)
        }

        // Workspace pills — live-bound to the virtual desktop state
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 5

            Repeater {
                model: 5
                Rectangle {
                    id: wsPill
                    required property int index
                    readonly property bool active: root.activeWorkspace === (index + 1)

                    width: 30
                    height: 30
                    radius: active ? 15 : 9
                    color: active ? Colours.m3secondaryContainer
                        : (wsHover.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.15) : "transparent")

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on radius { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    scale: wsHover.hovered && !active ? 1.08 : 1
                    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                    HoverHandler { id: wsHover }
                    TapHandler { onTapped: workspaceController.switchTo(wsPill.index + 1) }

                    Text {
                        anchors.centerIn: parent
                        text: wsPill.index + 1
                        color: wsPill.active ? Colours.m3onSecondaryContainer : Colours.m3onSurfaceVariant
                        font.family: root.fontDisplay
                        font.pixelSize: 11
                        font.weight: wsPill.active ? Font.Bold : Font.Normal
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Lock button
        RailButton {
            glyph: "⏻"
            danger: true
            onActivated: root.requestToggleLock()
        }
    }

    // ------------------------------------------------------------ Bluetooth popover
    Rectangle {
        id: btPopover
        visible: opacity > 0
        opacity: root.btPopoverOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        x: parent.width + 12
        y: 46
        width: 250
        height: btColumn.implicitHeight + 32
        radius: 24
        color: Colours.m3surfaceContainerLowest
        border.width: 1
        border.color: Qt.alpha(Colours.m3outlineVariant, 0.30)

        // Slide-in from behind the rail — same butter curve as the top drop
        transform: Translate {
            x: root.btPopoverOpen ? 0 : -16
            Behavior on x {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.30, 1.22, 0.28, 1, 1, 1]
                }
            }
        }

        ColumnLayout {
            id: btColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "Bluetooth"
                color: Colours.m3onSurface
                font.family: root.fontDisplay
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }

            // Enabled row
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Enabled"
                    color: Colours.m3onSurface
                    font.family: root.fontDisplay
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }
                SwitchButton { checked: root.bluetoothEnabled; onToggled: (val) => root.bluetoothEnabled = val }
            }

            // Discovering row
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Discovering"
                    color: Colours.m3onSurface
                    font.family: root.fontDisplay
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }
                SwitchButton {
                    checked: root.bluetoothDiscovering
                    enabled: root.bluetoothEnabled
                    onToggled: (val) => root.bluetoothDiscovering = val
                }
            }

            Text {
                text: root.bluetoothEnabled
                    ? (root.bluetoothDiscovering ? "Searching for devices…" : "0 devices available")
                    : "Bluetooth is off"
                color: Colours.m3onSurfaceVariant
                font.family: root.fontDisplay
                font.pixelSize: 11
            }

            // Open settings pill
            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 19
                color: Colours.m3primary
                opacity: setHover.hovered ? 0.88 : 1
                Behavior on opacity { NumberAnimation { duration: 140 } }

                HoverHandler { id: setHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        root.btPopoverOpen = false;
                        root.requestOpenSettings();
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "⚙  Open settings"
                    color: Colours.m3onPrimary
                    font.family: root.fontDisplay
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }
            }
        }
    }
}

