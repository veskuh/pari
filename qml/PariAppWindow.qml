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
    property var currentEditor: null
    property int goToLineNumber: -1

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
            documentManager.saveFile(stackLayout.currentIndex, appWindow.currentEditor.text);
        }
    }

    Action {
        id: saveAsAction
        text: qsTr("Save As...")
        shortcut: StandardKey.SaveAs
        enabled: stackLayout.currentIndex !== -1
        onTriggered: {
            saveAsDialog.open();
        }
    }

    Action {
        id: closeAction
        text: qsTr("Close")
        shortcut: StandardKey.Close
        enabled: stackLayout.currentIndex !== -1
        onTriggered: {
            if (stackLayout.currentIndex !== -1) {
                var currentDoc = documentManager.documents[stackLayout.currentIndex];
                if (currentDoc.isDirty) {
                    unsavedChangesDialog.open();
                } else {
                    closeCurrentFile();
                }
            }
        }
    }

    Action {
        id: findAction
        text: qsTr("Find")
        shortcut: StandardKey.Find
        enabled: stackLayout.currentIndex !== -1
        onTriggered: {
            appWindow.currentEditor.find();
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
            outputPanel.visible = true;
            buildManager.executeCommand(appSettings.getBuildCommand(fileSystem.rootPath), fileSystem.rootPath);
        }
    }

    Action {
        id: runAction
        text: "Run"
        enabled: hasBuildConfiguration
        shortcut: "Ctrl+r"
        onTriggered: {
            outputPanel.visible = true;
            buildManager.executeCommand(appSettings.getRunCommand(fileSystem.rootPath), fileSystem.rootPath);
        }
    }

    Action {
        id: indentAction
        text: qsTr("Indent")
        enabled: stackLayout.currentIndex !== -1
        shortcut: "Ctrl+i"
        onTriggered: {
            appWindow.currentEditor.saveCursorPosition();
            appWindow.currentEditor.format();
        }
    }
    Action {
        id: goToAction
        text: qsTr("Go to line..")
        enabled: stackLayout.currentIndex !== -1
        shortcut: "Ctrl+l"
        onTriggered: {
            goToLineDialog.x = appWindow.x + appWindow.width / 2 - goToLineDialog.width / 2;
            goToLineDialog.y = appWindow.y + appWindow.height / 2 - goToLineDialog.height / 2;
            goToLineDialog.open();
        }
    }

    Action {
        id: showAiPaneAction
        text: qsTr("Show AI Pane")
        shortcut: "Ctrl+shift+0"
        onTriggered: {
            aiOutputPane.visible = !aiOutputPane.visible;
        }
    }

    Action {
        id: showTreePaneAction
        text: qsTr("Show Filesystem")
        shortcut: "Ctrl+0"
        onTriggered: {
            treeColumn.visible = !treeColumn.visible;
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
                text: qsTr("Close")
                action: closeAction
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
            MenuItem {
                text: qsTr("Go to line...")
                action: goToAction
            }
            MenuSeparator {}
            MenuItem {
                text: qsTr("Show Files")
                action: showTreePaneAction
                checkable: true
                checked: treeColumn.visible
            }

            MenuItem {
                text: qsTr("Show AI")
                action: showAiPaneAction
                checkable: true
                checked: aiOutputPane.visible
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
            visible: true

            ToolButton {
                text: qsTr("Diff")
                icon.source: "qrc:/assets/diff.png"
                icon.width: 32
                icon.height: 32
                display: AbstractButton.TextUnderIcon
                width: 64
                enabled: aiOutputPane.text !== ""
                checkable: true
                onCheckedChanged: aiOutputPane.diffVisible = checked
            }
            /*
            ToolButton {
                text: qsTr("Use")
                icon.source: "qrc:/assets/accept.png"
                icon.width: 32
                icon.height: 32
                display: AbstractButton.TextUnderIcon
                width: 64
            }*/
        }

        PariTabBar {
            id: tabBar

            x: treeColumn.width
            width: codeColumn.width - 10

            onCurrentIndexChanged: {
                documentManager.setCurrentIndex(currentIndex);
                appWindow.currentEditor = editorRepeater.itemAt(stackLayout.currentIndex);
            }
            model: documentManager.documents
        }
    }

    footer: CustomStatusBar {
        id: customStatusBar
        modelName: "💡" + appSettings.ollamaModel
        branchName: gitManager.currentBranch !== "" ? "🌿 " + gitManager.currentBranch : ""
    }

    // --- REFACTORED MAIN CONTENT AREA ---
    // A single SplitView manages the three main panes.
    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        // Pane 1: File System (20% width)
        ColumnLayout {
            id: treeColumn
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
            id: codeColumn
            SplitView.preferredWidth: appWindow.width * 0.55
            SplitView.minimumWidth: 250

            StackLayout {
                id: stackLayout
                width: parent.width
                height: parent.height - tabBar.height
                currentIndex: documentManager.currentIndex
                visible: !outputPanel.expanded

                Repeater {
                    id: editorRepeater
                    model: documentManager.documents
                    CodeEditorPane {
                        text: model.text
                        dirty: model.isDirty
                        isActivePane: stackLayout.currentIndex === index
                        onDirtyChanged: {
                            documentManager.markDirty(index);
                        }
                    }
                }
            }

            Rectangle {
                id: outputPanel
                property bool expanded: false
                Layout.fillWidth: true
                Layout.preferredHeight: expanded ? codeColumn.height - 40 : 200
                visible: false
                color: appWindow.palette.window

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 5

                    RowLayout {
                        Label {
                            text: "Build Output"
                            font.bold: true
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        RowLayout {
                            Layout.alignment: Qt.AlignRight
                             ToolButton {
                                text: outputPanel.expanded? "➖" : "➕"
                                onClicked: {
                                    outputPanel.expanded = !outputPanel.expanded;
                                }
                            }
                            ToolButton {
                                text: "✖️"
                                onClicked: {
                                    outputPanel.visible = false;
                                    outputPanel.expanded = false;
                                }
                            }
                        }
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Flickable {
                            id: flickable
                            clip: true
                            contentHeight: outputArea.implicitHeight
                            width: parent.width
                            Text {
                                id: outputArea
                                color: palette.text
                                width: parent.width
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                textFormat: Text.MarkdownText
                                onLinkActivated: function (link) {
                                    var parts = link.split(":");
                                    if (parts.length > 0) {
                                        var filePath = parts[0];
                                        var lineNumber = -1;
                                        if (parts.length > 1) {
                                            lineNumber = parseInt(parts[1], 10);
                                        }

                                        if (fileSystem.fileExistsInProject(filePath)) {
                                            var absolutePath = fileSystem.getAbsolutePath(filePath);
                                            appWindow.goToLineNumber = lineNumber;
                                            fileSystem.loadFileContent(absolutePath);
                                        }
                                    }
                                }

                                onContentHeightChanged: {
                                    if (outputArea.contentHeight > flickable.height) {
                                        flickable.contentY = outputArea.contentHeight - flickable.height;
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
            currentEditor: appWindow.currentEditor
        }
    }

    function isCppFile(filePath) {
        return filePath.endsWith(".cpp") || filePath.endsWith(".h") || filePath.endsWith(".cxx") || filePath.endsWith(".hpp") || filePath.endsWith(".cc") || filePath.endsWith(".hh");
    }

    function formatOutput(text) {
        var lines = text.split('\n');
        var formattedText = "";
        var pathRegex = /([\w/.-]+)(?::(\d+))?(?::(\d+))?/g;

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i];
            var result = "";
            var lastIndex = 0;
            var match;
            pathRegex.lastIndex = 0; // Reset regex state
            while ((match = pathRegex.exec(line)) !== null) {
                if (fileSystem.fileExistsInProject(match[1])) {
                    var filePath = match[1];
                    var lineNumber = match[2] ? match[2] : -1;
                    var link = filePath + ":" + lineNumber;
                    result += line.substring(lastIndex, match.index);
                    result += `[${match[0]}](${link})`;
                    lastIndex = match.index + match[0].length;
                }
            }
            if (lastIndex === 0) {
                result = line;
            } else {
                result += line.substring(lastIndex);
            }
            formattedText += result;
            if (i < lines.length - 1) {
                formattedText += '\n';
            }
        }
        return formattedText;
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
        function onFileContentReady(filePath, content) {
            documentManager.openFile(filePath, content);
        }
    }

    Connections {
        target: documentManager
        function onFileOpened(filePath, content) {
            outputPanel.expanded = false;
            Qt.callLater(function () {
                appWindow.currentEditor = editorRepeater.itemAt(stackLayout.currentIndex);
                if (appWindow.currentEditor) {
                    var localPath = filePath.toString().substring(7);
                    syntaxHighlighterProvider.attachHighlighter(appWindow.currentEditor.textDocument, localPath);
                    if (isCppFile(localPath)) {
                        lspClient.documentOpened(localPath, content);
                    }
                    if (appWindow.goToLineNumber > -1) {
                        appWindow.currentEditor.goToLine(appWindow.goToLineNumber);
                        appWindow.goToLineNumber = -1;
                    }
                }
                tabBar.currentIndex = stackLayout.currentIndex;
            });
        }
    }

    Connections {
        target: buildManager
        function onOutputReady(output) {
            outputArea.text += "\n" + formatOutput(output);
        }
        function onErrorReady(error) {
            outputArea.text += "\n❗" + formatOutput(error); // "❗" +
        }
        function onFinished() {
            outputArea.text += "\n✅ Ready.\n"; //
            console.log("Ready");
        }
    }

    Connections {
        target: llm
        function onResponseReady(response) {
            aiOutputPane.text = response;
            customStatusBar.text = qsTr("💬 AI response received.");
            if (stackLayout.currentIndex !== -1) {
                aiOutputPane.updateDiff(appWindow.currentEditor.text);
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
                fileSystem.saveFile(saveAsDialog.selectedFile.toString().replace("file://", ""), appWindow.currentEditor.text);
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

    GoToLineDialog {
        id: goToLineDialog
        onGoToLine: function (lineNumber) {
            if (appWindow.currentEditor) {
                appWindow.currentEditor.goToLine(lineNumber);
            }
        }
    }

    GitOutputWindow {
        id: gitOutputWindow
    }

    MessageDialog {
        id: unsavedChangesDialog
        title: qsTr("Unsaved Changes")
        text: qsTr("The current file has unsaved changes. Do you want to save them?")
        buttons: MessageDialog.Save | MessageDialog.Discard | MessageDialog.Cancel
        onAccepted: {
            if (result === MessageDialog.Save) {
                documentManager.saveFile(stackLayout.currentIndex, appWindow.currentEditor.text);
                closeCurrentFile();
            } else if (result === MessageDialog.Discard) {
                closeCurrentFile();
            }
        }
        onRejected: {
            // Do nothing
        }



    }

    function closeCurrentFile() {
        if (stackLayout.currentIndex !== -1) {
            documentManager.closeFile(stackLayout.currentIndex);
        }
    }

    function showGitOutput(command, output, branch) {
        gitOutputWindow.command = command;
        gitOutputWindow.branchName = branch;
        if (command.startsWith("git log")) {
            gitOutputWindow.gitLogModel = gitLogModel;
        } else {
            gitOutputWindow.output = output;
        }
        gitOutputWindow.show();
    }

    Connections {
        target: toolManager
        function onOutputReady(command, output, branchName) {
            showGitOutput(command, output, branchName);
        }
        function onQmlFileIndented(formattedContent) {
            appWindow.currentEditor.text = formattedContent;
            appWindow.currentEditor.restoreCursorPosition();
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
