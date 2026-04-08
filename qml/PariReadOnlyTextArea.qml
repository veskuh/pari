import QtQuick
import QtQuick.Controls

ScrollView {
    id: root
    clip: true
    
    property alias text: textArea.text
    property alias textFormat: textArea.textFormat
    property alias placeholderText: textArea.placeholderText
    property alias wrapMode: textArea.wrapMode
    property alias textAreaFont: textArea.font
    property alias color: textArea.color

    readonly property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false

    TextArea {
        id: textArea
        readOnly: true
        wrapMode: Text.WordWrap
        textFormat: Text.MarkdownText
        font.family: (typeof appSettings !== 'undefined' && appSettings && appSettings.fontFamily) ? appSettings.fontFamily : "Menlo"
        font.pointSize: (typeof appSettings !== 'undefined' && appSettings && appSettings.fontSize) ? appSettings.fontSize : 12
        color: isDark ? "#d0d0d0" : "#1a1c1c"
        padding: 10
        background: null
    }
}
