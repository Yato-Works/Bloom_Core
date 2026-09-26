pragma Singleton
import QtQuick

QtObject {
    id: root
    readonly property bool armed: (typeof shellController !== "undefined" && shellController) ? shellController.armed : false
    readonly property bool locked: (typeof shellController !== "undefined" && shellController) ? shellController.locked : false
    readonly property real dimOpacity: (typeof shellController !== "undefined" && shellController) ? shellController.dimOpacity : 0.18
    function toggleLock() { if (typeof shellController !== "undefined" && shellController) shellController.toggleLock(); }
    function disarm() { if (typeof shellController !== "undefined" && shellController) shellController.disarm(); }
    function armPermanent(v) { if (typeof shellController !== "undefined" && shellController) shellController.armPermanent(v); }
}
