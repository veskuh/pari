import QtQuick
import "FormattingUtils.js" as FormattingUtils

Item {
    id: root

    // Reference components in PariAppWindow that are not globally available as context properties
    property var rootWindow
    property var customStatusBar
    property var outputArea
    property var aiOutputPane
    property var gitLogModel
    property var stackLayout
    property var dialogs

    Component.onCompleted: {
        console.log("AppLogic completed. fileSystem available:", typeof fileSystem !== 'undefined');
        if (typeof fileSystem !== 'undefined' && typeof appSettings !== 'undefined') {
            fileSystem.showHiddenFiles = appSettings.showHiddenFiles;
        }
    }

    Connections {
        target: (typeof appSettings !== 'undefined') ? appSettings : null
        function onShowHiddenFilesChanged() {
            if (typeof fileSystem !== 'undefined') {
                fileSystem.showHiddenFiles = appSettings.showHiddenFiles;
            }
        }
    }

    Connections {
        target: (typeof fileSystem !== 'undefined') ? fileSystem : null
        function onRootPathChanged() {
            rootWindow.fileSystemView.model = fileSystem.model;
            var buildCommand = appSettings.getBuildCommand(fileSystem.rootPath);
            rootWindow.hasBuildConfiguration = buildCommand !== "";
        }
        function onFileSaved(filePath) {
            customStatusBar.text = qsTr("✅ File saved: %1").arg(filePath);
        }
        function onFileRenamed(oldPath, newPath) {
            documentManager.updatePath(oldPath, newPath);
        }
    }

    Connections {
        target: (typeof buildManager !== 'undefined') ? buildManager : null
        function onOutputReady(output) {
            outputArea.text += "\n" + FormattingUtils.formatOutput(output, fileSystem);
        }
        function onErrorReady(error) {
            outputArea.text += "\n❗" + FormattingUtils.formatOutput(error, fileSystem);
        }
        function onFinished() {
            outputArea.text += "\n✅ Ready.\n";
            console.log("Ready");
        }
    }

    Connections {
        target: (typeof llm !== 'undefined') ? llm : null
        function onResponseReady(response) {
            aiOutputPane.text = response;
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
        target: (typeof toolManager !== 'undefined') ? toolManager : null
        function onOutputReady(command, output, branchName) {
            rootWindow.showGitOutput(command, output, branchName);
        }
        function onQmlFileIndented(formattedContent) {
            rootWindow.currentEditor.text = formattedContent;
            rootWindow.currentEditor.restoreCursorPosition();
        }
        function onGitLogReady(log) {
            gitLogModel.parseAndSetLog(log);
            rootWindow.showGitOutput("git log", "", "");
        }
    }
}
