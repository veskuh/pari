import QtQuick
import QtQuick.Layouts
import Kaakao 1.0
import "../app"

Rectangle {
    id: root
    
    // Use pariTheme if available, otherwise fallback to a local PariTheme instance (for tests)
    readonly property var _theme: (typeof pariTheme !== 'undefined') ? pariTheme : fallbackTheme
    PariTheme { id: fallbackTheme }

    readonly property bool isDark: _theme.isDark
    property alias content: container.data

    Layout.fillWidth: true
    Layout.margins: _theme.paddingSmall
    radius: _theme.borderRadius
    
    property color backgroundColor: "transparent"
    color: backgroundColor !== Qt.rgba(0,0,0,0) ? backgroundColor : (isDirtyWell ? _theme.editorBgDirty : Theme.contentBackground)
    border.color: Theme.textFieldBorder
    border.width: 1

    property bool isDirtyWell: false

    // Inset shadow for depth sourced from Theme.textFieldInnerShadow
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        color: "transparent"
        border.color: Theme.textFieldInnerShadow
        border.width: 1
        radius: root.radius
    }

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: 2
    }
}
