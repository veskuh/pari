import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import Qt.labs.platform 1.1 as Platform
import net.veskuh.pari 1.0
import "../settings"
import "../ai"
import "../buildtools"
import "../editor"
import "../git"
import "../sidebar"

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
    property alias quitConfirmationDialog: quitConfirmationDialog
    property alias reloadConfirmationDialog: reloadConfirmationDialog
    property string reloadTargetFilePath: ""

    // Signals for dialog actions
    signal saveConfiguration(string buildCommand, string runCommand, string cleanCommand)
    signal goToLine(int lineNumber)
    signal discardChanges(int index)
    signal saveAndClose(int index)
    signal saveAllAndQuit()
    signal discardAllAndQuit()
    signal resultClicked(string filePath, int lineNumber)

    property int targetIndex: -1

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
        onResultClicked: (path, line) => root.resultClicked(path, line)
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

    Platform.MessageDialog {
        id: quitConfirmationDialog
        title: qsTr("Unsaved Changes")
        text: qsTr("You have unsaved changes in one or more files. Do you want to save them before exiting?")
        buttons: Platform.MessageDialog.SaveAll | Platform.MessageDialog.Discard | Platform.MessageDialog.Cancel
        onAccepted: {
            root.saveAllAndQuit();
        }
        onDiscardClicked: {
            root.discardAllAndQuit();
        }
    }

    Platform.MessageDialog {
        id: reloadConfirmationDialog
        title: qsTr("File Changed Externally")
        text: qsTr("The file '%1' has been modified externally. Do you want to reload it and discard your changes?").arg(reloadTargetFilePath)
        buttons: Platform.MessageDialog.Yes | Platform.MessageDialog.No
        onYesClicked: {
            documentManager.reloadFile(reloadTargetFilePath);
        }
        onNoClicked: {
            documentManager.ignoreExternalChange(reloadTargetFilePath);
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
