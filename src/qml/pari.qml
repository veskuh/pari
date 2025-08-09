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
                            wrapMode: Text.Wrap
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
                            wrapMode: Text.Wrap

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
                    wrapMode: Text.Wrap
                }
                RowLayout {
                
                    ComboBox {
                        id: promptComboBox
                        model: ["Comment the code", "Explain the code", "Refactor the code", "Write unit tests"]
                        onCurrentTextChanged: {
                            var prompt = ""
                            switch (currentIndex) {
                                case 0:
                                    prompt = "Add comments to the following code. Do not add any other text, just the commented code."
                                    break
                                case 1:
                                    prompt = "Explain the following code in a clear and concise way. Focus on the overall purpose of the code and the role of each major component."
                                    break
                                case 2:
                                    prompt = "Refactor the following code to improve its readability, performance, and maintainability. Do not add any new functionality."
                                    break
                                case 3:
                                    prompt = "Write unit tests for the following code. Use the Qt Test framework and cover all major functionality."
                                    break
                            }
                            aiMessagePane.text = prompt
                        }
                    }
                    Button {
                        text: "Send"
                        enabled: codeEditor.text != "" && aiMessagePane.text !="" 
                        onClicked: {
                            aiOutputPane.text = ""; // Clear previous output
                            var prompt = aiMessagePane.text                             
                            llm.sendPrompt("You are AI code assistant. Follow the instructions given for the code in the end of message. Be short in your response, no chatting or politness, just code or comment. " + prompt + "\n```\n" + codeEditor.text + "\n```");
                        }
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