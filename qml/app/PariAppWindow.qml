import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs

import net.veskuh.pari 1.0
import "../filetree"
import "../editor"
import "../common"
import "../ai"
import "../utils/FileUtils.js" as FileUtils
import "../utils/FormattingUtils.js" as FormattingUtils

ApplicationWindow {
    id: appWindow

    PariTheme {
        id: pariTheme
    }

    Settings {
        id: windowSettings
        category: "window"
        property alias x: appWindow.x
        property alias y: appWindow.y
        property alias width: appWindow.width
        property alias height: appWindow.height
    }

    GitLogModel {
        id: gitLogModel
    }

    property bool hasBuildConfiguration: false
    property var currentEditor: null
    property int goToLineNumber: -1
    property alias fileSystemView: fileSystemView
    property alias aiOutputPane: aiOutputPane
    property alias aiColumn: aiColumn
    property alias treeColumn: treeColumn

    minimumWidth: 800
    minimumHeight: 480

    visible: true

    // --- REFACTORED MAIN CONTENT AREA ---
    // A single SplitView manages the three main panes.
    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        handle: Rectangle {
            implicitWidth: 1
            implicitHeight: 1
            color: pariTheme.sidebarBorder
        }

        // Pane 1: File System (20% width)
        Rectangle {
            id: treeColumn
            SplitView.preferredWidth: appWindow.width * 0.15
            SplitView.minimumWidth: 200
            color: pariTheme.sidebarBg

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Label {
                    text: "💻 " + fileSystem.rootName
                    font.bold: true
                    Layout.leftMargin: 10
                    Layout.topMargin: 5
                    Layout.bottomMargin: 5
                    color: pariTheme.textColor
                }

                TreeView {
                    id: fileSystemView
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    model: fileSystem.model
                    property string selectedPath: ""

                    delegate: FileTreeDelegate { mainWindow: appWindow }
                }
                Connections {
                    target: fileSystemView
                    function onModelChanged() {
                        fileSystemView.rootIndex = fileSystem.currentRootIndex;
                    }
                }
            }

            // Etched right border
            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: pariTheme.sidebarBorder
            }
        }

        // Pane 2: Code Editor (55% width)
        SplitView {
            id: codeColumn
            orientation: Qt.Vertical
            SplitView.preferredWidth: appWindow.width * 0.55
            SplitView.minimumWidth: 250

            handle: Rectangle {
                implicitWidth: 1
                implicitHeight: 1
                color: pariTheme.sidebarBorder
            }

            ColumnLayout {
                spacing: 0
                SplitView.fillWidth: true
                SplitView.fillHeight: true
                SplitView.minimumHeight: 100

                StackLayout {
                    id: stackLayout
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: documentManager.currentIndex
                    visible: documentManager.documents.length > 0

                    Repeater {
                        id: editorRepeater
                        model: documentManager.documents

                        CodeEditorPane {
                            id: editor
                            text: model.text
                            dirty: model.isDirty
                            filePath: model.filePath
                            isActivePane: stackLayout.currentIndex === index
                            textDocumentSearcher: TextDocumentSearcher {}
                            injectedLspClient: lspClient

                            onIsActivePaneChanged: {
                                if (isActivePane) {
                                    tabBar.currentIndex = index
                                    appWindow.currentEditor = editor
                                    fileSystem.currentFilePath = filePath
                                    fileSystemView.selectedPath = filePath
                                }
                            }

                            onTextChangedByUser: {
                                documentManager.markDirty(index);
                            }
                            Component.onCompleted: {
                                syntaxHighlighterProvider.attachHighlighter(textDocument, model.filePath);
                                if (FileUtils.isCppFile(model.filePath)) {
                                    lspClient.documentOpened(model.filePath, model.text);
                                }
                            }
                        }
                    }
                }

                EmptyEditorState {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: documentManager.documents.length === 0
                }
            }

            PariPaperWell {
                id: outputPanel
                property bool expanded: false
                SplitView.fillWidth: true
                SplitView.preferredHeight: expanded ? codeColumn.height - 40 : codeColumn.height * 0.20
                SplitView.minimumHeight: expanded ? codeColumn.height - 40 : 100
                SplitView.maximumHeight: expanded ? codeColumn.height - 40 : codeColumn.height * 0.5
                visible: false

                content: ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 5

                    RowLayout {
                        Label {
                            text: "Build Output"
                            font.bold: true
                            color: pariTheme.textColor
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
                                color: pariTheme.textColor
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

        // Pane 3: AI Section (30% width)
        Rectangle {
            id: aiColumn
            SplitView.preferredWidth: appWindow.width * 0.30
            SplitView.minimumWidth: 250
            color: pariTheme.sidebarBg

            // Etched left border
            Rectangle {
                anchors.left: parent.left
                width: 1
                height: parent.height
                color: pariTheme.sidebarBorder
            }

            OutputPane {
                id: aiOutputPane
                anchors.fill: parent
                anchors.leftMargin: 1 // Don't overlap the border
                currentEditor: appWindow.currentEditor
                diffUtils: DiffUtils {}
            }
        }
    }

    PariActions {
        id: actions
        rootWindow: appWindow
        dialogs: dialogs
        stackLayout: stackLayout
        outputPanel: outputPanel
        outputArea: outputArea
        gitLogModel: gitLogModel
        hasBuildConfiguration: appWindow.hasBuildConfiguration
        onCloseCurrentFile: appWindow.closeCurrentFile()
    }

    menuBar: PariMenuBar {
        actions: actions
        dialogs: dialogs
        gitLogModel: gitLogModel
    }

    header: PariToolBar {
        id: customToolBar
        implicitHeight: 64
        
        Row {
            id: leftButtons
            spacing: 5
            height: 56
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 5

            PariToolButton {
                text: qsTr("Build")
                iconSource: "qrc:/assets/build.png"
                action: actions.buildAction
            }
            PariToolButton {
                text: qsTr("Run")
                iconSource: "qrc:/assets/play.png"
                action: actions.runAction
            }
            PariToolButton {
                text: qsTr("Search")
                iconSource: "qrc:/assets/search.png"
                action: actions.findAction
            }
        }

        PariTabBar {
            id: tabBar
            anchors.left: leftButtons.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 10
            model: documentManager.documents
            onTabClicked: (index) => setEditorIndex(index)
            onCloseTab: (index) => {
                var doc = documentManager.documents[index];
                if (doc.isDirty) {
                    dialogs.targetIndex = index;
                    dialogs.unsavedChangesDialog.open();
                } else {
                    documentManager.closeFile(index);
                    setEditorIndex(documentManager.currentIndex);
                }
            }
        }
    }

    function setEditorIndex(index) {
        tabBar.currentIndex = index
        documentManager.setCurrentIndex(index);
        
        // Synchronize File Tree highlight with the active document
        if (index >= 0 && index < documentManager.documents.length) {
            var doc = documentManager.documents[index];
            fileSystemView.selectedPath = doc.filePath;
            fileSystem.currentFilePath = doc.filePath;
        } else if (documentManager.documents.length === 0) {
            fileSystemView.selectedPath = "";
            fileSystem.currentFilePath = "";
        }
    }

    footer: CustomStatusBar {
        id: customStatusBar
        text: qsTr("✅ Ready")
        modelName: (typeof appSettings !== 'undefined') ? appSettings.ollamaModel : ""
        branchName: (typeof gitManager !== 'undefined') ? gitManager.currentBranch : ""
    }

    PariDialogs {
        id: dialogs
        onSaveConfiguration: (buildCommand, runCommand, cleanCommand) => {
            appSettings.setBuildCommands(fileSystem.rootPath, buildCommand, runCommand, cleanCommand);
            hasBuildConfiguration = buildCommand !== "";
        }
        onGoToLine: (lineNumber) => {
            if (appWindow.currentEditor) {
                appWindow.currentEditor.goToLine(lineNumber);
            }
        }
        onDiscardChanges: (index) => closeCurrentFile(index)
        onSaveAndClose: (index) => {
            var doc = documentManager.documents[index];
            if (doc) {
                var text = (index === stackLayout.currentIndex) ? appWindow.currentEditor.text : doc.text;
                documentManager.saveFile(index, text);
            }
            closeCurrentFile(index);
        }

        fileDialog.onAccepted: {
            if (dialogs.fileDialog.folder) {
                const folderPath = dialogs.fileDialog.folder.toString().replace("file://", "");
                fileSystem.setRootPath(folderPath);
                appSettings.addRecentFolder(folderPath);
            }
        }

        saveAsDialog.onAccepted: {
            if (dialogs.saveAsDialog.file) {
                fileSystem.saveFile(dialogs.saveAsDialog.file.toString().replace("file://", ""), appWindow.currentEditor.text);
            }
        }
    }

    function closeCurrentFile(index) {
        var targetIndex = (typeof index !== 'undefined' && index !== -1) ? index : stackLayout.currentIndex;
        if (targetIndex !== -1) {
            documentManager.closeFile(targetIndex);
            // Synchronize selection with the new current document
            setEditorIndex(documentManager.currentIndex);
        }
    }

    function showGitOutput(command, output, branch) {
        dialogs.gitOutputWindow.command = command;
        dialogs.gitOutputWindow.branchName = branch;
        dialogs.gitOutputWindow.output = output !== "" ? output : qsTr("No output (empty diff or no changes).");
        if (command.startsWith("git log")) {
            dialogs.gitOutputWindow.gitLogModel = gitLogModel;
        } else {
            dialogs.gitOutputWindow.gitLogModel = null;
        }
        dialogs.gitOutputWindow.show();
    }

    Component.onCompleted: {
        fileSystem.setRootPath(fileSystem.homePath);
    }

    AppLogic {
        id: appLogic
        rootWindow: appWindow
        customStatusBar: customStatusBar
        outputArea: outputArea
        aiOutputPane: aiOutputPane
        gitLogModel: gitLogModel
        blameModelBackend: gitBlameModel
        injectedGitManager: gitManager
        stackLayout: stackLayout
        dialogs: dialogs
    }
}
