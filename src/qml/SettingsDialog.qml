import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: settingsDialog
    title: "Settings"
    standardButtons: Dialog.Ok | Dialog.Cancel
    modal: true
    width: 400
    height: 300

    property alias ollamaUrl: ollamaUrlField.text
    property alias ollamaModel: ollamaModelComboBox.currentValue
    property alias fontFamily: fontFamilyField.text
    property alias fontSize: fontSizeSpinBox.value

    onAccepted: {
        appSettings.ollamaUrl = ollamaUrl
        appSettings.ollamaModel = ollamaModelComboBox.currentValue
        appSettings.fontFamily = fontFamily
        appSettings.fontSize = fontSize
    }

    onOpened: {
        ollamaUrlField.text = appSettings.ollamaUrl
        var modelIndex = appSettings.availableModels.indexOf(appSettings.ollamaModel)
        if (modelIndex !== -1) {
            ollamaModelComboBox.currentIndex = modelIndex
        }
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
            RowLayout {
                ComboBox {
                    id: ollamaModelComboBox
                    model: appSettings.availableModels
                    textRole: "text"
                    valueRole: "value"
                    Layout.fillWidth: true
                    currentIndex: model: appSettings.availableModels.indexOf(appSettings.ollamaModel)
                    onCurrentIndexChanged: {
                        if (currentIndex !== -1) {
                            appSettings.ollamaModel = appSettings.availableModels[currentIndex]
                        }
                    }
                }
                Button {
                    text: "Refresh"
                    onClicked: llm.listModels()
                }
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
