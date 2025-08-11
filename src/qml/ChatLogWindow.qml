import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: chatLogWindow
    width: 800
    height: 600
    title: qsTr("Chat Log")
    visible: false

    property var chatLlm: null

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Label {
            text: qsTr("Chat Session Log")
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            TextArea {
                id: chatLogArea
                readOnly: true
                wrapMode: Text.WordWrap
                text: chatLlm ? chatLlm.chatLog.join("\\n") : "No chat log available."

                Connections {
                    target: chatLlm
                    function onChatLogChanged() {
                        chatLogArea.text = chatLlm.chatLog.join("\\n")
                    }
                }
            }
        }

        Button {
            text: qsTr("Close")
            Layout.alignment: Qt.AlignRight
            onClicked: chatLogWindow.close()
        }
    }
}
