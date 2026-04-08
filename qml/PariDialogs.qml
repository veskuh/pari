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

    // Signals for dialog actions
    signal saveConfiguration(string buildCommand, string runCommand, string cleanCommand)
    signal goToLine(int lineNumber)
    signal discardChanges()
    signal saveAndClose()

    SettingsWindow {
        id: settingsDialog
    }
    AboutWindow {
        id: aboutWindow
    }
    ChatLogWindow {
        id: chatLogWindow
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

    MessageDialog {
        id: unsavedChangesDialog
        title: qsTr("Unsaved Changes")
        text: qsTr("The current file has unsaved changes. Do you want to save them?")
        buttons: MessageDialog.Save | MessageDialog.Discard | MessageDialog.Cancel
        onAccepted: {
            if (result === MessageDialog.Save) {
                root.saveAndClose();
            } else if (result === MessageDialog.Discard) {
                root.discardChanges();
            }
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
}
