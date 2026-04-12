import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import Qt.labs.platform 1.1 as Platform

Item {
    id: root

    // Properties to expose dialogs or their methods if needed
    property alias settingsDialog: settingsDialog
    property alias aboutWindow: aboutWindow
    property alias chatLogWindow: chatLogWindow
    property alias buildConfigurationWindow: buildConfigurationWindow
    property alias goToLineDialog: goToLineDialog
    property alias gitOutputWindow: gitOutputWindow
    property alias unsavedChangesDialog: unsavedChangesDialog
    property alias fileDialog: fileDialog
    property alias saveAsDialog: saveAsDialog
    property alias newFileDialog: newFileDialog

    property int targetIndex: -1

    // Signals for dialog actions
    signal saveConfiguration(string buildCommand, string runCommand, string cleanCommand)
    signal goToLine(int lineNumber)
    signal discardChanges(int index)
    signal saveAndClose(int index)

    SettingsWindow {
        id: settingsDialog
    }
    AboutWindow {
        id: aboutWindow
    }
    ChatLogWindow {
        id: chatLogWindow
        chatLlm: (typeof llm !== 'undefined') ? llm : null
    }

    BuildConfigurationDialog {
        id: buildConfigurationWindow
        onSaveConfiguration: (buildCommand, runCommand, cleanCommand) => root.saveConfiguration(buildCommand, runCommand, cleanCommand)
    }

    GoToLineDialog {
        id: goToLineDialog
        onGoToLine: (lineNumber) => root.goToLine(lineNumber)
    }

    GitOutputWindow {
        id: gitOutputWindow
    }

    Platform.MessageDialog {
        id: unsavedChangesDialog
        title: qsTr("Unsaved Changes")
        text: qsTr("The current file has unsaved changes. Do you want to save them?")
        buttons: Platform.MessageDialog.Save | Platform.MessageDialog.Discard | Platform.MessageDialog.Cancel
        onAccepted: {
            root.saveAndClose(root.targetIndex);
        }
        onDiscardClicked: {
            root.discardChanges(root.targetIndex);
        }
    }

    Platform.FolderDialog {
        id: fileDialog
        title: qsTr("Choose a folder")
    }

    Platform.FileDialog {
        id: saveAsDialog
        title: "Save As..."
        fileMode: Platform.FileDialog.SaveFile
    }

    NewFileDialog {
        id: newFileDialog
        onAccepted: {
            // New file creation is handled inside doCreate
        }
    }
}
