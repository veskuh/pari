import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: chatLogWindow
    width: 800
    height: 600
    title: qsTr("Chat Log")
    visible: false
    color: palette.window

    property var chatLlm: null

    SystemPalette {
        id: palette
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Label {
            text: qsTr("Chat Session Log")
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            color: palette.windowText
        }

        ListView {
            id: chatLogView
            objectName: "chatLogView"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: chatLlm ? chatLlm.chatLog : []
            spacing: 5

            delegate: Rectangle {
                width: chatLogView.width - 20
                height: logText.implicitHeight + 10
                color: {
                    if (modelData.includes("USER:")) return palette.alternateBase
                    if (modelData.includes("ERROR:")) return "#ffebee"
                    return palette.base
                }
                radius: 4
                border.color: palette.mid
                border.width: 1

                Text {
                    id: logText
                    anchors.fill: parent
                    anchors.margins: 5
                    text: modelData
                    wrapMode: Text.WordWrap
                    color: modelData.includes("ERROR:") ? "red" : palette.text
                    font.family: "Menlo"
                    font.pixelSize: 12
                }
            }

            ScrollBar.vertical: ScrollBar {
                active: true
            }

            onCountChanged: {
                chatLogView.positionViewAtEnd()
            }
        }

        Button {
            text: qsTr("Close")
            Layout.alignment: Qt.AlignRight
            onClicked: chatLogWindow.close()
        }
    }
}
