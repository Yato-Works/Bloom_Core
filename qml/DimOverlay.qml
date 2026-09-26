import QtQuick
import Bloom

// ============================================================================
// Bloom.DimOverlay — Hold-to-Arm Dimming Scrim
// Smoothly dims the screen and absorbs/handles background clicks when Win+Ctrl
// (Hold-to-Arm) is active.
// ============================================================================
Rectangle {
    id: root
    anchors.fill: parent
    z: 0

    // Properties
    property color dimColor: "#000000"
    property int duration: 180
    property bool dismissOnClick: true
    property bool blockClicks: true

    signal dismissed()

    // Resolve shell armed state from Core singleton or fallback to context property
    readonly property bool armed: (typeof Core !== "undefined" && Core)
                                  ? Core.armed
                                  : ((typeof shellController !== "undefined" && shellController) ? shellController.armed : false)

    readonly property real targetOpacity: (typeof Core !== "undefined" && Core)
                                          ? Core.dimOpacity
                                          : ((typeof shellController !== "undefined" && shellController) ? shellController.dimOpacity : 0.16)

    color: dimColor
    opacity: root.armed ? root.targetOpacity : 0.0
    visible: opacity > 0.001

    Behavior on opacity {
        NumberAnimation {
            duration: root.duration
            easing.type: Easing.OutCubic
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.armed && root.blockClicks
        acceptedButtons: Qt.AllButtons
        hoverEnabled: false

        onClicked: function(mouse) {
            mouse.accepted = true;
            if (root.dismissOnClick) {
                root.dismissed();
                if (typeof Core !== "undefined" && Core) {
                    if (typeof Core.dismiss === "function") Core.dismiss();
                    else if (typeof Core.armPermanent === "function") Core.armPermanent(false);
                } else if (typeof shellController !== "undefined" && shellController) {
                    shellController.dismiss();
                }
            }
        }
        onPressed: function(mouse) { mouse.accepted = true; }
        onWheel: function(wheel) { wheel.accepted = true; }
    }
}
