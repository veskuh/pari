import QtQuick
import Qt.labs.settings 1.0
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs

import net.veskuh.pari 1.0
import "FileUtils.js" as FileUtils
import "FormattingUtils.js" as FormattingUtils

ApplicationWindow {
    id: appWindow

    GitLogModel {
        id: gitLogModel
    }

    property bool hasBuildConfiguration: false
    property var currentEditor: null
    property int goToLineNumber: -1
    property alias fileSystemView: fileSystemView

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
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            // Position based on the tree column width
            x: treeColumn.width
            width: codeColumn.width - 10

            onTabClicked: function(index) { appWindow.setEditorIndex(index) }
            model: documentManager.documents
        }

        Row {
            id: rightButtons
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 56
            rightPadding: 5

            PariToolButton {
                text: qsTr("Diff")
                iconSource: "qrc:/assets/diff.png"
                enabled: aiOutputPane.text !== ""
                checkable: true
                checked: aiOutputPane.diffVisible
                onClicked: aiOutputPane.diffVisible = !aiOutputPane.diffVisible
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
        } else if (documentManager.documents.length === 0) {
            fileSystemView.selectedPath = "";
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
                visible: !outputPanel.expanded && documentManager.documents.length > 0

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
                visible: !outputPanel.expanded && documentManager.documents.length === 0
            }

            PariPaperWell {
                id: outputPanel
                property bool expanded: false
                Layout.fillWidth: true
                Layout.preferredHeight: expanded ? codeColumn.height - 40 : 200
                visible: false

                content: ColumnLayout {
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

        OutputPane {
            id: aiOutputPane
            SplitView.preferredWidth: appWindow.width * 0.30
            SplitView.minimumWidth: 250
            currentEditor: appWindow.currentEditor
            diffUtils: DiffUtils {}
        }    }

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
        if (command.startsWith("git log")) {
            dialogs.gitOutputWindow.gitLogModel = gitLogModel;
        } else {
            dialogs.gitOutputWindow.output = output;
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
        stackLayout: stackLayout
        dialogs: dialogs
    }
}
