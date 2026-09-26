pragma Singleton
import QtQuick

QtObject {
    id: root
    readonly property var backend: (typeof bloomWorkspace !== "undefined" && bloomWorkspace) ? bloomWorkspace : ((typeof workspaceController !== "undefined" && workspaceController) ? workspaceController : null)
    readonly property int currentWorkspace: backend ? backend.currentWorkspace : 1
    readonly property bool isSwitching: backend ? backend.isSwitching : false
    function switchTo(i) { if (backend) backend.switchTo(i); }
    function switchNext() { if (backend) backend.switchNext(); }
    function switchPrevious() { if (backend) backend.switchPrevious(); }
}
