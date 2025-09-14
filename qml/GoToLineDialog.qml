import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: goToLineDialog
    title: qsTr("Go to Line")
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel
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
    }

    onAccepted: {
        goToLine(parseInt(lineInput.text))
    }
}