import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../common"

Dialog {
    id: renameDialog
    title: "Rename File"
    modal: true
    width: 400
    standardButtons: Dialog.NoButton

    // Use pariTheme if available (global in app), otherwise fallback (for tests)
    readonly property var _pariTheme: (typeof pariTheme !== 'undefined') ? pariTheme : null

    padding: _pariTheme ? _pariTheme.marginStandard : 15

    property string oldPath

    onOldPathChanged: {
        if (oldPath) {
            var currentName = oldPath.substring(oldPath.lastIndexOf('/') + 1);
            newNameField.text = currentName;
        }
    }

    onOpened: {
        newNameField.forceActiveFocus();
        newNameField.selectAll();
    }

    contentItem: ColumnLayout {
        spacing: _pariTheme ? _pariTheme.paddingLarge : 15

        Label {
            text: "Enter new name for: " + (renameDialog.oldPath ? renameDialog.oldPath.substring(renameDialog.oldPath.lastIndexOf('/') + 1) : "")
            Layout.fillWidth: true
            elide: Text.ElideMiddle
            color: _pariTheme ? _pariTheme.textColor : "black"
        }

        TextField {
            id: newNameField
            Layout.fillWidth: true
            placeholderText: "New name"
            validator: RegularExpressionValidator { regularExpression: /[^\\/]+/ }
            focus: true
            color: _pariTheme ? _pariTheme.textColor : "black"
            onAccepted: {
                if (renameButton.enabled) {
                    renameButton.clicked()
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: _pariTheme ? _pariTheme.paddingMedium : 10
            PariButton {
                id: renameButton
                objectName: "renameButton"
                text: qsTr("Rename")
                enabled: newNameField.acceptableInput && newNameField.text.trim().length > 0
                highlighted: true
                onClicked: {
                    if (renameDialog.doRename()) {
                        renameDialog.accept()
                    }
                }
            }
            PariButton {
                objectName: "cancelButton"
                text: qsTr("Cancel")
                onClicked: {
                    renameDialog.reject()
                }
            }
        }
    }

    function doRename() {
        var oldFilePath = renameDialog.oldPath;
        var newFileName = newNameField.text.trim();
        var lastSlash = oldFilePath.lastIndexOf('/');
        var newFilePath = oldFilePath.substring(0, lastSlash + 1) + newFileName;
        
        if (newFilePath === oldFilePath) {
             return true; // No change needed
        }

        if (fileSystem.renameFile(oldFilePath, newFilePath)) {
            return true;
        } else {
            errorDialog.text = "Failed to rename file. Make sure the name is valid and doesn't already exist.";
            errorDialog.open();
            return false;
        }
    }

    MessageDialog {
        id: errorDialog
        title: "Error"
        buttons: MessageDialog.Ok
    }
}
