import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs

import "." // Import local QML files

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
            MenuItem {
                text: qsTr("Settings...")
                onTriggered: settingsDialog.open()
            }
        }
        Menu {
            title: qsTr("Help")
            MenuItem { text: qsTr("About") }
        }
    }

    header: ToolBar {
        RowLayout {
            ToolButton {text: qsTr("Open")}
            ToolButton {text: qsTr("Save")}
            ToolButton {text: qsTr("Build")}
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
                text: qsTr("File System")
                Layout.leftMargin: 10
            }

            TreeView {
                id: fileSystemView
                Layout.fillHeight: true
                Layout.fillWidth: true
                model: fileSystem.model
                rootIndex: fileSystem.currentRootIndex

                property string selectedPath : ""

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
                    id: root
                    implicitHeight: 20
                    implicitWidth: fileSystemView.width

                    required property int depth
                    required property bool expanded
                    property bool isDirectory: fileSystem.isDirectory(model.filePath)

                    Label {
                        id: indicator
                        text: (isDirectory? "▶" : " ") 
                        x: (root.depth * 10) + 5
                        rotation : expanded? 90 : 0
                    }

                    Label {
                        text: model.display 
                        x: indicator.x + 20
                        font.bold: model.filePath == fileSystemView.selectedPath
                    }


                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (isDirectory) {
                                fileSystemView.toggleExpanded(index);
                            } else {
                                console.log("QML: Attempting to load file:", model.filePath);
                                fileSystem.loadFileContent(model.filePath);
                                fileSystemView.selectedPath = model.filePath
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

            RowLayout {
            
                // Right side: Editor 
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
                        Layout.minimumWidth: 400
                        TextArea {
                            id: codeEditor
                            placeholderText: "Code editor pane"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 500
                            Layout.minimumWidth: 400
                            font.family: appSettings.fontFamily
                            font.pointSize: appSettings.fontSize

                        }
                    }
                }

                // Right side: Editor 
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    // Top: Code Editor

                    Label {
                        text: qsTr("AI output")
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 500
                        Layout.minimumWidth: 400
                        TextArea {
                            id: aiOutputPane
                            placeholderText: "AI output"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 500
                            Layout.minimumWidth: 400

                        }
                    }
                }

                
            }

            // Bottom: AI Panes
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 250
                Layout.minimumHeight: 150

                // AI Message Pane
                Label {
                    text: qsTr("AI Message")
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHLeft
                }
                TextArea {
                    id: aiMessagePane
                    color: "lightblue"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 100
                    Layout.minimumHeight: 50
                }
                Button {
                    text: "Comment Code"
                    enabled: codeEditor.text != ""
                    onClicked: {
                        aiOutputPane.text = ""; // Clear previous output
                        llm.sendPrompt("Comment the following code:\n```\n" + codeEditor.text + "\n```");
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
            customStatusBar.text = qsTr("AI response received.");
        }
        function onBusyChanged() {
            if (llm.busy) {
                customStatusBar.text = qsTr("Processing AI request...");
            } else {
                customStatusBar.text = qsTr("Ready");
            }
        }
        function onNewLineReceived(line) {
            aiOutputPane.append(line);
        }
    }

    FolderDialog {
        id: fileDialog
        title: qsTr("Choose a folder")
        currentFolder: fileSystem.lastOpenedPath
        
        onAccepted: {
            if (fileDialog.selectedFolder) {
                fileSystem.setRootPath(fileDialog.selectedFolder.toString().replace("file://", ""));
            }
        }
    }

    SettingsDialog {
        id: settingsDialog
    }
}