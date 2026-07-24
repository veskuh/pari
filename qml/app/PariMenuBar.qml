import QtQuick
import QtQuick.Controls
import Kaakao 1.0

MenuBar {
    id: root

    property var actions
    property var dialogs
    property var gitLogModel

    KaakaoMenu {
        title: qsTr("File")
        KaakaoMenuItem { action: actions.newAction }
        KaakaoMenuItem { action: actions.openAction }
        KaakaoMenu {
            title: qsTr("Recents")
            Repeater {
                model: appSettings.recentFolders
                KaakaoMenuItem {
                    text: modelData
                    onTriggered: fileSystem.setRootPath(modelData)
                }
            }
            KaakaoMenuSeparator {}
            KaakaoMenuItem {
                text: qsTr("Clear Recents")
                onTriggered: appSettings.clearRecentFolders()
            }
        }
        KaakaoMenuItem { action: actions.saveAction }
        KaakaoMenuItem { action: actions.saveAsAction }
        KaakaoMenuItem { action: actions.closeAction }
        KaakaoMenuItem {
            text: qsTr("Exit")
            onTriggered: Qt.exit(0)
        }
    }
    KaakaoMenu {
        title: qsTr("Edit")
        KaakaoMenuItem { text: qsTr("Cut") }
        KaakaoMenuItem { text: qsTr("Copy") }
        KaakaoMenuItem { text: qsTr("Paste") }
        KaakaoMenuItem { action: actions.findAction }
        KaakaoMenuItem { action: actions.filterLinesAction }
        KaakaoMenuItem { action: actions.indentAction }
        KaakaoMenuItem {
            text: qsTr("Settings...")
            onTriggered: dialogs.settingsDialog.show()
        }
    }
    KaakaoMenu {
        title: qsTr("View")
        KaakaoMenuItem {
            text: qsTr("Chat log")
            onTriggered: dialogs.chatLogWindow.show()
        }
        KaakaoMenuItem { action: actions.goToAction }
        KaakaoMenuSeparator {}
        KaakaoMenuItem {
            text: qsTr("Show Files")
            action: actions.showTreePaneAction
            checkable: true
            checked: actions.showTreePaneAction ? actions.showTreePaneAction.checked : true
        }

        KaakaoMenuItem {
            text: qsTr("Global Search")
            onTriggered: {
                actions.showGlobalSearchAction.trigger();
            }
        }

        KaakaoMenuItem {
            text: qsTr("Show AI")
            action: actions.showAiPaneAction
            checkable: true
            checked: actions.showAiPaneAction ? actions.showAiPaneAction.checked : true
        }

        KaakaoMenuSeparator {}

        KaakaoMenuItem {
            text: qsTr("Show Hidden Files")
            action: actions.toggleHiddenFilesAction
            checkable: true
            checked: actions.toggleHiddenFilesAction ? actions.toggleHiddenFilesAction.checked : false
        }
    }
    KaakaoMenu {
        title: qsTr("Build")
        KaakaoMenuItem { action: actions.buildAction }
        KaakaoMenuItem { action: actions.runAction }
        KaakaoMenuItem {
            text: "Clean"
            enabled: actions.hasBuildConfiguration
            onTriggered: {
                actions.outputArea.text = "";
                actions.outputPanel.visible = true;
                buildManager.executeCommand(appSettings.getCleanCommand(fileSystem.rootPath), fileSystem.rootPath);
            }
        }
        KaakaoMenuSeparator {}
        KaakaoMenuItem { action: actions.configureBuildAction }
    }
    KaakaoMenu {
        title: qsTr("Help")
        KaakaoMenuItem {
            text: qsTr("About")
            onTriggered: dialogs.aboutWindow.show()
        }
    }
    KaakaoMenu {
        title: qsTr("Git")
        KaakaoMenuItem {
            text: "git diff"
            enabled: fileSystem.isGitRepository
            onTriggered: {
                actions.rootWindow.showGitOutput("git status --porcelain && git diff", "", "");
            }
        }
        KaakaoMenuItem {
            text: "git diff current file"
            enabled: fileSystem.isGitRepository && fileSystem.currentFilePath !== ""
            onTriggered: {
                actions.rootWindow.showGitOutput("git status --porcelain " + fileSystem.currentFilePath + " && git diff " + fileSystem.currentFilePath, "", "");
            }
        }
        KaakaoMenuItem {
            enabled: fileSystem.isGitRepository
            text: "git log"
            onTriggered: {
                actions.rootWindow.showGitOutput("git log --pretty=format:\"%H%x1f%an%x1f%ae%x1f%ad%x1f%s%n%b%x1e\" --date=rfc", "", "");
            }
        }
        KaakaoMenuItem {
            text: "git blame"
            enabled: fileSystem.isGitRepository && fileSystem.currentFilePath !== ""
            onTriggered: {
                actions.rootWindow.showGitOutput("git blame --line-porcelain " + fileSystem.currentFilePath, "", "");
            }
        }
    }
}
