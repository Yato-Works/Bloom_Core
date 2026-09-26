import QtQuick

Item {
    id: fview
    property string path: ""

    signal loaded()

    function text(): string {
        return ""
    }
}
