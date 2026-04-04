import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: renameDialog
    title: "Rename File"
    modal: true
    width: 400
    standardButtons: Dialog.NoButton

    property string oldPath

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15

        Label {
            text: "Enter new name for: " + (renameDialog.oldPath ? renameDialog.oldPath.substring(renameDialog.oldPath.lastIndexOf('/') + 1) : "")
            Layout.fillWidth: true
            elide: Text.ElideMiddle
        }

        TextField {
            id: newNameField
            Layout.fillWidth: true
            placeholderText: "New name"
            validator: RegularExpressionValidator { regularExpression: /[^\\/]+/ }
            focus: true
            onAccepted: {
                if (okButton.enabled) {
                    okButton.clicked()
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                id: okButton
                text: "OK"
                enabled: newNameField.acceptableInput && newNameField.text.trim().length > 0
                onClicked: {
                    if (renameDialog.doRename()) {
                        renameDialog.accept()
                    }
                }
            }
            Button {
                text: "Cancel"
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
