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

    Action {
        id: saveAction
        text: qsTr("Save")
        shortcut: StandardKey.Save
        enabled: codeEditor.text.length > 0 && fileSystem.currentFilePath !== ""
        onTriggered: {
            fileSystem.saveFile(fileSystem.currentFilePath, codeEditor.text)
        }
    }

    Action {
        id: saveAsAction
        text: qsTr("Save As...")
        shortcut: StandardKey.SaveAs
        enabled: codeEditor.text.length > 0
        onTriggered: saveAsDialog.open()
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Open")
                action: openAction
            }
            MenuItem {
                text: qsTr("Save")
                action: saveAction
            }
            MenuItem {
                text: qsTr("Save As...")
                action: saveAsAction
            }
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
                onTriggered: settingsDialog.show()
            }
        }
        Menu {
            title: qsTr("Help")
            MenuItem {
                text: qsTr("About")
                onTriggered: aboutWindow.show()
            }
        }
    }

    header: ToolBar {
        RowLayout {
            ToolButton {
                text: qsTr("Open")
                action: openAction
            }
            ToolButton {
                text: qsTr("Save")
                action: saveAction
            }
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
            Layout.preferredWidth: 250

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

                onModelChanged: {
                    console.log("TreeView: model changed to:", fileSystemView.model);
                }

                delegate: Item {
                    id: root
                    implicitHeight: 28
                    implicitWidth: fileSystemView.width

                    height: 28

                    required property int depth
                    required property bool expanded
                    property bool isDirectory: fileSystem.isDirectory(model.filePath)

                    Label {
                        id: indicator
                        text: (isDirectory? "▶" : " ") 
                        x: (root.depth * 10) + 5
                        rotation : expanded? 90 : 0
                        anchors.verticalCenter: parent.verticalCenter

                    }

                    Image {
                        source: {
                            if (model.filePath==null) {
                                "qrc:/assets/file.png"
                            }
                            else if (model.filePath.endsWith(".cpp") || model.filePath.endsWith(".h")) {
                                "qrc:/assets/cpp.png"
                            } else if (model.filePath.endsWith(".png")) {
                                "qrc:/assets/png.png"
                            } else if (model.filePath.endsWith(".qml")) {
                                "qrc:/assets/qml.png"
                            } else if (isDirectory) {
                                "qrc:/assets/folder.png"
                            } else if (model.filePath.endsWith(".md")) {
                                "qrc:/assets/md.png"
                            } else if (model.filePath.endsWith(".txt")) {
                                "qrc:/assets/txt.png"
                            } else {
                                "qrc:/assets/file.png"
                            }
                        }
                        sourceSize.height: 20
                        x: indicator.x + 14
                        anchors.verticalCenter: parent.verticalCenter

                    }

                    Label {
                        text: model.display ? model.display : "" 
                        x: indicator.x + 38
                        font.bold: model.filePath == fileSystemView.selectedPath
                        anchors.verticalCenter: parent.verticalCenter
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
        function onRootPathChanged() {
            fileSystemView.model = fileSystem.model
        }
        function onFileContentReady(content) {
            codeEditor.text = content;
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

    Connections {
        target: fileSystem
        function onFileSaved(filePath) {
            customStatusBar.text = qsTr("File saved: %1").arg(filePath)
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

    FileDialog {
        id: saveAsDialog
        title: "Save As..."
        fileMode: FileDialog.SaveFile
        currentFolder: fileSystem.lastOpenedPath
        onAccepted: {
            if (saveAsDialog.selectedFile) {
                fileSystem.saveFile(saveAsDialog.selectedFile.toString().replace("file://", ""), codeEditor.text)
            }
        }
    }

    SettingsWindow {
        id: settingsDialog
    }

    AboutWindow {
        id: aboutWindow
    }

    Component.onCompleted:{
        fileSystem.setRootPath(fileSystem.homePath)
    }   
}