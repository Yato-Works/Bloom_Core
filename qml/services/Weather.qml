pragma Singleton
import QtQuick

QtObject {
    id: root
    readonly property string condition: (typeof weatherService !== "undefined" && weatherService) ? weatherService.condition : ""
    readonly property string temperature: (typeof weatherService !== "undefined" && weatherService) ? weatherService.temperature : ""
    readonly property string city: (typeof weatherService !== "undefined" && weatherService) ? weatherService.city : ""
    readonly property string humidity: (typeof weatherService !== "undefined" && weatherService) ? weatherService.humidity : ""
    readonly property string wind: (typeof weatherService !== "undefined" && weatherService) ? weatherService.wind : ""
    readonly property string pressure: (typeof weatherService !== "undefined" && weatherService) ? weatherService.pressure : ""
}
