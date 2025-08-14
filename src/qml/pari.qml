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

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem { text: qsTr("Open"); action: openAction }
            MenuItem { text: qsTr("Save"); action: saveAction }
            MenuItem { text: qsTr("Save As..."); action: saveAsAction }
            MenuItem { text: qsTr("Exit"); onTriggered: Qt.exit(0) }
        }
        Menu {
            title: qsTr("Edit")
            MenuItem { text: qsTr("Cut") }
            MenuItem { text: qsTr("Copy") }
            MenuItem { text: qsTr("Paste") }
            MenuItem { text: qsTr("Settings..."); onTriggered: settingsDialog.show() }
        }
        Menu {
            title: qsTr("View")
            MenuItem { text: qsTr("Chat log"); onTriggered: chatLogWindow.show() }
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
                        text: (isDirectory ? "▶" : " ")
                        x: (root.depth * 10) + 5
                        rotation: expanded ? 90 : 0
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Image {
                        source: {
                            if (model.filePath == null) "qrc:/assets/file.png";
                            else if (model.filePath.endsWith(".cpp") || model.filePath.endsWith(".h")) "qrc:/assets/cpp.png";
                            else if (model.filePath.endsWith(".png")) "qrc:/assets/png.png";
                            else if (model.filePath.endsWith(".qml")) "qrc:/assets/qml.png";
                            else if (isDirectory) "qrc:/assets/folder.png";
                            else if (model.filePath.endsWith(".md")) "qrc:/assets/md.png";
                            else if (model.filePath.endsWith(".txt")) "qrc:/assets/txt.png";
                            else "qrc:/assets/file.png";
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
                                fileSystemView.selectedPath = model.filePath;
                            }
                        }
                    }
                }
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
            // ScrollView is necessary for when content exceeds the visible area.
            ScrollView {
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
                                    contentHeight: thinkingOutput.contentHeight
                                    clip: true
                                    TextArea {
                                        id: thinkingOutput
                                        width: parent.width
                                        readOnly: true
                                        text: aiPane.thinkingText
                                        color: "white"
                                        wrapMode: Text.WordWrap
                                        font.family: appSettings.fontFamily
                                        font.pointSize: appSettings.fontSize
                                        background: Rectangle { color: "transparent" }
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
                            readOnly: true
                            placeholderText: "Diff will appear here..."
                            wrapMode: Text.NoWrap
                            font.family: "monospace"
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
                    enabled: codeEditor.text !== "" && aiMessagePane.text !== ""
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

    SettingsWindow { id: settingsDialog }
    AboutWindow { id: aboutWindow }
    ChatLogWindow {
        id: chatLogWindow
        chatLlm: llm
    }

    Component.onCompleted: {
        fileSystem.setRootPath(fileSystem.homePath)
    }
}
