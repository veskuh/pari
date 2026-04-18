import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

Dialog {
    id: goToLineDialog
    title: qsTr("Go to Line")
    modal: true
    standardButtons: Dialog.NoButton
    padding: 10

    signal goToLine(int lineNumber)

    contentItem: ColumnLayout {
        spacing: 10
        Label {
            text: qsTr("Line number:")
        }

        TextField {
            id: lineInput
            validator: IntValidator { bottom: 1; }
            focus: true
            onAccepted: {
                goToLineDialog.accept()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            PariButton {
                objectName: "okButton"
                text: qsTr("OK")
                highlighted: true
                onClicked: goToLineDialog.accept()
            }
            PariButton {
                objectName: "cancelButton"
                text: qsTr("Cancel")
                onClicked: goToLineDialog.reject()
            }
        }
    }

    onAccepted: {
        goToLine(parseInt(lineInput.text))
    }
}