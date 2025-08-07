import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: settingsDialog
    title: "Settings"
    standardButtons: Dialog.Ok | Dialog.Cancel
    modal: false
    width: 400
    height: 300

    property alias ollamaUrl: ollamaUrlField.text
    property alias ollamaModel: ollamaModelField.text
    property alias fontFamily: fontFamilyField.text
    property alias fontSize: fontSizeSpinBox.value

    onAccepted: {
        appSettings.ollamaUrl = ollamaUrl
        appSettings.ollamaModel = ollamaModel
        appSettings.fontFamily = fontFamily
        appSettings.fontSize = fontSize
    }

    onOpened: {
        ollamaUrlField.text = appSettings.ollamaUrl
        ollamaModelField.text = appSettings.ollamaModel
        fontFamilyField.text = appSettings.fontFamily
        fontSizeSpinBox.value = appSettings.fontSize
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Label {
            text: "Ollama Settings"
            font.bold: true
        }

        GridLayout {
            columns: 2

            Label { text: "API URL:" }
            TextField {
                id: ollamaUrlField
                Layout.fillWidth: true
            }

            Label { text: "Model:" }
            TextField {
                id: ollamaModelField
                Layout.fillWidth: true
            }
        }

        Label {
            text: "Editor Settings"
            font.bold: true
        }

        GridLayout {
            columns: 2

            Label { text: "Font Family:" }
            TextField {
                id: fontFamilyField
                Layout.fillWidth: true
            }

            Label { text: "Font Size:" }
            SpinBox {
                id: fontSizeSpinBox
                from: 8
                to: 72
                stepSize: 1
            }
        }
    }
}
