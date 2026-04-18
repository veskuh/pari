import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../common"

Dialog {
    id: newFileDialog
    title: qsTr("New File")
    modal: true
    width: 400
    height: 200
    standardButtons: Dialog.NoButton

    property string folderPath

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: (typeof pariTheme !== 'undefined') ? pariTheme.marginStandard : 15
        spacing: (typeof pariTheme !== 'undefined') ? pariTheme.paddingLarge : 15

        Label {
            text: qsTr("Create new file in: ") + newFileDialog.folderPath
            Layout.fillWidth: true
            elide: Text.ElideMiddle
            font.pixelSize: 11
            color: "gray"
        }

        TextField {
            id: fileNameField
            Layout.fillWidth: true
            placeholderText: qsTr("File name")
            validator: RegularExpressionValidator { regularExpression: /[^\\/]+/ }
            focus: true
            onAccepted: {
                if (createButton.enabled) {
                    createButton.clicked()
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: (typeof pariTheme !== 'undefined') ? pariTheme.paddingMedium : 10
            Layout.topMargin: (typeof pariTheme !== 'undefined') ? pariTheme.paddingMedium : 10
            PariButton {
                id: createButton
                objectName: "createButton"
                text: qsTr("Create")
                enabled: fileNameField.acceptableInput && fileNameField.text.trim().length > 0
                highlighted: true
                onClicked: {
                    if (newFileDialog.doCreate()) {
                        newFileDialog.accept()
                    }
                }
            }
            PariButton {
                objectName: "cancelButton"
                text: qsTr("Cancel")
                onClicked: {
                    newFileDialog.reject()
                }
            }
        }
    }

    function doCreate() {
        var name = fileNameField.text.trim();
        if (fileSystem.createNewFile(newFileDialog.folderPath, name)) {
            return true;
        } else {
            errorDialog.text = qsTr("Failed to create file. Make sure the name is valid and doesn't already exist.");
            errorDialog.open();
            return false;
        }
    }

    MessageDialog {
        id: errorDialog
        title: qsTr("Error")
        buttons: MessageDialog.Ok
    }
}
