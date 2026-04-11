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

    property alias logView: logView
    property alias outputArea: outputArea

    // Theme helper
    readonly property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false

    onClosing: {
        gitLogModel = null;
    }

    Pane {
        anchors.fill: parent
        background: Rectangle { color: isDark ? "#1e1e1e" : "#f0f0f0" }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: qsTr("Command: ")
                    font.bold: true
                    color: isDark ? "#aaaaaa" : "#555555"
                }
                Label {
                    text: command
                    font.family: "Menlo"
                    color: isDark ? "#ffffff" : "#000000"
                }
                Item { Layout.fillWidth: true }
                Label {
                    text: "🌿 " + branchName
                    font.bold: true
                    visible: branchName !== ""
                    color: isDark ? "#4a9eff" : "#005a9e"
                }
            }

            PariPaperWell {
                id: well
                isDark: gitOutputWindow.isDark
                
                ListView {
                    id: logView
                    objectName: "logView"
                    anchors.fill: parent
                    anchors.margins: 5
                    model: gitLogModel
                    visible: gitLogModel !== null && logView.count > 0
                    clip: true
                    spacing: 5
                    delegate: GitLogDelegate {}
                }

                Label {
                    text: qsTr("No log entries found.")
                    visible: gitLogModel !== null && logView.count === 0
                    anchors.centerIn: parent
                    font.italic: true
                    color: isDark ? "#888888" : "#666666"
                }

                PariReadOnlyTextArea {
                    id: outputArea
                    objectName: "outputArea"
                    anchors.fill: parent
                    visible: gitLogModel === null
                    text: output
                    textFormat: Text.RichText
                    wrapMode: Text.NoWrap
                    textAreaFont.family: Qt.platform.os === 'osx' ? 'Menlo' : 'Noto Sans Mono'
                }
            }

            Button {
                text: qsTr("Close")
                onClicked: gitOutputWindow.close()
                Layout.alignment: Qt.AlignRight
                highlighted: true
            }
        }
    }
}
