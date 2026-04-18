import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

ScrollView {
    id: root
    clip: true
    
    property alias text: textArea.text
    property int textFormat: Text.MarkdownText
    property alias placeholderText: textArea.placeholderText
    property alias wrapMode: textArea.wrapMode
    property alias textAreaFont: textArea.font
    property alias color: textArea.color

    readonly property bool isDark: (typeof pariTheme !== 'undefined') ? pariTheme.isDark : ((typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false)

    TextArea {
        id: textArea
        width: root.width
        readOnly: true
        wrapMode: Text.WordWrap
        textFormat: root.textFormat
        font.family: (typeof pariTheme !== 'undefined') ? pariTheme.monoFont : ((typeof appSettings !== 'undefined' && appSettings && appSettings.fontFamily) ? appSettings.fontFamily : "Menlo")
        font.pointSize: (typeof pariTheme !== 'undefined') ? pariTheme.fontSize : ((typeof appSettings !== 'undefined' && appSettings && appSettings.fontSize) ? appSettings.fontSize : 12)
        color: (typeof pariTheme !== 'undefined') ? pariTheme.textColor : (isDark ? "#d0d0d0" : "#1a1c1c")
        padding: (typeof pariTheme !== 'undefined') ? pariTheme.paddingLarge : 10
        background: Rectangle {
            color: "transparent"
        }
    }
}
