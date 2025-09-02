import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: 800
    height: 600
    title: "LSP Log"
    visible: false

    TextArea {
        id: logView
        anchors.fill: parent
        readOnly: true
        font.family: "monospace"
        font.pointSize: 10
        text: lspLogHandler ? lspLogHandler.logMessages.join("\\n") : "LSP Log Handler not available."

        Connections {
            target: lspLogHandler
            enabled: lspLogHandler !== null
            function onLogMessagesChanged() {
                logView.text = lspLogHandler.logMessages.join("\\n")
            }
        }
    }
}
