import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: appWindow
    width: 1024
    height: 768
    visible: true
    title: qsTr("Pari")

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem { text: qsTr("Open") }
            MenuItem { text: qsTr("Save") }
            MenuItem { 
                text: qsTr("Exit")
                onTriggered: {
                    Qt.exit(0)
                }
            }
        }
        Menu {
            title: qsTr("Edit")
            MenuItem { text: qsTr("Cut") }
            MenuItem { text: qsTr("Copy") }
            MenuItem { text: qsTr("Paste") }
        }
        Menu {
            title: qsTr("Help")
            MenuItem { text: qsTr("About") }
        }
    }

    header: ToolBar {
        Layout.fillWidth: true
        RowLayout {
            anchors.fill: parent
            ToolButton { text: qsTr("Open"); Layout.preferredWidth: 80 }
            ToolButton { text: qsTr("Save"); Layout.preferredWidth: 80 }
            ToolButton { text: qsTr("Build"); Layout.preferredWidth: 80 }
        }
    }

    footer: CustomStatusBar {
        id: customStatusBar
    }

    // Main content area
    RowLayout {
        anchors.fill: parent

        // Left side: File System Pane / Project Explorer
        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            Layout.minimumWidth: 150
            Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "#ffcccc"; z: -1 } // Debug color

            Label {
                text: qsTr("File System / Project Explorer")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            TreeView {
                id: fileSystemView
                Layout.fillHeight: true
                Layout.fillWidth: true
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
            }
        }

        // Right side: Editor and AI Panes
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "#ccffcc"; z: -1 } // Debug color

            // Top: Code Editor
            Label {
                text: qsTr("Code Editor")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                TextArea {
                    id: codeEditor
                    placeholderText: "Code editor pane"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 200
                }
            }

            // Bottom: AI Panes
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 250
                Layout.minimumHeight: 150
                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "#ccccff"; z: -1 } // Debug color

                // AI Message Pane
                Label {
                    text: qsTr("AI Message")
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
                Rectangle {
                    id: aiMessagePane
                    color: "lightblue"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 100
                    Layout.minimumHeight: 50
                    Text {
                        text: "AI Message Pane"
                        anchors.centerIn: parent
                    }
                    Button {
                        text: "Comment Code"
                        anchors.centerIn: parent
                        enabled: codeEditor.text != ""
                        onClicked: {
                            llm.sendPrompt("Comment the following code:\n```\n" + codeEditor.text + "\n```");
                        }
                    }
                }

                // AI Output Pane
                Label {
                    text: qsTr("AI Output")
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
                TextArea {
                        id: aiOutputPane
                        placeholderText: "AI Output Pane"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredHeight: 150
                        Layout.minimumHeight: 100
                        Text {
                            id: busyIndicatorText
                            text: qsTr("Processing...")
                            anchors.centerIn: parent
                            visible: llm.busy
                        }
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

    Connections {
        target: llm
        function onResponseReady(response) {
            aiOutputPane.text = response;
            customStatusBar.text = qsTr("AI response received.");
        }
        function onBusyChanged() {
            if (llm.busy) {
                customStatusBar.text = qsTr("Processing AI request...");
            } else {
                customStatusBar.text = qsTr("Ready");
            }
        }
    }
}