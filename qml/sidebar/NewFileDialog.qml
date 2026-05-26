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
    height: 220
    standardButtons: Dialog.NoButton

    // Use pariTheme if available (global in app), otherwise fallback (for tests)
    readonly property var _pariTheme: (typeof pariTheme !== 'undefined') ? pariTheme : null

    padding: _pariTheme ? _pariTheme.marginStandard : 15

    property string folderPath

    onOpened: {
        fileNameField.text = "";
        fileNameField.forceActiveFocus();
    }

    contentItem: ColumnLayout {
        spacing: _pariTheme ? _pariTheme.paddingLarge : 15

        Label {
            text: qsTr("Create new file in: ") + newFileDialog.folderPath
            Layout.fillWidth: true
            elide: Text.ElideMiddle
            font.pixelSize: _pariTheme ? _pariTheme.fontSizeSmall : 11
            color: _pariTheme ? _pariTheme.textColorDim : "gray"
        }

        TextField {
            id: fileNameField
            Layout.fillWidth: true
            placeholderText: qsTr("File name")
            validator: RegularExpressionValidator { regularExpression: /[^\\/]+/ }
            focus: true
            color: _pariTheme ? _pariTheme.textColor : "black"
            onAccepted: {
                if (createButton.enabled) {
                    createButton.clicked()
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: _pariTheme ? _pariTheme.paddingMedium : 10
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
        var filePath = newFileDialog.folderPath + "/" + name;
        if (fileSystem.createNewFile(newFileDialog.folderPath, name)) {
            documentManager.openFile(filePath, false);
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
