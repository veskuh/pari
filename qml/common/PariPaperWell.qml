import QtQuick
import QtQuick.Layouts
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
    
    color: isDirtyWell ? _theme.editorBgDirty : _theme.editorBg
    border.color: _theme.editorBorder
    border.width: 1

    property bool isDirtyWell: false

    // Inset shadow for depth
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        color: "transparent"
        border.color: root.isDark ? "#000000" : "black"
        opacity: root.isDark ? 0.2 : 0.05
        radius: root.radius
    }

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: 2
    }
}
