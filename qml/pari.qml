import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    width: 1024
    height: 768
    visible: true
    title: qsTr("Pari")

    Component.onCompleted: {
    }

    RowLayout {
        anchors.fill: parent

        // Left side: File System Pane / Project Explorer
        TreeView {
            id: fileSystemView
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            Layout.minimumWidth: 150
            model: fileSystem.model
            rootIndex: fileSystem.model.index(fileSystem.model.rootPath, 0)

            delegate: Item {
                implicitHeight: 20
                implicitWidth: fileSystemView.width
                Text {
                    text: model.display
                    anchors.verticalCenter: parent.verticalCenter
                    x: 5
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (fileSystem.isDirectory(model.filePath)) {
                            fileSystemView.toggleExpanded(index);
                        } else {
                            fileSystem.loadFileContent(model.filePath);
                        }
                    }
                }
            }

            Connections {
                target: fileSystem
                function onFileContentReady(content) {
                    codeEditor.text = content;
                }
            }
        }

        // Right side: Editor and AI Panes
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Top: Code Editor
            TextArea {
                id: codeEditor
                placeholderText: "Code editor pane"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 200
            }

            // Bottom: AI Panes
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 250
                Layout.minimumHeight: 150

                // AI Message Pane
                Rectangle {
                    id: aiMessagePane
                    color: "lightblue"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Text {
                        text: "AI Message Pane"
                        anchors.centerIn: parent
                    }
                    Button {
                        text: "Comment Code"
                        anchors.centerIn: parent
                        onClicked: {
                            llm.sendPrompt("Comment the following code:\n```\n" + codeEditor.text + "\n```");
                        }
                    }
                }

                // AI Output Pane
                TextArea {
                    id: aiOutputPane
                    placeholderText: "AI Output Pane"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    Connections {
        target: llm
        function onResponseReady(response) {
            aiOutputPane.text = response;
        }
    }
}
