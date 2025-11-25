import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: renameDialog
    title: "Rename File"
    modal: true
    width: 400
    height: 150

    property string oldPath

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Label {
            text: "Enter new name for: " + oldPath.substring(oldPath.lastIndexOf('/') + 1)
        }

        TextField {
            id: newNameField
            Layout.fillWidth: true
            placeholderText: "New name"
            validator: RegExpValidator { regExp: /[^\\/]+/ }
            onAccepted: {
                renameDialog.accept()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                text: "OK"
                enabled: newNameField.acceptableInput && newNameField.text.length > 0
                onClicked: {
                    renameDialog.accept()
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

    onAccepted: {
        var oldFilePath = oldPath;
        var newFileName = newNameField.text;
        if (newFileName.length > 0) {
            var lastSlash = oldFilePath.lastIndexOf('/');
            var newFilePath = oldFilePath.substring(0, lastSlash + 1) + newFileName;
            if (!fileSystem.renameFile(oldFilePath, newFilePath)) {
                errorDialog.text = "Failed to rename file.";
                errorDialog.open();
            }
        }
    }

    MessageDialog {
        id: errorDialog
        title: "Error"
        icon: StandardIcon.Critical
        standardButtons: Dialog.Ok
    }
}
