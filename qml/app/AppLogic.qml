import QtQuick
import "../utils/FormattingUtils.js" as FormattingUtils
import "../utils/FileUtils.js" as FileUtils

Item {
    id: root

    // Reference components in PariAppWindow that are not globally available as context properties
    property var rootWindow
    property var customStatusBar
    property var outputArea
    property var aiOutputPane
    property var gitLogModel
    property var blameModelBackend
    property var injectedGitManager
    property var stackLayout
    property var dialogs

    Component.onCompleted: {
        console.log("AppLogic completed. fileSystem available:", typeof fileSystem !== 'undefined');
        if (typeof fileSystem !== 'undefined' && typeof appSettings !== 'undefined') {
            fileSystem.showHiddenFiles = appSettings.showHiddenFiles;
        }
        if (typeof customStatusBar !== 'undefined' && typeof appSettings !== 'undefined') {
            customStatusBar.modelName = appSettings.ollamaModel;
        }
        
        var gitM = root.injectedGitManager || (typeof gitManager !== 'undefined' ? gitManager : null);
        if (typeof customStatusBar !== 'undefined' && gitM && gitM.currentBranch !== undefined) {
            customStatusBar.branchName = gitM.currentBranch;
        }
    }

    // SHARED NAVIGATION HELPER
    function handlePendingNavigation() {
        if (rootWindow.goToLineNumber !== -1) {
            var line = rootWindow.goToLineNumber;
            rootWindow.goToLineNumber = -1; // Consume
            
            // Wait for QML layout and editor population
            var timer = Qt.createQmlObject('import QtQuick; Timer { interval: 150; repeat: false; running: true; }', root);
            timer.triggered.connect(function() {
                if (rootWindow.currentEditor) {
                    rootWindow.currentEditor.goToLine(line);
                }
                timer.destroy();
            });
        }
    }

    Connections {
        target: (typeof appSettings !== 'undefined') ? appSettings : null
        function onShowHiddenFilesChanged() {
            if (typeof fileSystem !== 'undefined') {
                fileSystem.showHiddenFiles = appSettings.showHiddenFiles;
            }
        }
        function onOllamaModelChanged() {
            if (typeof customStatusBar !== 'undefined') {
                customStatusBar.modelName = appSettings.ollamaModel;
            }
        }
    }

    Connections {
        target: (typeof fileSystem !== 'undefined') ? fileSystem : null
        function onRootPathChanged() {
            rootWindow.fileSystemView.model = fileSystem.model;
            var buildCommand = appSettings.getBuildCommand(fileSystem.rootPath);
            rootWindow.hasBuildConfiguration = buildCommand !== "";
            
            if (typeof appSettings !== 'undefined' && fileSystem.rootPath !== "") {
                appSettings.addRecentFolder(fileSystem.rootPath);
            }
        }
        function onFileSaved(filePath) {
            customStatusBar.text = qsTr("✅ File saved: %1").arg(filePath);
        }
        function onFileRenamed(oldPath, newPath) {
            if (typeof lspClient !== 'undefined' && lspClient && FileUtils.isCppFile(oldPath)) {
                lspClient.documentClosed(oldPath);
            }
            documentManager.updatePath(oldPath, newPath);
            if (typeof lspClient !== 'undefined' && lspClient && FileUtils.isCppFile(newPath)) {
                for (var i = 0; i < documentManager.documents.length; i++) {
                    var doc = documentManager.documents[i];
                    if (doc.filePath === newPath) {
                        lspClient.documentOpened(newPath, doc.text);
                        break;
                    }
                }
            }
        }
    }

    Connections {
        target: (typeof documentManager !== 'undefined') ? documentManager : null
        // PATH 1: Newly opened file
        function onFileOpened(filePath, content) {
            root.handlePendingNavigation();
        }
        // PATH 2: Already open file (just switching tabs)
        function onCurrentIndexChanged() {
            root.handlePendingNavigation();
        }
        function onFileContentReloaded(filePath, content) {
            if (typeof stackLayout !== 'undefined') {
                for (var i = 0; i < stackLayout.children.length; i++) {
                    var child = stackLayout.children[i];
                    if (child.filePath === filePath) {
                        child.text = content;
                        break;
                    }
                }
            }
        }
        function onFileModifiedExternally(filePath) {
            if (rootWindow && typeof rootWindow.showReloadPrompt === 'function') {
                rootWindow.showReloadPrompt(filePath);
            }
        }
    }

    function appendToOutput(newText, isError) {
        if (!newText) return;
        var formatted = FormattingUtils.formatOutput(newText, fileSystem);
        if (formatted.length === 0) return;
        
        var prefix = (isError ? "❗" : "");
        outputArea.append(prefix + formatted);
    }

    Connections {
        target: (typeof buildManager !== 'undefined') ? buildManager : null
        function onOutputReady(output) {
            root.appendToOutput(output, false);
        }
        function onErrorReady(error) {
            root.appendToOutput(error, true);
        }
        function onFinished() {
            root.appendToOutput("✅ Ready.", false);
        }
    }

    Connections {
        target: (typeof llm !== 'undefined') ? llm : null
        function onResponseReady(response) {
            aiOutputPane.fullAiText = response;
            customStatusBar.text = qsTr("💬 AI response received.");
            if (stackLayout.currentIndex !== -1) {
                aiOutputPane.updateDiff(rootWindow.currentEditor.text);
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

    Connections {
        target: root.injectedGitManager || (typeof gitManager !== 'undefined' ? gitManager : null)
        function onCurrentBranchChanged() {
            if (typeof customStatusBar !== 'undefined') {
                var gitM = root.injectedGitManager || (typeof gitManager !== 'undefined' ? gitManager : null);
                if (gitM && gitM.currentBranch !== undefined) {
                    customStatusBar.branchName = gitM.currentBranch;
                }
            }
        }
    }

    Connections {
        target: (typeof toolManager !== 'undefined') ? toolManager : null
        function onOutputReady(command, output, branchName) {
            if (command.includes("git blame")) {
                blameModelBackend.parseRawOutput(output);
            } else if (command.startsWith("git ")) {
                blameModelBackend.clear();
            }
            // showGitOutput is now handled solely by the trigger points
        }
        function onQmlFileIndented(formattedContent) {
            rootWindow.currentEditor.text = formattedContent;
            rootWindow.currentEditor.restoreCursorPosition();
        }
        function onGitLogReady(log) {
            // Global log model updated, but windows will catch their own iftaskId is matched
            gitLogModel.parseAndSetLog(log);
        }
        function onCommitDetailsReady(sha, details) {
            gitLogModel.updateDetails(sha, details);
        }
    }
}
