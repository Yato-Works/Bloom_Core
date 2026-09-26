import QtQuick

Item {
    id: root

    property var settings: ({
        watchFiles: true
    })

    default property alias content: root.children
}
