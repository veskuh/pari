import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs
import net.veskuh.pari 1.0

ApplicationWindow {
    id: appWindow

    DiffUtils {
        id: diffUtils
    }

    TextDocumentSearcher {
        id: textDocumentSearcher
    }

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

    Action {
        id: findAction
        text: qsTr("Find")
        shortcut: StandardKey.Find
        onTriggered: findOverlay.open()
    }

    Action {
        id: configureBuildAction
        text: "Build setup..."
        onTriggered: {
            buildConfigurationWindow.buildCommand = appSettings.getBuildCommand(fileSystem.rootPath)
            buildConfigurationWindow.runCommand = appSettings.getRunCommand(fileSystem.rootPath)
            buildConfigurationWindow.cleanCommand = appSettings.getCleanCommand(fileSystem.rootPath)
            buildConfigurationWindow.visible = true
        }
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem { text: qsTr("Open"); action: openAction }
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
            MenuItem { text: qsTr("Save"); action: saveAction }
            MenuItem { text: qsTr("Save As..."); action: saveAsAction }
            MenuItem { text: qsTr("Exit"); onTriggered: Qt.exit(0) }
        }
        Menu {
            title: qsTr("Edit")
            MenuItem { text: qsTr("Cut") }
            MenuItem { text: qsTr("Copy") }
            MenuItem { text: qsTr("Paste") }
            MenuItem { text: qsTr("Find"); action: findAction }
            MenuItem { text: qsTr("Settings..."); onTriggered: settingsDialog.show() }
        }
        Menu {
            title: qsTr("View")
            MenuItem { text: qsTr("Chat log"); onTriggered: chatLogWindow.show() }
        }
        Menu {
            title: qsTr("Build")
            MenuItem {
                id: buildAction
                text: "Build"
                enabled: hasBuildConfiguration
                onTriggered: {
                    outputArea.text = ""
                    outputPanel.visible = true
                    buildManager.executeCommand(appSettings.getBuildCommand(fileSystem.rootPath), fileSystem.rootPath)
                }
            }
            MenuItem {
                id: runAction
                text: "Run"
                enabled: hasBuildConfiguration
                onTriggered: {
                    outputArea.text = ""
                    outputPanel.visible = true
                    buildManager.executeCommand(appSettings.getRunCommand(fileSystem.rootPath), fileSystem.rootPath)
                }
            }
            MenuItem {
                id: cleanAction
                text: "Clean"
                enabled: hasBuildConfiguration
                onTriggered: {
                    outputArea.text = ""
                    outputPanel.visible = true
                    buildManager.executeCommand(appSettings.getCleanCommand(fileSystem.rootPath), fileSystem.rootPath)
                }
            }
            MenuSeparator {}
            MenuItem {
                action: configureBuildAction
            }
        }
        Menu {
            title: qsTr("Help")
            MenuItem { text: qsTr("About"); onTriggered: aboutWindow.show() }
        }
    }

    header: ToolBar {
        RowLayout {
            ToolButton { text: qsTr("Open"); action: openAction }
            ToolButton { text: qsTr("Save"); action: saveAction }
            ToolButton { text: qsTr("Build") }
        }
    }

    footer: CustomStatusBar {
        id: customStatusBar
        modelName: appSettings.ollamaModel
    }

    function updateDiff() {
        if (codeEditor.text.length > 0 && aiOutputPane.text.length > 0) {
            const diff = diffUtils.createDiff(codeEditor.text, aiOutputPane.text)
            diffView.text = diff
        } else {
            diffView.text = ""
        }
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
                    fileSystemView.rootIndex = fileSystem.currentRootIndex
                }
            }
        }

        // Pane 2: Code Editor (40% width)
        ColumnLayout {
            SplitView.preferredWidth: appWindow.width * 0.40
            SplitView.minimumWidth: 250

            Label {
                text: qsTr("Code Editor")
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 5
                Layout.bottomMargin: 5
            }

            FindOverlay {
                id: findOverlay
                width: parent.width
                color: appWindow.palette.window
                borderColor: appWindow.palette.windowText
                textColor: appWindow.palette.text
                textBackgroundColor: appWindow.palette.base
                onFindNext: {
                    var newPos = textDocumentSearcher.find(codeEditor.textDocument, findOverlay.searchText, codeEditor.cursorPosition, 0)
                    if (newPos !== -1) {
                        codeEditor.cursorPosition = newPos;
                        codeEditor.select(newPos-searchText.length, newPos)
                    }
                    var occurrences = codeEditor.text.split(findOverlay.searchText).length - 1;
                    findOverlay.updateResults(occurrences);
                }

                onFindPrevious: {
                    var oldPos = codeEditor.cursorPosition
                    var newPos = textDocumentSearcher.find(codeEditor.textDocument, findOverlay.searchText, codeEditor.cursorPosition, 1)
                    if (codeEditor.cursorPosition === newPos) {
                        newPos = textDocumentSearcher.find(codeEditor.textDocument, findOverlay.searchText, codeEditor.cursorPosition-findOverlay.searchText.length, 1)
                    }

                    if (newPos !== -1) {
                        codeEditor.cursorPosition = newPos;
                        codeEditor.select(newPos-searchText.length, newPos)
                    }
                    var occurrences = codeEditor.text.split(findOverlay.searchText).length - 1;
                    findOverlay.updateResults(occurrences);
                }
                onCloseOverlay: close()
            }

            // ScrollView is necessary for when content exceeds the visible area.
            ScrollView {
                id: codeEditorScrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true // Ensures content doesn't draw outside the ScrollView



                TextArea {
                    id: codeEditor
                    placeholderText: "Open a file or start typing..."
                    wrapMode: Text.WordWrap
                    font.family: appSettings.fontFamily
                    font.pointSize: appSettings.fontSize
                    tabStopDistance: 4 * textMetrics.advanceWidth
                    onTextChanged: updateDiff()

                    TextMetrics {
                        id: textMetrics
                        font: codeEditor.font
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
                        TextArea {
                            id: outputArea
                            readOnly: true
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        // Pane 3: AI Section (40% width) - Refactored with Tabs
        ColumnLayout {
            id: aiPane // Keep the ID for isThinking property
            property bool isThinking: false
            property string thinkingText: ""

            SplitView.preferredWidth: appWindow.width * 0.40
            SplitView.minimumWidth: 250

            TabBar {
                id: rightSideTabBar
                Layout.fillWidth: true
                currentIndex: 0
                TabButton {
                    text: qsTr("AI Output")
                }
                TabButton {
                    text: qsTr("Diff View")
                }
            }

            StackLayout {
                id: rightSideStackLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: rightSideTabBar.currentIndex

                // Pane for AI Output
                Item {
                    id: aiOutputItem
                    ScrollView {
                        id: aiOutputScrollView
                        width: aiOutputItem.width
                        height: aiOutputItem.height
                        clip: true

                        TextArea {
                            id: aiOutputPane
                            readOnly: true
                            placeholderText: "AI assistant output will appear here..."
                            wrapMode: Text.WordWrap
                            textFormat: Text.MarkdownText
                        }
                    }

                    // Thinking Overlay
                    Rectangle {
                        id: thinkingOverlay
                        anchors.fill: parent
                        color: "#AA000000"
                        opacity: aiPane.isThinking ? 1.0 : 0.0
                        visible: opacity > 0.01
                        z: 10
                        Behavior on opacity { PropertyAnimation { duration: 500; easing.type: Easing.InOutQuad } }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            Label { text: "Thinking..."; font.bold: true; color: "white" }
                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                Flickable {
                                    id: flickable
                                    clip: true
                                    Text {
                                        id: thinkingOutput
                                        width: parent.width

                                        text: aiPane.thinkingText
                                        color: "white"
                                        wrapMode: Text.WordWrap
                                        font.family: appSettings.fontFamily
                                        font.pointSize: appSettings.fontSize
                                        onTextChanged: {
                                            if (contentHeight > flickable.height) {
                                                flickable.contentY = contentHeight - flickable.height
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Pane for Diff View
                Item {
                    id: diffViewItem
                    ScrollView {
                        width: diffViewItem.width
                        height: diffViewItem.height
                        clip: true
                        TextArea {
                            id: diffView
                            textFormat: Text.RichText
                            readOnly: true
                            placeholderText: "Diff will appear here..."
                            wrapMode: Text.NoWrap
                            font.family: "Courier"
                        }
                    }
                }
            }

            // AI Input Controls - Placed below the tab view
            Label {
                text: qsTr("AI Prompt")
                font.bold: true
                Layout.topMargin: 10
                Layout.leftMargin: 5
            }
            TextArea {
                id: aiMessagePane
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                Layout.minimumHeight: 50
                wrapMode: Text.WordWrap
                placeholderText: "Type a prompt or select a command..."
            }
            RowLayout {
                Layout.topMargin: 5
                Layout.alignment: Qt.AlignRight

                ComboBox {
                    id: promptComboBox
                    model: ["Comment the code", "Explain the code", "Refactor the code", "Write unit tests"]
                    onCurrentTextChanged: {
                        var prompt = ""
                        switch (currentIndex) {
                            case 0: prompt = "Add comments to the following code. Do not add any other text, just the commented code."; break;
                            case 1: prompt = "Explain the following code in a clear and concise way. Focus on the overall purpose of the code and the role of each major component."; break;
                            case 2: prompt = "Refactor the following code to improve its readability, performance, and maintainability. Do not add any new functionality."; break;
                            case 3: prompt = "Write unit tests for the following code. Use the Qt Test framework and cover all major functionality."; break;
                        }
                        aiMessagePane.text = prompt
                    }
                }
                Button {
                    text: "Send"
                    enabled: codeEditor.text !== "" && aiMessagePane.text !== "" && !llm.busy
                    onClicked: {
                        aiOutputPane.text = ""; // Clear previous output
                        diffView.text = ""; // Clear previous diff
                        var prompt = aiMessagePane.text
                        llm.sendPrompt("You are AI code assistant. Follow the instructions given for the code in the end of message. Be short in your response, no chatting or politness, just code or comment. " + prompt + "\n```\n" + codeEditor.text + "\n```");
                    }
                    highlighted: true
                }
            }
        }
    }

    Connections {
        target: buildManager
        function onOutputReady(output) {
            outputArea.text += output
        }
        function onErrorReady(error) {
            outputArea.text += error
        }
    }

   Connections {
        target: fileSystem
        function onRootPathChanged() {
            fileSystemView.model = fileSystem.model
        }
        function onFileContentReady(filePath, content) {
            codeEditor.text = content;
            syntaxHighlighterProvider.attachHighlighter(codeEditor.textDocument, filePath);
        }
        function onFileSaved(filePath) { customStatusBar.text = qsTr("File saved: %1").arg(filePath) }
    }

    Connections {
        target: llm
        function onResponseReady(response) {
            aiOutputPane.text = response;
            customStatusBar.text = qsTr("AI response received.");
            updateDiff();
        }
        function onBusyChanged() {
            if (llm.busy) {
                customStatusBar.text = qsTr("Processing AI request...");
            } else {
                customStatusBar.text = qsTr("Ready");
                // When AI is done, update the diff
                updateDiff();
            }
        }
        function onNewLineReceived(line) {
            var currentLine = line;
            while (currentLine.length > 0) {
                if (aiPane.isThinking) {
                    var endThinkIndex = currentLine.indexOf("</think>");
                    if (endThinkIndex !== -1) {
                        aiPane.thinkingText += currentLine.substring(0, endThinkIndex);
                        aiPane.thinkingText += "<br>"
                        aiPane.isThinking = false;
                        currentLine = currentLine.substring(endThinkIndex + 8);
                    } else {
                        aiPane.thinkingText += currentLine;

                        if (currentLine.trim()!=="") {
                            aiPane.thinkingText += "\n\n";
                        }

                        currentLine = "";
                    }
                } else {
                    var startThinkIndex = currentLine.indexOf("<think>");
                    if (startThinkIndex !== -1) {
                        aiOutputPane.text += currentLine.substring(0, startThinkIndex);
                        aiPane.isThinking = true;
                        aiPane.thinkingText = ""; // Clear previous thinking
                        currentLine = currentLine.substring(startThinkIndex + 7);
                    } else {
                        aiOutputPane.text += currentLine;
                        currentLine = "";
                    }
                }
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
                fileSystem.saveFile(saveAsDialog.selectedFile.toString().replace("file://", ""), codeEditor.text)
            }
        }
    }

    SettingsWindow { id: settingsDialog }
    AboutWindow { id: aboutWindow }
    ChatLogWindow {
        id: chatLogWindow
        chatLlm: llm
    }

    property bool hasBuildConfiguration: false

    Connections {
        target: fileSystem
        function onRootPathChanged() {
            var buildCommand = appSettings.getBuildCommand(fileSystem.rootPath)
            hasBuildConfiguration = buildCommand !== ""
        }
    }

    BuildConfigurationDialog {
        id: buildConfigurationWindow
        onSaveConfiguration: function(buildCommand, runCommand, cleanCommand) {
            appSettings.setBuildCommands(fileSystem.rootPath, buildCommand, runCommand, cleanCommand)
            hasBuildConfiguration = buildCommand !== ""
        }
    }

    Component.onCompleted: {
        fileSystem.setRootPath(fileSystem.homePath)
    }
}
