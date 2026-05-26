import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs

import net.veskuh.pari 1.0
import "../sidebar"
import "../editor"
import "../common"
import "../ai"
import "../utils/FileUtils.js" as FileUtils
import "../utils/FormattingUtils.js" as FormattingUtils

ApplicationWindow {
    id: appWindow

    title: {
        var baseTitle = "Pari";
        if (currentEditor && currentEditor.filePath) {
            var fileName = currentEditor.filePath.substring(currentEditor.filePath.lastIndexOf('/') + 1);
            return (currentEditor.dirty ? "* " : "") + fileName + " - " + baseTitle;
        }
        return baseTitle;
    }

    property bool forceClose: false

    onClosing: (close) => {
        if (forceClose) {
            close.accepted = true;
            return;
        }
        var hasDirty = false;
        for (var i = 0; i < documentManager.documents.length; i++) {
            if (documentManager.documents[i].isDirty) {
                hasDirty = true;
                break;
            }
        }
        if (hasDirty) {
            close.accepted = false;
            dialogs.quitConfirmationDialog.open();
        }
    }

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
    property alias sidebarStack: sidebarStack

    minimumWidth: 800
    minimumHeight: 480

    visible: true

    // --- REFACTORED MAIN CONTENT AREA ---
    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        handle: Rectangle {
            implicitWidth: 1
            implicitHeight: 1
            color: pariTheme.sidebarBorder
        }

        // Pane 1: Sidebar
        Rectangle {
            id: treeColumn
            SplitView.preferredWidth: appWindow.width * 0.18
            SplitView.minimumWidth: 250
            color: pariTheme.sidebarBg

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 1. SIDEBAR TAB BAR (Unified Metallic)
                PariSidebarTabBar {
                    id: sidebarTabBar
                    Layout.fillWidth: true
                    currentIndex: sidebarStack.currentIndex
                    model: [
                        { text: qsTr("Explorer"), icon: "qrc:/assets/folder.png" },
                        { text: qsTr("Search"), icon: "qrc:/assets/search.png" }
                    ]
                    onTabClicked: (index) => sidebarStack.currentIndex = index
                }

                // 2. Main Sidebar Content
                StackLayout {
                    id: sidebarStack
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: 0

                    // Explorer View
                    ColumnLayout {
                        spacing: 0
                        Label {
                            text: qsTr("EXPLORER")
                            font.pixelSize: 10
                            font.bold: true
                            Layout.leftMargin: 10
                            Layout.topMargin: 10
                            Layout.bottomMargin: 4
                            color: pariTheme.textColor
                            opacity: 0.6
                        }
                        Label {
                            text: "💻 " + fileSystem.rootName
                            font.bold: true
                            Layout.leftMargin: 10
                            Layout.bottomMargin: 8
                            color: pariTheme.textColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        TreeView {
                            id: fileSystemView
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            model: fileSystem.model
                            property string selectedPath: ""
                            delegate: FileTreeDelegate { mainWindow: appWindow }
                            columnWidthProvider: function(column) {
                                return column === 0 ? width : 0;
                            }
                            onWidthChanged: forceLayout()
                            ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }
                        }
                        Connections {
                            target: fileSystemView
                            function onModelChanged() {
                                fileSystemView.rootIndex = fileSystem.currentRootIndex;
                            }
                        }
                    }

                    // Search View
                    GlobalSearchPane {
                        id: searchPane
                        onResultClicked: (path, line) => {
                            appWindow.goToLineNumber = line;
                            documentManager.openFile(path, false);
                        }
                    }
                }
            }

            // Etched right border for the whole sidebar
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
                            injectedLspClient: lspClient
                            readonly property var docModel: model

                            onFilePathChanged: {
                                if (isActivePane) {
                                    fileSystem.currentFilePath = filePath;
                                    fileSystemView.selectedPath = filePath;
                                }
                            }

                            onIsActivePaneChanged: {
                                if (isActivePane) {
                                    tabBar.currentIndex = index
                                    appWindow.currentEditor = editor
                                    fileSystem.currentFilePath = filePath
                                    fileSystemView.selectedPath = filePath
                                } else {
                                    if (docModel && (!editor.searchManager || !editor.searchManager.filterActive)) {
                                        if (docModel.text !== editor.text) {
                                            docModel.text = editor.text;
                                        }
                                    }
                                }
                            }

                            Component.onDestruction: {
                                if (docModel && (!editor.searchManager || !editor.searchManager.filterActive)) {
                                    if (docModel.text !== editor.text) {
                                        docModel.text = editor.text;
                                    }
                                }
                                if (typeof lspClient !== 'undefined' && lspClient && FileUtils.isCppFile(filePath)) {
                                    var isStillOpen = false;
                                    for (var i = 0; i < documentManager.documents.length; i++) {
                                        if (documentManager.documents[i].filePath === filePath) {
                                            isStillOpen = true;
                                            break;
                                        }
                                    }
                                    if (!isStillOpen) {
                                        lspClient.documentClosed(filePath);
                                    }
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

            BuildOutputPanel {
                id: outputPanel
                SplitView.fillWidth: true
                SplitView.preferredHeight: expanded ? codeColumn.height - 40 : codeColumn.height * 0.20
                SplitView.minimumHeight: expanded ? codeColumn.height - 40 : 100
                SplitView.maximumHeight: expanded ? codeColumn.height - 40 : codeColumn.height * 0.5
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
                anchors.leftMargin: 1 
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
        outputArea: outputPanel.outputArea
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
            x: codeColumn.x
            width: codeColumn.width
            anchors.top: parent.top
            anchors.bottom: parent.bottom
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
        onSaveAllAndQuit: {
            for (var i = 0; i < documentManager.documents.length; i++) {
                var doc = documentManager.documents[i];
                if (doc.isDirty) {
                    var text = (i === stackLayout.currentIndex) ? appWindow.currentEditor.text : doc.text;
                    documentManager.saveFile(i, text);
                }
            }
            appWindow.forceClose = true;
            Qt.quit();
        }
        onDiscardAllAndQuit: {
            appWindow.forceClose = true;
            Qt.quit();
        }
        onResultClicked: (path, line) => {
            appWindow.goToLineNumber = line;
            var fullPath = path;
            if (path !== "" && !path.startsWith("/")) {
                fullPath = fileSystem.rootPath + "/" + path;
            }
            documentManager.openFile(fullPath, false);
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
            setEditorIndex(documentManager.currentIndex);
        }
    }

    property var gitWindows: []
    property int lastWindowOffset: 0

    function showGitOutput(command, output, branch) {
        var component = Qt.createComponent("qrc:/qml/git/GitOutputWindow.qml");
        if (component.status === Component.Ready) {
            var win = component.createObject(appWindow, {
                "command": command,
                "output": output,
                "branchName": branch,
                "gitLogModel": command.startsWith("git log") ? gitLogModel : null
            });
            
            if (win) {
                // If we don't have output yet, trigger the command now
                if (output === "" && command !== "") {
                    toolManager.runCommand(command, fileSystem.rootPath);
                } else if (output !== "" && (command.includes("git diff") || command.includes("git show"))) {
                    win.setDiff(output);
                }
                
                // Connect navigation back to main window
                win.resultClicked.connect((path, line) => {
                    appWindow.goToLineNumber = line;
                    var fullPath = path;
                    if (path !== "" && !path.startsWith("/")) {
                        fullPath = fileSystem.rootPath + "/" + path;
                    }
                    documentManager.openFile(fullPath, false);
                });
                
                // Cascading positioning
                win.x = appWindow.x + 40 + lastWindowOffset;
                win.y = appWindow.y + 40 + lastWindowOffset;
                lastWindowOffset = (lastWindowOffset + 20) % 100;
                
                win.show();
                gitWindows.push(win);
                
                // Cleanup on close
                win.closing.connect(() => {
                    var idx = gitWindows.indexOf(win);
                    if (idx !== -1) gitWindows.splice(idx, 1);
                    win.destroy();
                });
            }
        } else {
            console.error("Error loading GitOutputWindow component:", component.errorString());
        }
    }

    Component.onCompleted: {
        fileSystem.setRootPath(fileSystem.homePath);
    }

    AppLogic {
        id: appLogic
        rootWindow: appWindow
        customStatusBar: customStatusBar
        outputArea: outputPanel.outputArea
        aiOutputPane: aiOutputPane
        gitLogModel: gitLogModel
        blameModelBackend: gitBlameModel
        injectedGitManager: gitManager
        stackLayout: stackLayout
        dialogs: dialogs
    }
}
