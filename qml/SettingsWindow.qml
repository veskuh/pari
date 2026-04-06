import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: settingsWindow
    title: "Settings"
    width: 600
    height: 520

    property alias ollamaUrl: ollamaUrlField.text
    property alias ollamaModel: ollamaModelComboBox.currentValue

    FontDialog {
        id: fontDialog
        title: "Select Font"
        onAccepted: {
            fontValue.text = `${fontDialog.selectedFont.family}, ${fontDialog.selectedFont.pointSize}`;
        }
    }

    ColorDialog {
        id: colorDialog
        property ColorButton activeButton

        function openForColor(button, initialColor) {
            colorDialog.selectedColor = initialColor;
            colorDialog.open();
            if (colorDialog.activeButton) {
                colorDialog.accepted.disconnect(colorDialog.activeButton.updateColor);
            }
            colorDialog.accepted.connect(button.updateColor);
            colorDialog.activeButton = button;
        }
    }

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

            Label {
                text: "API URL:"
            }
            TextField {
                id: ollamaUrlField
                objectName: "ollamaUrlField"
                Layout.fillWidth: true
            }

            Label {
                text: "Model:"
            }
            RowLayout {
                ComboBox {
                    id: ollamaModelComboBox
                    objectName: "ollamaModelComboBox"
                    model: appSettings.availableModels
                    Layout.fillWidth: true
                }
                Button {
                    text: "Refresh"
                    objectName: "refreshButton"
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

            Label {
                text: "Font:"
            }
            RowLayout {
                Label {
                    id: fontValue
                    text: `${appSettings.fontFamily}, ${appSettings.fontSize}`
                    Layout.fillWidth: true
                }
                Button {
                    text: "Select"
                    onClicked: fontDialog.open()
                }
            }
        }

        Label {
            text: "Highlighting Settings"
            font.bold: true
        }

        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true

            RowLayout {
                spacing: 10
                Item { Layout.preferredWidth: 120 }
                Label { text: "Dark:"; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                Label { text: "Light:"; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
            }

            SettingColorRow {
                labelText: "Keyword Color:"
                colorDialog: colorDialog
                darkColor: appSettings.darkTheme.keywordColor
                lightColor: appSettings.lightTheme.keywordColor
                onDarkColorSelected: (c) => appSettings.darkTheme.keywordColor = c
                onLightColorSelected: (c) => appSettings.lightTheme.keywordColor = c
            }

            SettingColorRow {
                labelText: "String Color:"
                colorDialog: colorDialog
                darkColor: appSettings.darkTheme.stringColor
                lightColor: appSettings.lightTheme.stringColor
                onDarkColorSelected: (c) => appSettings.darkTheme.stringColor = c
                onLightColorSelected: (c) => appSettings.lightTheme.stringColor = c
            }

            SettingColorRow {
                labelText: "Comment Color:"
                colorDialog: colorDialog
                darkColor: appSettings.darkTheme.commentColor
                lightColor: appSettings.lightTheme.commentColor
                onDarkColorSelected: (c) => appSettings.darkTheme.commentColor = c
                onLightColorSelected: (c) => appSettings.lightTheme.commentColor = c
            }

            SettingColorRow {
                labelText: "Type Color:"
                colorDialog: colorDialog
                darkColor: appSettings.darkTheme.typeColor
                lightColor: appSettings.lightTheme.typeColor
                onDarkColorSelected: (c) => appSettings.darkTheme.typeColor = c
                onLightColorSelected: (c) => appSettings.lightTheme.typeColor = c
            }

            SettingColorRow {
                labelText: "Number Color:"
                colorDialog: colorDialog
                darkColor: appSettings.darkTheme.numberColor
                lightColor: appSettings.lightTheme.numberColor
                onDarkColorSelected: (c) => appSettings.darkTheme.numberColor = c
                onLightColorSelected: (c) => appSettings.lightTheme.numberColor = c
            }

            SettingColorRow {
                labelText: "Preprocessor Color:"
                colorDialog: colorDialog
                darkColor: appSettings.darkTheme.preprocessorColor
                lightColor: appSettings.lightTheme.preprocessorColor
                onDarkColorSelected: (c) => appSettings.darkTheme.preprocessorColor = c
                onLightColorSelected: (c) => appSettings.lightTheme.preprocessorColor = c
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
                objectName: "applyButton"
                onClicked: {
                    appSettings.ollamaUrl = ollamaUrlField.text;
                    appSettings.ollamaModel = ollamaModelComboBox.currentValue;
                    appSettings.fontFamily = fontDialog.selectedFont.family;
                    appSettings.fontSize = fontDialog.selectedFont.pointSize;

                    appSettings.saveColors();

                    settingsWindow.close();
                }
            }
            Button {
                text: "Cancel"
                onClicked: {
                    settingsWindow.close();
                }
            }
        }
    }

    Timer {
        id: timer
        // Populate selectionList a bit later as content is not ready so quick
        interval: 1000
        repeat: false
        onTriggered: {
            var modelIndex = appSettings.availableModels.indexOf(appSettings.ollamaModel);
            if (modelIndex !== -1) {
                ollamaModelComboBox.currentIndex = modelIndex;
            }
        }
    }

    Component.onCompleted: {
        ollamaUrlField.text = appSettings.ollamaUrl;
        var modelIndex = appSettings.availableModels.indexOf(appSettings.ollamaModel);
        if (modelIndex !== -1) {
            ollamaModelComboBox.currentIndex = modelIndex;
        }
        fontValue.text = `${appSettings.fontFamily}, ${appSettings.fontSize}`;
        timer.start();
    }
}
