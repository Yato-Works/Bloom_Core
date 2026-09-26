pragma Singleton
import QtQuick
import Bloom

QtObject {
    id: root

    readonly property string fontDisplay: Tokens.fontDisplay
    readonly property string fontMono: Tokens.fontMono
    readonly property int durationFast: Tokens.durationFast
    readonly property int durationNormal: Tokens.durationNormal
    readonly property int durationSlow: Tokens.durationSlow
    readonly property var easeEmphasized: Tokens.easeEmphasized
}
