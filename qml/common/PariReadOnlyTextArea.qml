import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import "../app"

ScrollView {
    id: root
    clip: true
    
    property alias text: textArea.text
    property int textFormat: Text.MarkdownText
    property alias placeholderText: textArea.placeholderText
    property alias wrapMode: textArea.wrapMode
    property alias textAreaFont: textArea.font
    property alias color: textArea.color

    // Use pariTheme if available, otherwise fallback to a local PariTheme instance (for tests)
    readonly property var _theme: (typeof pariTheme !== 'undefined') ? pariTheme : fallbackTheme
    PariTheme { id: fallbackTheme }

    readonly property bool isDark: _theme.isDark

    TextArea {
        id: textArea
        width: root.width
        readOnly: true
        wrapMode: Text.WordWrap
        textFormat: root.textFormat
        font.family: _theme.monoFont
        font.pointSize: _theme.fontSize
        color: _theme.textColor
        padding: _theme.paddingLarge
        background: Rectangle {
            color: "transparent"
        }
    }
}
