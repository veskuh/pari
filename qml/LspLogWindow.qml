import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: lspLogWindow
    width: 800
    height: 600
    title: qsTr("LSP Log")
    visible: false
    color: palette.window

    SystemPalette {
        id: palette
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Label {
            text: qsTr("LSP Message Log")
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            color: palette.windowText
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            TextArea {
                id: logView
                readOnly: true
                wrapMode: Text.WordWrap
                font.family: "monospace"
                font.pointSize: 10
                text: lspLogHandler ? lspLogHandler.logMessages.join("\\n\\n") : "LSP Log Handler not available."

                Connections {
                    target: lspLogHandler
                    enabled: lspLogHandler !== null
                    function onLogMessagesChanged() {
                        logView.text = lspLogHandler.logMessages.join("\\n\\n")
                    }
                }
            }
        }

        Button {
            text: qsTr("Close")
            Layout.alignment: Qt.AlignRight
            onClicked: lspLogWindow.close()
        }
    }
}
