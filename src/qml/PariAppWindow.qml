import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs
import net.veskuh.pari 1.0

ApplicationWindow {
    id: appWindow

    property bool hasBuildConfiguration: false

    width: 1280 // Increased default width for better 3-pane view
    height: 768
    visible: true
    title: qsTr("Pari")

    // --- Actions, MenuBar, Header, and Footer are unchanged ---
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
            fileSystem.saveFile(fileSystem.currentFilePath, codeEditor.text);
        }
    }

    Action {
        id: saveAsAction
        text: qsTr("Save As...")
        shortcut: StandardKey.SaveAs
        enabled: codeEditor.text.length > 0
        onTriggered: saveAsDialog.open()
    }

    Action {
        id: findAction
        text: qsTr("Find")
        shortcut: StandardKey.Find
        onTriggered: codeEditor.find()
    }

    Action {
        id: configureBuildAction
        text: "Build setup..."
        onTriggered: {
            buildConfigurationWindow.buildCommand = appSettings.getBuildCommand(fileSystem.rootPath);
            buildConfigurationWindow.runCommand = appSettings.getRunCommand(fileSystem.rootPath);
            buildConfigurationWindow.cleanCommand = appSettings.getCleanCommand(fileSystem.rootPath);
            buildConfigurationWindow.visible = true;
        }
    }

    Action {
        id: buildAction
        text: "Build"
        enabled: hasBuildConfiguration
        shortcut: "Ctrl+b"
        onTriggered: {
            codeEditor.showBuildPanel()
            buildManager.executeCommand(appSettings.getBuildCommand(fileSystem.rootPath), fileSystem.rootPath);
        }
    }

    Action {
        id: runAction
        text: "Run"
        enabled: hasBuildConfiguration
        shortcut: "Ctrl+r"
        onTriggered: {
            codeEditor.showBuildPanel()
            buildManager.executeCommand(appSettings.getRunCommand(fileSystem.rootPath), fileSystem.rootPath);
        }
    }

    Action {
        id: indentAction
        text: qsTr("Indent")
        enabled: fileSystem.currentFilePath.endsWith(".qml")
        shortcut: "Ctrl+i"
        onTriggered: {
            codeEditor.saveCursorPosition()
            toolManager.indentQmlFile(fileSystem.currentFilePath, codeEditor.text);
        }
    }



    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Open")
                action: openAction
            }
            Menu {
                title: qsTr("Recents")
                Repeater {
                    model: appSettings.recentFolders
                    MenuItem {
                        text: modelData
                        onTriggered: fileSystem.setRootPath(modelData)
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Clear Recents")
                    onTriggered: appSettings.clearRecentFolders()
                }
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
                onTriggered: Qt.exit(0)
            }
        }
        Menu {
            title: qsTr("Edit")
            MenuItem {
                text: qsTr("Cut")
            }
            MenuItem {
                text: qsTr("Copy")
            }
            MenuItem {
                text: qsTr("Paste")
            }
            MenuItem {
                text: qsTr("Find")
                action: findAction
            }
            MenuItem {
                text: qsTr("Auto Intendt")
                action: indentAction
            }
            MenuItem {
                text: qsTr("Settings...")
                onTriggered: settingsDialog.show()
            }
        }
        Menu {
            title: qsTr("View")
            MenuItem {
                text: qsTr("Chat log")
                onTriggered: chatLogWindow.show()
            }
        }
        Menu {
            title: qsTr("Build")
            MenuItem {
                text: "Build"
                action: buildAction
            }
            MenuItem {
                text: "Run"
                action: runAction
            }
            MenuItem {
                id: cleanAction
                text: "Clean"
                enabled: hasBuildConfiguration
                onTriggered: {
                    outputArea.text = "";
                    outputPanel.visible = true;
                    buildManager.executeCommand(appSettings.getCleanCommand(fileSystem.rootPath), fileSystem.rootPath);
                }
            }
            MenuSeparator {}
            MenuItem {
                action: configureBuildAction
            }
        }
        Menu {
            title: qsTr("Help")
            MenuItem {
                text: qsTr("About")
                onTriggered: aboutWindow.show()
            }
        }
        Menu {
            title: qsTr("Git")
            MenuItem {
                text: "git diff"
                enabled: fileSystem.isGitRepository
                onTriggered: toolManager.runCommand("git diff", fileSystem.rootPath)
            }
            MenuItem {
                text: "git diff current file"
                enabled: fileSystem.isGitRepository && fileSystem.currentFilePath !== ""
                onTriggered: toolManager.runCommand("git diff " + fileSystem.currentFilePath, fileSystem.rootPath)
            }
            MenuItem {
                enabled: fileSystem.isGitRepository
                text: "git log"
                onTriggered: toolManager.runCommand("git log", fileSystem.rootPath)
            }
            MenuItem {
                text: "git blame"
                enabled: fileSystem.isGitRepository && fileSystem.currentFilePath !== ""
                onTriggered: toolManager.runCommand("git blame " + fileSystem.currentFilePath, fileSystem.rootPath)
            }
        }
    }

    header: ToolBar {
        height: 64

        Row {
            ToolButton {
                text: qsTr("Build")
                icon.source: "qrc:/assets/build.png"
                icon.width: 32
                icon.height: 32
                display: AbstractButton.TextUnderIcon
                width: 64
                action: buildAction
            }
            ToolButton {
                text: qsTr("Run")
                icon.source: "qrc:/assets/play.png"
                icon.width: 32
                icon.height: 32
                display: AbstractButton.TextUnderIcon
                width: 64
                action: runAction
            }
            ToolButton {
                text: qsTr("Search")
                icon.source: "qrc:/assets/search.png"
                icon.width: 32
                icon.height: 32
                display: AbstractButton.TextUnderIcon
                width: 64

                action: findAction
            }
        }

        Row {
            anchors.right: parent.right
            visible: false // TBD

            ToolButton {
                text: qsTr("Diff")
                icon.source: "qrc:/assets/diff.png"
                icon.width: 32
                icon.height: 32
                display: AbstractButton.TextUnderIcon
                width: 64
            }
            ToolButton {
                text: qsTr("Use")
                icon.source: "qrc:/assets/accept.png"
                icon.width: 32
                icon.height: 32
                display: AbstractButton.TextUnderIcon
                width: 64
            }
        }
    }

    footer: CustomStatusBar {
        id: customStatusBar
        modelName: appSettings.ollamaModel
    }

    // --- REFACTORED MAIN CONTENT AREA ---
    // A single SplitView manages the three main panes.
    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        // Pane 1: File System (20% width)
        ColumnLayout {
            // Use attached properties to define the pane's size within the SplitView
            SplitView.preferredWidth: appWindow.width * 0.20
            SplitView.minimumWidth: 200 // Prevent the pane from becoming too small

            Label {
                text: qsTr("File System")
                font.bold: true
                Layout.leftMargin: 10
                Layout.topMargin: 5
                Layout.bottomMargin: 5
            }

            TreeView {
                id: fileSystemView
                Layout.fillHeight: true
                Layout.fillWidth: true
                model: fileSystem.model
                property string selectedPath: ""

                delegate: FileTreeDelegate {}
            }
            Connections {
                target: fileSystemView
                function onModelChanged() {
                    fileSystemView.rootIndex = fileSystem.currentRootIndex;
                }
            }
        }

        // Pane 2: Code Editor (40% width)
        CodeEditorPane {
            id: codeEditor
            SplitView.preferredWidth: appWindow.width * 0.40
            SplitView.minimumWidth: 250
        }

        // Pane 3: AI Section (40% width) - Refactored with Tabs
        OutputPane {
            id: aiOutputPane
            SplitView.preferredWidth: appWindow.width * 0.40
            SplitView.minimumWidth: 250
        }
    }

    Connections {
        target: fileSystem
        function onRootPathChanged() {
            fileSystemView.model = fileSystem.model;
            var buildCommand = appSettings.getBuildCommand(fileSystem.rootPath);
            hasBuildConfiguration = buildCommand !== "";
        }
        function onFileContentReady(filePath, content) {
            codeEditor.text = content;
            syntaxHighlighterProvider.attachHighlighter(codeEditor.textDocument, filePath);
        }
        function onFileSaved(filePath) {
            customStatusBar.text = qsTr("File saved: %1").arg(filePath);
        }
    }

    Connections {
        target: llm
        function onResponseReady(response) {
            aiOutputPane.text = response;
            customStatusBar.text = qsTr("AI response received.");
            aiOutputPane.updateDiff(codeEditor.text);
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
        currentFolder: fileSystem.lastOpenedPath
        onAccepted: {
            if (fileDialog.selectedFolder) {
                const folderPath = fileDialog.selectedFolder.toString().replace("file://", "");
                fileSystem.setRootPath(folderPath);
                appSettings.addRecentFolder(folderPath);
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
                fileSystem.saveFile(saveAsDialog.selectedFile.toString().replace("file://", ""), codeEditor.text);
            }
        }
    }

    SettingsWindow {
        id: settingsDialog
    }
    AboutWindow {
        id: aboutWindow
    }
    ChatLogWindow {
        id: chatLogWindow
        chatLlm: llm
    }

    BuildConfigurationDialog {
        id: buildConfigurationWindow
        onSaveConfiguration: function (buildCommand, runCommand, cleanCommand) {
            appSettings.setBuildCommands(fileSystem.rootPath, buildCommand, runCommand, cleanCommand);
            hasBuildConfiguration = buildCommand !== "";
        }
    }

    function showGitOutput(command, output, branch) {
        var component = Qt.createComponent("GitOutputWindow.qml");
        if (component.status === Component.Ready) {
            var window = component.createObject(appWindow, {
                "command": command,
                "output": output,
                "branchName": branch
            });
            if (window) {
                window.show();
            } else {
                console.error("Error creating git output window");
            }
        } else {
            console.error("Error loading git output window component:", component.errorString());
        }
    }

    Connections {
        target: toolManager
        function onOutputReady(command, output, branchName) {
            showGitOutput(command, output, branchName)
        }
        function onQmlFileIndented(formattedContent) {
            codeEditor.text = formattedContent
            codeEditor.restoreCursorPosition()
        }
    }

    Component.onCompleted: {
        fileSystem.setRootPath(fileSystem.homePath);
    }
}
