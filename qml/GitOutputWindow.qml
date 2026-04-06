import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: gitOutputWindow
    width: 800
    height: 600
    title: qsTr("Git Output")
    property string command: ""
    property string output: ""
    property string branchName: ""
    property var gitLogModel: null

    onClosing: {
        gitLogModel = null;
    }

    Pane {
        anchors.fill: parent
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            Label {
                text: "🌿 " + qsTr("Branch: ") + branchName
                font.bold: true
                visible: gitLogModel === null
            }

            Label {
                text: qsTr("Command: ") + command
                font.bold: true
            }

            ListView {
                id: logView
                objectName: "logView"
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: gitLogModel
                visible: gitLogModel !== null
                clip: true
                spacing: 5
                delegate: GitLogDelegate {}
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: gitLogModel === null

                TextArea {
                    id: outputArea
                    objectName: "outputArea"
                    readOnly: true
                    text: output
                    wrapMode: Text.NoWrap
                    font.family: Qt.platform.os === 'osx' ? 'Menlo' : 'Noto Sans Mono'
                    textFormat: Text.PlainText
                }
            }

            Button {
                text: qsTr("Close")
                onClicked: gitOutputWindow.close()
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
