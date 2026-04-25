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

                // 1. Machine Bezel Tab Strip
                Rectangle {
                    id: tabStrip
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: pariTheme.isDark ? "#2a2a2a" : "#e0e4e9" }
                        GradientStop { position: 0.5; color: pariTheme.isDark ? "#323232" : "#edf1f5" }
                        GradientStop { position: 1.0; color: pariTheme.isDark ? "#2a2a2a" : "#e0e4e9" }
                    }
                    z: 5
                    
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: pariTheme.sidebarBorder
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -1
                        width: parent.width
                        height: 1
                        color: pariTheme.isDark ? "#ffffff" : "#ffffff"
                        opacity: pariTheme.isDark ? 0.05 : 0.6
                        visible: !pariTheme.isDark
                    }

                    // Sliding Recessed Well (Increased width for Label)
                    Rectangle {
                        id: recessedWell
                        y: 6
                        height: 30
                        width: 100
                        radius: 6
                        x: (sidebarStack.currentIndex === 0 ? explorerTabItem.x : searchTabItem.x) + 12
                        
                        color: pariTheme.isDark ? "#1a1a1a" : "#d0d6db"
                        border.color: pariTheme.isDark ? "#000000" : "#b0b7be"
                        border.width: 1
                        
                        Behavior on x { 
                            SmoothedAnimation { duration: 250; easing.type: Easing.InOutQuad } 
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 1
                            radius: 5
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#20000000" }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Item {
                            id: explorerTabItem
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 30
                            
                            AbstractButton {
                                id: explorerTabBtn
                                anchors.fill: parent
                                checkable: true
                                checked: sidebarStack.currentIndex === 0
                                onClicked: sidebarStack.currentIndex = 0
                                ToolTip.visible: hovered
                                ToolTip.text: qsTr("Explorer")
                                
                                padding: 0
                                
                                contentItem: Item {
                                    anchors.fill: parent
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Image {
                                            source: "qrc:/assets/folder.png"
                                            sourceSize.width: 16
                                            sourceSize.height: 16
                                            fillMode: Image.PreserveAspectFit
                                            Layout.alignment: Qt.AlignVCenter
                                            opacity: explorerTabBtn.checked ? 1.0 : 0.7
                                        }
                                        Label {
                                            text: qsTr("Explorer")
                                            font.pixelSize: 11
                                            font.bold: explorerTabBtn.checked
                                            color: pariTheme.textColor
                                            opacity: explorerTabBtn.checked ? 1.0 : 0.7
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                    }
                                }
                                
                                background: Item {}
                                scale: pressed ? 0.95 : 1.0
                            }
                        }

                        Item {
                            id: searchTabItem
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 30
                            
                            AbstractButton {
                                id: searchTabBtn
                                anchors.fill: parent
                                checkable: true
                                checked: sidebarStack.currentIndex === 1
                                onClicked: sidebarStack.currentIndex = 1
                                ToolTip.visible: hovered
                                ToolTip.text: qsTr("Project Search")
                                
                                padding: 0
                                
                                contentItem: Item {
                                    anchors.fill: parent
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Image {
                                            source: "qrc:/assets/search.png"
                                            sourceSize.width: 16
                                            sourceSize.height: 16
                                            fillMode: Image.PreserveAspectFit
                                            Layout.alignment: Qt.AlignVCenter
                                            opacity: searchTabBtn.checked ? 1.0 : 0.7
                                        }
                                        Label {
                                            text: qsTr("Search")
                                            font.pixelSize: 11
                                            font.bold: searchTabBtn.checked
                                            color: pariTheme.textColor
                                            opacity: searchTabBtn.checked ? 1.0 : 0.7
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                    }
                                }
                                
                                background: Item {}
                                scale: pressed ? 0.95 : 1.0
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
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
                        }
                        Connections {
                            target: fileSystemView
                            function onModelChanged() {
                                fileSystemView.rootIndex = fileSystem.currentRootIndex;
                            }
                        }
                    }

                    // Search View
                    InvestigationPane {
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
                                            documentManager.openFile(absolutePath, false);
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
        console.log("DEBUG-APP: PariAppWindow Component.onCompleted");
        console.log("DEBUG-APP: treeColumn exists:", !!treeColumn);
        console.log("DEBUG-APP: sidebarStack exists:", !!sidebarStack);
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
