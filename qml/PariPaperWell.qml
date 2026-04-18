import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    
    // Fallback to appSettings only if pariTheme is not available (e.g. in standalone tests)
    readonly property bool _isDark: (typeof pariTheme !== 'undefined') ? pariTheme.isDark : ((typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false)
    
    property bool isDark: _isDark
    property alias content: container.data

    Layout.fillWidth: true
    Layout.margins: (typeof pariTheme !== 'undefined') ? pariTheme.paddingSmall : 4
    radius: (typeof pariTheme !== 'undefined') ? pariTheme.borderRadius : 2
    
    color: (typeof pariTheme !== 'undefined') ? (isDirtyWell ? pariTheme.editorBgDirty : pariTheme.editorBg) : (isDark ? "#1a1a1a" : "#ffffff")
    border.color: (typeof pariTheme !== 'undefined') ? pariTheme.editorBorder : (isDark ? "#121212" : "#bcbcbc")
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
