import QtQuick
import QtQuick.Controls

MenuBar {
    id: root

    property var actions
    property var dialogs
    property var gitLogModel

    Menu {
        title: qsTr("File")
        MenuItem { action: actions.newAction }
        MenuItem { action: actions.openAction }
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
        MenuItem { action: actions.saveAction }
        MenuItem { action: actions.saveAsAction }
        MenuItem { action: actions.closeAction }
        MenuItem {
            text: qsTr("Exit")
            onTriggered: Qt.exit(0)
        }
    }
    Menu {
        title: qsTr("Edit")
        MenuItem { text: qsTr("Cut") }
        MenuItem { text: qsTr("Copy") }
        MenuItem { text: qsTr("Paste") }
        MenuItem { action: actions.findAction }
        MenuItem { action: actions.filterLinesAction }
        MenuItem { action: actions.indentAction }
        MenuItem {
            text: qsTr("Settings...")
            onTriggered: dialogs.settingsDialog.show()
        }
    }
    Menu {
        title: qsTr("View")
        MenuItem {
            text: qsTr("Chat log")
            onTriggered: dialogs.chatLogWindow.show()
        }
        MenuItem { action: actions.goToAction }
        MenuSeparator {}
        MenuItem {
            text: qsTr("Show Files")
            action: actions.showTreePaneAction
            checkable: true
            checked: actions.showTreePaneAction ? actions.showTreePaneAction.checked : true
        }

        MenuItem {
            text: qsTr("Global Search")
            onTriggered: {
                actions.showGlobalSearchAction.trigger();
            }
        }

        MenuItem {
            text: qsTr("Show AI")
            action: actions.showAiPaneAction
            checkable: true
            checked: actions.showAiPaneAction ? actions.showAiPaneAction.checked : true
        }

        MenuSeparator {}

        MenuItem {
            text: qsTr("Show Hidden Files")
            action: actions.toggleHiddenFilesAction
            checkable: true
            checked: actions.toggleHiddenFilesAction ? actions.toggleHiddenFilesAction.checked : false
        }
    }
    Menu {
        title: qsTr("Build")
        MenuItem { action: actions.buildAction }
        MenuItem { action: actions.runAction }
        MenuItem {
            text: "Clean"
            enabled: actions.hasBuildConfiguration
            onTriggered: {
                actions.outputArea.text = "";
                actions.outputPanel.visible = true;
                buildManager.executeCommand(appSettings.getCleanCommand(fileSystem.rootPath), fileSystem.rootPath);
            }
        }
        MenuSeparator {}
        MenuItem { action: actions.configureBuildAction }
    }
    Menu {
        title: qsTr("Help")
        MenuItem {
            text: qsTr("About")
            onTriggered: dialogs.aboutWindow.show()
        }
    }
    Menu {
        title: qsTr("Git")
        MenuItem {
            text: "git diff"
            enabled: fileSystem.isGitRepository
            onTriggered: {
                actions.rootWindow.showGitOutput("git status --porcelain && git diff", "", "");
            }
        }
        MenuItem {
            text: "git diff current file"
            enabled: fileSystem.isGitRepository && fileSystem.currentFilePath !== ""
            onTriggered: {
                actions.rootWindow.showGitOutput("git status --porcelain " + fileSystem.currentFilePath + " && git diff " + fileSystem.currentFilePath, "", "");
            }
        }
        MenuItem {
            enabled: fileSystem.isGitRepository
            text: "git log"
            onTriggered: {
                actions.rootWindow.showGitOutput("git log --pretty=format:\"%H%x1f%an%x1f%ae%x1f%ad%x1f%s%n%b%x1e\" --date=rfc", "", "");
            }
        }
        MenuItem {
            text: "git blame"
            enabled: fileSystem.isGitRepository && fileSystem.currentFilePath !== ""
            onTriggered: {
                actions.rootWindow.showGitOutput("git blame --line-porcelain " + fileSystem.currentFilePath, "", "");
            }
        }
    }
}
