import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: settingsWindow
    title: "Settings"
    width: 400
    height: 300

    property alias ollamaUrl: ollamaUrlField.text
    property alias ollamaModel: ollamaModelComboBox.currentValue
    property alias fontFamily: fontFamilyField.text
    property alias fontSize: fontSizeSpinBox.value

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.margins: 10

        Label {
            text: "Ollama Settings"
            font.bold: true
        }

        GridLayout {
            columns: 2
            columnSpacing: 10

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
                    Layout.fillWidth: true
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
            columnSpacing: 10

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

        Item {
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Button {
                text: "Apply"
                onClicked: {
                    appSettings.ollamaUrl = ollamaUrlField.text
                    appSettings.ollamaModel = ollamaModelComboBox.currentValue
                    appSettings.fontFamily = fontFamilyField.text
                    appSettings.fontSize = fontSizeSpinBox.value
                    settingsWindow.close()
                }
            }
            Button {
                text: "Cancel"
                onClicked: {
                    settingsWindow.close()
                }
            }
        }
    }

    Component.onCompleted: {
        ollamaUrlField.text = appSettings.ollamaUrl
        var modelIndex = appSettings.availableModels.indexOf(appSettings.ollamaModel)
        if (modelIndex !== -1) {
            ollamaModelComboBox.currentIndex = modelIndex
        }
        fontFamilyField.text = appSettings.fontFamily
        fontSizeSpinBox.value = appSettings.fontSize
    }
}
