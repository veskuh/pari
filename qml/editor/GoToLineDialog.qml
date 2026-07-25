import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kaakao 1.0
import "../common"

Dialog {
    id: goToLineDialog
    title: qsTr("Go to Line")
    modal: true
    standardButtons: Dialog.NoButton
    
    // Use pariTheme if available (global in app), otherwise fallback (for tests)
    readonly property var _pariTheme: (typeof pariTheme !== 'undefined') ? pariTheme : null

    padding: _pariTheme ? _pariTheme.marginStandard : 15

    signal goToLine(int lineNumber)

    contentItem: ColumnLayout {
        spacing: _pariTheme ? _pariTheme.paddingLarge : 10

        Label {
            text: qsTr("Line number:")
            color: _pariTheme ? _pariTheme.textColor : "black"
        }

        TextField {
            id: lineInput
            validator: IntValidator { bottom: 1; }
            focus: true
            Layout.fillWidth: true
            color: _pariTheme ? _pariTheme.textColor : "black"
            onAccepted: {
                goToLineDialog.accept()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: _pariTheme ? _pariTheme.paddingMedium : 8
            KaakaoButton {
                objectName: "okButton"
                text: qsTr("OK")
                highlighted: true
                onClicked: goToLineDialog.accept()
            }
            KaakaoButton {
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