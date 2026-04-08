import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    
    property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false
    property alias content: container.data

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.margins: 4
    radius: 2
    
    color: isDark ? "#1a1a1a" : "#ffffff"
    border.color: isDark ? "#121212" : "#bcbcbc"
    border.width: 1

    // Inset shadow for depth
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        color: "transparent"
        border.color: isDark ? "#000000" : "black"
        opacity: isDark ? 0.2 : 0.05
        radius: 2
    }

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: 2
    }
}
