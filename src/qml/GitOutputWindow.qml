import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: gitOutputWindow
    width: 800
    height: 600
    title: "Git Output"
    property string command: ""
    property string output: ""
    property string branchName: ""

    Pane {
        anchors.fill: parent
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            Label {
                text: "Branch: " + branchName
                font.bold: true
            }

            Label {
                text: "Command: " + command
                font.bold: true
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                TextArea {
                    id: outputArea
                    readOnly: true
                    text: output
                    wrapMode: Text.NoWrap
                    font.family: "monospace"
                }
            }

            Button {
                text: "Close"
                onClicked: gitOutputWindow.close()
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
