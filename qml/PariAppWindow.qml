import QtQuick
import Qt.labs.settings 1.0
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs
import net.veskuh.pari 1.0

ApplicationWindow {
    id: appWindow

    GitLogModel {
        id: gitLogModel
    }

    property bool hasBuildConfiguration: false

    minimumWidth: 800
    minimumHeight: 480

    visible: true
    title: qsTr("Pari") + " - " + fileSystem.rootPath

    Settings {
        property alias x: appWindow.x
        property alias y: appWindow.y
        property alias width: appWindow.width
        property alias height: appWindow.height
    }

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
        enabled: stackLayout.currentIndex !== -1
        onTriggered: {
            var currentDoc = documentManager.documents[stackLayout.currentIndex];
            var currentEditor = stackLayout.currentItem;
            documentManager.saveFile(stackLayout.currentIndex, currentEditor.text);
        }
    }

    Action {
        id: saveAsAction
        text: qsTr("Save As...")
        shortcut: StandardKey.SaveAs
        enabled: stackLayout.currentIndex !== -1
        onTriggered: saveAsDialog.open()
    }

    Action {
        id: findAction
        text: qsTr("Find")
        shortcut: StandardKey.Find
        enabled: stackLayout.currentIndex !== -1
        onTriggered: {
            var currentEditor = stackLayout.currentItem;
            currentEditor.find();
        }
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
            var currentEditor = stackLayout.currentItem;
            if (currentEditor) {
                currentEditor.showBuildPanel();
            }
            buildManager.executeCommand(appSettings.getBuildCommand(fileSystem.rootPath), fileSystem.rootPath);
        }
    }

    Action {
        id: runAction
        text: "Run"
        enabled: hasBuildConfiguration
        shortcut: "Ctrl+r"
        onTriggered: {
            var currentEditor = stackLayout.currentItem;
            if (currentEditor) {
                currentEditor.showBuildPanel();
            }
            buildManager.executeCommand(appSettings.getRunCommand(fileSystem.rootPath), fileSystem.rootPath);
        }
    }

    Action {
        id: indentAction
        text: qsTr("Indent")
        enabled: stackLayout.currentIndex !== -1
        shortcut: "Ctrl+i"
        onTriggered: {
            var currentEditor = stackLayout.currentItem;
            currentEditor.saveCursorPosition();
            currentEditor.format()
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
                onTriggered: toolManager.runCommand("git log --pretty=format:\"%H%x1f%an%x1f%ae%x1f%ad%x1f%s%n%b%x1e\" --date=rfc", fileSystem.rootPath)
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
        modelName: "💡" + appSettings.ollamaModel
        branchName: gitManager.currentBranch!=="" ?  "🌿 " + gitManager.currentBranch : ""
    }

    // --- REFACTORED MAIN CONTENT AREA ---
    // A single SplitView manages the three main panes.
    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        // Pane 1: File System (20% width)
        ColumnLayout {
            // Use attached properties to define the pane's size within the SplitView
            SplitView.preferredWidth: appWindow.width * 0.15
            SplitView.minimumWidth: 200 // Prevent the pane from becoming too small

            Label {
                text: "💻 " + fileSystem.rootName
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

        // Pane 2: Code Editor (55% width)
        ColumnLayout {
            SplitView.preferredWidth: appWindow.width * 0.55
            SplitView.minimumWidth: 250

            TabBar {
                id: tabBar
                width: parent.width
                currentIndex: documentManager.currentIndex
                onCurrentIndexChanged: documentManager.setCurrentIndex(currentIndex)

                Repeater {
                    model: documentManager.documents
                    TabButton {
                        text: model.fileName
                    }
                }
            }

            StackLayout {
                id: stackLayout
                width: parent.width
                height: parent.height - tabBar.height
                currentIndex: documentManager.currentIndex

                Repeater {
                    model: documentManager.documents
                    CodeEditorPane {
                        text: model.text
                        dirty: model.isDirty
                        onDirtyChanged: {
                            documentManager.markDirty(index)
                        }
                        onShowBuildPanelRequested: {
                            outputPanel.visible = true;
                        }
                    }
                }
            }

            Rectangle {
                id: outputPanel
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                visible: false
                color: appWindow.palette.window
                border.color: appWindow.palette.windowText

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 5

                    RowLayout {
                        Label {
                            text: "Build Output"
                            font.bold: true
                        }
                        Button {
                            text: "Close"
                            onClicked: outputPanel.visible = false
                            Layout.alignment: Qt.AlignRight
                        }
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Flickable {
                            id: flickable
                            clip: true
                            width: parent.width
                            TextArea {
                                id: outputArea
                                readOnly: true
                                width: parent.width
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                onTextChanged: {
                                    if (contentHeight > flickable.height) {
                                        flickable.contentY = contentHeight - flickable.height;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Pane 3: AI Section (40% width) - Refactored with Tabs
        OutputPane {
            id: aiOutputPane
            SplitView.preferredWidth: appWindow.width * 0.30
            SplitView.minimumWidth: 250
            currentEditor: stackLayout.currentItem
        }
    }

    function isCppFile(filePath) {
        return filePath.endsWith(".cpp") || filePath.endsWith(".h") || filePath.endsWith(".cxx") || filePath.endsWith(".hpp") || filePath.endsWith(".cc") || filePath.endsWith(".hh")
    }

    Connections {
        target: fileSystem
        function onRootPathChanged() {
            fileSystemView.model = fileSystem.model;
            var buildCommand = appSettings.getBuildCommand(fileSystem.rootPath);
            hasBuildConfiguration = buildCommand !== "";
        }
        function onFileSaved(filePath) {
            customStatusBar.text = qsTr("✅ File saved: %1").arg(filePath);
        }
    }

    Connections {
        target: documentManager
        function onFileOpened(filePath, content) {
            var currentEditor = stackLayout.currentItem;
            var localPath = filePath.toString().substring(7);
            syntaxHighlighterProvider.attachHighlighter(currentEditor.textDocument, localPath);
            if (isCppFile(localPath)) {
                lspClient.documentOpened(localPath, content);
            }
        }
    }

    Connections {
        target: buildManager
        function onOutputReady(output) {
            outputArea.text += output;
        }
        function onErrorReady(error) {
            outputArea.text += "❗" + error;
        }
        function onFinished() {
            outputArea.text += "\n✅ Ready.\n";
            console.log("Ready");
        }
    }

    Connections {
        target: llm
        function onResponseReady(response) {
            aiOutputPane.text = response;
            customStatusBar.text = qsTr("💬 AI response received.");
            if (stackLayout.currentIndex !== -1) {
                var currentEditor = stackLayout.currentItem;
                aiOutputPane.updateDiff(currentEditor.text);
            }
        }
        function onBusyChanged() {
            if (llm.busy) {
                customStatusBar.text = qsTr("✨ Processing AI request...");
            } else {
                customStatusBar.text = qsTr("✅ Ready");
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
                var currentEditor = stackLayout.currentItem;
                fileSystem.saveFile(saveAsDialog.selectedFile.toString().replace("file://", ""), currentEditor.text);
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
            var properties = {
                "command": command,
                "branchName": branch
            };
            if (command.startsWith("git log")) {
                properties.gitLogModel = gitLogModel;
            } else {
                properties.output = output;
            }

            var window = component.createObject(appWindow, properties);
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
            showGitOutput(command, output, branchName);
        }
        function onQmlFileIndented(formattedContent) {
            var currentEditor = stackLayout.currentItem;
            currentEditor.text = formattedContent;
            currentEditor.restoreCursorPosition();
        }
        function onGitLogReady(log) {
            gitLogModel.parseAndSetLog(log);
            showGitOutput("git log", "", ""); // We don't need to pass output here anymore
        }
    }

    Component.onCompleted: {
        fileSystem.setRootPath(fileSystem.homePath);
    }
}
