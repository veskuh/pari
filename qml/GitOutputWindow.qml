import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
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
                Layout.fillHeight: true
                
                StackLayout {
                    id: wellStack
                    anchors.fill: parent
                    anchors.margins: 5
                    currentIndex: {
                        if (gitLogModel !== null) {
                            return logView.count > 0 ? 0 : 1;
                        }
                        return 2;
                    }

                    ListView {
                        id: logView
                        objectName: "logView"
                        model: gitLogModel
                        clip: true
                        spacing: 5
                        delegate: GitLogDelegate {}
                    }

                    Label {
                        id: noEntriesLabel
                        text: qsTr("No log entries found.")
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.italic: true
                        color: isDark ? "#888888" : "#666666"
                    }

                    PariReadOnlyTextArea {
                        id: outputArea
                        objectName: "outputArea"
                        text: output
                        textFormat: Text.RichText
                        wrapMode: Text.NoWrap
                        textAreaFont.family: Qt.platform.os === 'osx' ? 'Menlo' : 'Noto Sans Mono'
                    }
                }
            }

            PariButton {
                objectName: "closeButton"
                text: qsTr("Close")
                onClicked: gitOutputWindow.close()
                Layout.alignment: Qt.AlignRight
                highlighted: true
            }
        }
    }
}
