import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs

ApplicationWindow {
    id: appWindow
    width: 1024
    height: 768
    visible: true
    title: qsTr("Pari")

    Action {
        id: openAction
        text: qsTr("Open")
        shortcut: StandardKey.Open
        onTriggered: fileDialog.open()
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Open")
                action: openAction
            }
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
            ToolButton { text: qsTr("Open"); width: 80 }
            ToolButton { text: qsTr("Save"); width: 80 }
            ToolButton { text: qsTr("Build"); width: 80 }
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
            Layout.preferredWidth: 150
            Layout.minimumWidth: 100

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
                rootIndex: fileSystem.currentRootIndex

                // Debugging TreeView properties
                Component.onCompleted: {
                    console.log("TreeView: Component.onCompleted - Initial rootIndex:", fileSystemView.rootIndex);
                    console.log("TreeView: Component.onCompleted - Initial model:", fileSystemView.model);
                }

                onRootIndexChanged: {
                    console.log("TreeView: rootIndex changed to:", fileSystemView.rootIndex);
                    // Check if the new rootIndex is valid and expand it
                    if (fileSystemView.rootIndex.isValid) {
                        fileSystemView.expand(fileSystemView.rootIndex);
                        console.log("TreeView: Expanded new rootIndex.");
                    } else {
                        console.log("TreeView: New rootIndex is not valid.");
                    }
                }

                onModelChanged: {
                    console.log("TreeView: model changed to:", fileSystemView.model);
                }

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
                                console.log("QML: Attempting to load file:", model.filePath);
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

            // Top: Code Editor
            Label {
                text: qsTr("Code Editor")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 500
                Layout.minimumWidth: 600
                TextArea {
                    id: codeEditor
                    placeholderText: "Code editor pane"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 500
                    Layout.minimumWidth: 600

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
        target: fileSystem.model
        function onDirectoryLoaded(path) {
            if (path === fileSystem.rootPath) {
                console.log("QML Connections: fileSystem.model.directoryLoaded detected for path:", path);
                fileSystemView.rootIndex = fileSystem.currentRootIndex;
                console.log("QML Connections: TreeView rootIndex set to:", fileSystemView.rootIndex);
                if (fileSystemView.rootIndex.isValid) {
                    fileSystemView.expand(fileSystemView.rootIndex);
                    console.log("QML Connections: TreeView expanded new rootIndex.");
                } else {
                    console.log("QML Connections: TreeView rootIndex is NOT valid after directory loaded.");
                }
            }
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

    FolderDialog {
        id: fileDialog
        title: qsTr("Choose a folder")
        
        onAccepted: {
            if (fileDialog.selectedFolder) {
                fileSystem.setRootPath(fileDialog.selectedFolder.toString().replace("file://", ""));
            }
        }
    }
}