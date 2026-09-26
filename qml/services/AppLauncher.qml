pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property var backend: (typeof appLauncherService !== "undefined" && appLauncherService) ? appLauncherService : null
    readonly property var apps: backend ? backend.apps : []
    property string currentApp: ""

    function launch(id) {
        if (!backend) return false;
        return backend.launchApp(id);
    }

    function search(query) {
        if (!backend) return [];
        return backend.searchApps(query);
    }

    function evaluateMath(expr) {
        if (!backend) return { valid: false };
        return backend.evaluateMath(expr);
    }
}
