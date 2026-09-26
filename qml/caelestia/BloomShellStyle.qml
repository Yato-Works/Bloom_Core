// Design tokens for the redesigned Bloom top bar & control panel.
//
// The old chrome leaned entirely on the dynamic wallpaper palette (Colours.m3*).
// The redesign asks for a calm, predictable dark mode: deep NAVY surfaces
// (never pure black), a low-saturated PASTEL-PINK accent, sharp 6-8px radii
// and a translucent "glass" panel. These constants back that look so the bar
// matches the mockup (mockups/bloom-topbar-spec.html) regardless of wallpaper.
//
// Not a singleton - each consumer instantiates it (a pure value object).
import QtQuick

QtObject {
    // ---- typography (Inter is preferred; Segoe UI is the system fallback) ----
    readonly property string fontUi:   "Inter"
    readonly property string fontMono: "Cascadia Code"

    // ---- surfaces: deep navy, opaque-ish for the bar, glassy for the panel ----
    readonly property color barColor:   Qt.rgba(0.075, 0.086, 0.118, 0.94)   // #131720 @ .94
    readonly property color panelColor: Qt.rgba(0.086, 0.106, 0.153, 0.84)   // #151a28 @ .84 (glass)
    readonly property color cardColor:  Qt.rgba(0.118, 0.137, 0.184, 0.58)   // panel cards
    readonly property color inputColor: Qt.rgba(0.150, 0.176, 0.239, 0.94)

    readonly property color lineSoft:    Qt.rgba(1, 1, 1, 0.07)
    readonly property color lineStrong:  Qt.rgba(1, 1, 1, 0.12)

    // ---- typography / text ----
    readonly property color textHi:   Qt.rgba(0.933, 0.933, 0.960, 1.0)
    readonly property color textMid:  Qt.rgba(0.70, 0.72, 0.80, 1.0)
    readonly property color textLow:  Qt.rgba(0.47, 0.49, 0.58, 1.0)
    readonly property color textOff:  Qt.rgba(0.33, 0.35, 0.42, 1.0)

    // ---- accents (pastel pink + semantic colors) ----
    readonly property color pink:       Qt.rgba(0.933, 0.70, 0.82, 1.0)        // #edb3d1
    readonly property color pinkSoft:   Qt.rgba(0.933, 0.70, 0.82, 0.13)
    readonly property color blue:       Qt.rgba(0.575, 0.70, 0.950, 1.0)
    readonly property color green:      Qt.rgba(0.555, 0.80, 0.68, 1.0)
    readonly property color warn:       Qt.rgba(0.95, 0.77, 0.54, 1.0)
    readonly property color bad:        Qt.rgba(0.94, 0.58, 0.58, 1.0)

    // ---- metrics: sharp, compact, 8px-based grid ----
    readonly property int barHeight:    46
    readonly property int panelHeight:  264
    readonly property int iconBtnSize:  30
    readonly property int radiusSharp: 6
    readonly property int radiusCard:  8
    readonly property int iconSize:    14
    readonly property int chipHeight:  30

    // ---- weather glyph helper (shared by bar + panel) ----
    function weatherGlyph(name) {
        const c = (name || "").toLowerCase()
        if (c.indexOf("clear")   !== -1 || c.indexOf("sunny") !== -1) return "☀️"
        if (c.indexOf("partly") !== -1 || c.indexOf("曇")    !== -1)  return "⛅"
        if (c.indexOf("cloud")   !== -1 || c.indexOf("くもり") !== -1)  return "☁️"
        if (c.indexOf("fog")    !== -1 || c.indexOf("霧")   !== -1)    return "🌫️"
        if (c.indexOf("drizzle") !== -1)                               return "🌦️"
        if (c.indexOf("rain")   !== -1 || c.indexOf("雨")   !== -1)    return "🌧️"
        if (c.indexOf("snow")   !== -1 || c.indexOf("雪")   !== -1)    return "❄️"
        if (c.indexOf("thunder") !== -1)                              return "⛈️"
        return "🌤️"
    }

    // ---- compact date helpers ----
    function shortDate(d) {
        const w = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][d.getDay()]
        return w + " " + ["Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec"][d.getMonth()] + " " + d.getDate()
    }
    function monthName(m) {
        return ["January","February","March","April","May","June",
                "July","August","September","October","November","December"][m] || ""
    }
}
