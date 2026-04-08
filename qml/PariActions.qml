import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var rootWindow
    property var dialogs
    property var stackLayout
    property var outputPanel
    property var outputArea
    property var gitLogModel
    property bool hasBuildConfiguration

    // Signals to communicate with the main window
    signal closeCurrentFile()

    Action {
        id: openAction
        text: qsTr("Open")
        shortcut: StandardKey.Open
        onTriggered: dialogs.fileDialog.open()
    }

    Action {
        id: saveAction
        text: qsTr("Save")
        shortcut: StandardKey.Save
        enabled: stackLayout.currentIndex !== -1
        onTriggered: {
            documentManager.saveFile(stackLayout.currentIndex, rootWindow.currentEditor.text);
        }
    }

    Action {
        id: saveAsAction
        text: qsTr("Save As...")
        shortcut: StandardKey.SaveAs
        enabled: stackLayout.currentIndex !== -1
        onTriggered: {
            dialogs.saveAsDialog.open();
        }
    }

    Action {
        id: closeAction
        text: qsTr("Close")
        shortcut: StandardKey.Close
        enabled: stackLayout.currentIndex !== -1
        onTriggered: {
            if (stackLayout.currentIndex !== -1) {
                var currentDoc = documentManager.documents[stackLayout.currentIndex];
                if (currentDoc.isDirty) {
                    dialogs.unsavedChangesDialog.open();
                } else {
                    root.closeCurrentFile();
                }
            }
        }
    }

    Action {
        id: findAction
        text: qsTr("Find")
        shortcut: StandardKey.Find
        enabled: stackLayout.currentIndex !== -1
        onTriggered: {
            rootWindow.currentEditor.find();
        }
    }

    Action {
        id: configureBuildAction
        text: "Build setup..."
        onTriggered: {
            dialogs.buildConfigurationWindow.buildCommand = appSettings.getBuildCommand(fileSystem.rootPath);
            dialogs.buildConfigurationWindow.runCommand = appSettings.getRunCommand(fileSystem.rootPath);
            dialogs.buildConfigurationWindow.cleanCommand = appSettings.getCleanCommand(fileSystem.rootPath);
            dialogs.buildConfigurationWindow.visible = true;
        }
    }

    Action {
        id: buildAction
        text: "Build"
        enabled: hasBuildConfiguration
        shortcut: "Ctrl+b"
        onTriggered: {
            outputPanel.visible = true;
            buildManager.executeCommand(appSettings.getBuildCommand(fileSystem.rootPath), fileSystem.rootPath);
        }
    }

    Action {
        id: runAction
        text: "Run"
        enabled: hasBuildConfiguration
        shortcut: "Ctrl+r"
        onTriggered: {
            outputPanel.visible = true;
            buildManager.executeCommand(appSettings.getRunCommand(fileSystem.rootPath), fileSystem.rootPath);
        }
    }

    Action {
        id: indentAction
        text: qsTr("Indent")
        enabled: stackLayout.currentIndex !== -1
        shortcut: "Ctrl+i"
        onTriggered: {
            rootWindow.currentEditor.saveCursorPosition();
            rootWindow.currentEditor.format();
        }
    }

    Action {
        id: goToAction
        text: qsTr("Go to line..")
        enabled: stackLayout.currentIndex !== -1
        shortcut: "Ctrl+l"
        onTriggered: {
            dialogs.goToLineDialog.x = rootWindow.x + rootWindow.width / 2 - dialogs.goToLineDialog.width / 2;
            dialogs.goToLineDialog.y = rootWindow.y + rootWindow.height / 2 - dialogs.goToLineDialog.height / 2;
            dialogs.goToLineDialog.open();
        }
    }

    Action {
        id: showAiPaneAction
        text: qsTr("Show AI Pane")
        shortcut: "Ctrl+shift+0"
        onTriggered: {
            rootWindow.aiOutputPane.visible = !rootWindow.aiOutputPane.visible;
        }
    }

    Action {
        id: showTreePaneAction
        text: qsTr("Show Filesystem")
        shortcut: "Ctrl+0"
        onTriggered: {
            rootWindow.treeColumn.visible = !rootWindow.treeColumn.visible;
        }
    }

    // Export actions to be used by other components
    property alias openAction: openAction
    property alias saveAction: saveAction
    property alias saveAsAction: saveAsAction
    property alias closeAction: closeAction
    property alias findAction: findAction
    property alias configureBuildAction: configureBuildAction
    property alias buildAction: buildAction
    property alias runAction: runAction
    property alias indentAction: indentAction
    property alias goToAction: goToAction
    property alias showAiPaneAction: showAiPaneAction
    property alias showTreePaneAction: showTreePaneAction
}
