import QtQuick

// Quickshell.Io.Process fallback/adapter
Item {
    id: proc
    property var command: []
    property bool running: false
    property string stdout: ""
    property string stderr: ""

    signal exited(int exitCode)

    function start() {}
    function terminate() {}
}
