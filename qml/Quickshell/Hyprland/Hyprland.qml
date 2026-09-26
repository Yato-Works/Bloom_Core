pragma Singleton
import QtQuick

// ============================================================================
// Quickshell.Hyprland — Hyprland Compatibility Bridge for Windows
// Adapts Linux Hyprland workspaces and window events to Windows 11 Virtual Desktops
// by delegating to Bloom Core's WorkspaceModel and SystemModel.
// ============================================================================
QtObject {
    id: root

    readonly property var wsBackend: (typeof bloomWorkspace !== "undefined" && bloomWorkspace)
                                     ? bloomWorkspace
                                     : ((typeof workspaceController !== "undefined" && workspaceController) ? workspaceController : null)

    readonly property var sysBackend: (typeof bloomSystem !== "undefined" && bloomSystem)
                                      ? bloomSystem
                                      : ((typeof systemInfo !== "undefined" && systemInfo) ? systemInfo : null)

    // Current workspace index (1-based, Windows Virtual Desktop)
    readonly property int activeWsId: wsBackend ? wsBackend.currentWorkspace : 1

    readonly property var focusedWorkspace: ({
        id: activeWsId,
        name: String(activeWsId),
        toplevels: { values: [] }
    })

    readonly property var focusedMonitor: ({
        name: "PrimaryDisplay",
        id: 0,
        lastIpcObject: {
            specialWorkspace: { name: "" }
        }
    })

    // Workspaces model matching Hyprland's `Hyprland.workspaces.values`
    readonly property var workspaces: ({
        get values() {
            const list = [];
            const cur = root.activeWsId;
            const count = (root.wsBackend && root.wsBackend.workspaceCount) ? root.wsBackend.workspaceCount : 5;
            for (let i = 1; i <= Math.max(5, count); ++i) {
                list.push({
                    id: i,
                    name: String(i),
                    active: i === cur,
                    lastIpcObject: { windows: 1 }
                });
            }
            return list;
        }
    })

    readonly property var toplevels: ({
        values: []
    })

    readonly property var activeToplevel: ({
        title: root.sysBackend ? root.sysBackend.hostName : "Desktop",
        class: "Windows"
    })

    readonly property bool usingLua: false

    // Hyprland.dispatch(command)
    // Supports commands like:
    //   "workspace 2"
    //   "workspace +1" / "workspace next"
    //   "workspace -1" / "workspace prev"
    function dispatch(request: string): void {
        if (!request) return;
        const trimmed = request.trim();

        if (!root.wsBackend) return;

        if (trimmed.startsWith("workspace")) {
            const arg = trimmed.substring(9).trim();
            if (arg === "next" || arg === "+1" || arg === "e+1") {
                root.wsBackend.switchNext();
            } else if (arg === "prev" || arg === "-1" || arg === "e-1") {
                root.wsBackend.switchPrevious();
            } else {
                const target = parseInt(arg, 10);
                if (!isNaN(target) && target > 0) {
                    root.wsBackend.switchTo(target);
                }
            }
        }
    }

    function refreshWorkspaces(): void {}
    function refreshMonitors(): void {}
    function refreshToplevels(): void {}

    signal rawEvent(var event)
}
