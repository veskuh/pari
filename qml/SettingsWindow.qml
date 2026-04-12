import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: settingsWindow
    title: "Settings"
    width: 600
    height: 520

    // Use a local reference to the global objects to avoid repeated checks and make it safer for tests
    readonly property var _appSettings: (typeof appSettings !== 'undefined') ? appSettings : null
    readonly property var _llm: (typeof llm !== 'undefined') ? llm : null

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
                    model: _appSettings ? _appSettings.availableModels : []
                    Layout.fillWidth: true
                }
                Button {
                    text: "Refresh"
                    objectName: "refreshButton"
                    onClicked: if (_llm) _llm.listModels()
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
                    text: _appSettings ? `${_appSettings.fontFamily}, ${_appSettings.fontSize}` : ""
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
                Label {
                    text: "Dark:"
                    Layout.preferredWidth: 50
                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    text: "Light:"
                    Layout.preferredWidth: 50
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            SettingColorRow {
                labelText: "Keyword Color:"
                colorDialog: colorDialog
                darkColor: _appSettings ? _appSettings.darkTheme.keywordColor : "black"
                lightColor: _appSettings ? _appSettings.lightTheme.keywordColor : "black"
                onDarkColorSelected: (c) => { if (_appSettings) _appSettings.darkTheme.keywordColor = c }
                onLightColorSelected: (c) => { if (_appSettings) _appSettings.lightTheme.keywordColor = c }
            }

            SettingColorRow {
                labelText: "String Color:"
                colorDialog: colorDialog
                darkColor: _appSettings ? _appSettings.darkTheme.stringColor : "black"
                lightColor: _appSettings ? _appSettings.lightTheme.stringColor : "black"
                onDarkColorSelected: (c) => { if (_appSettings) _appSettings.darkTheme.stringColor = c }
                onLightColorSelected: (c) => { if (_appSettings) _appSettings.lightTheme.stringColor = c }
            }

            SettingColorRow {
                labelText: "Comment Color:"
                colorDialog: colorDialog
                darkColor: _appSettings ? _appSettings.darkTheme.commentColor : "black"
                lightColor: _appSettings ? _appSettings.lightTheme.commentColor : "black"
                onDarkColorSelected: (c) => { if (_appSettings) _appSettings.darkTheme.commentColor = c }
                onLightColorSelected: (c) => { if (_appSettings) _appSettings.lightTheme.commentColor = c }
            }

            SettingColorRow {
                labelText: "Type Color:"
                colorDialog: colorDialog
                darkColor: _appSettings ? _appSettings.darkTheme.typeColor : "black"
                lightColor: _appSettings ? _appSettings.lightTheme.typeColor : "black"
                onDarkColorSelected: (c) => { if (_appSettings) _appSettings.darkTheme.typeColor = c }
                onLightColorSelected: (c) => { if (_appSettings) _appSettings.lightTheme.typeColor = c }
            }

            SettingColorRow {
                labelText: "Number Color:"
                colorDialog: colorDialog
                darkColor: _appSettings ? _appSettings.darkTheme.numberColor : "black"
                lightColor: _appSettings ? _appSettings.lightTheme.numberColor : "black"
                onDarkColorSelected: (c) => { if (_appSettings) _appSettings.darkTheme.numberColor = c }
                onLightColorSelected: (c) => { if (_appSettings) _appSettings.lightTheme.numberColor = c }
            }

            SettingColorRow {
                labelText: "Preprocessor Color:"
                colorDialog: colorDialog
                darkColor: _appSettings ? _appSettings.darkTheme.preprocessorColor : "black"
                lightColor: _appSettings ? _appSettings.lightTheme.preprocessorColor : "black"
                onDarkColorSelected: (c) => { if (_appSettings) _appSettings.darkTheme.preprocessorColor = c }
                onLightColorSelected: (c) => { if (_appSettings) _appSettings.lightTheme.preprocessorColor = c }
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
                    if (_appSettings) {
                        _appSettings.ollamaUrl = ollamaUrlField.text;
                        _appSettings.ollamaModel = ollamaModelComboBox.currentValue;
                        _appSettings.fontFamily = fontDialog.selectedFont.family;
                        _appSettings.fontSize = fontDialog.selectedFont.pointSize;
                        _appSettings.saveColors();
                    }
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
            if (_appSettings) {
                var modelIndex = _appSettings.availableModels.indexOf(_appSettings.ollamaModel);
                if (modelIndex !== -1) {
                    ollamaModelComboBox.currentIndex = modelIndex;
                }
            }
        }
    }

    Component.onCompleted: {
        if (_appSettings) {
            ollamaUrlField.text = _appSettings.ollamaUrl;
            var modelIndex = _appSettings.availableModels.indexOf(_appSettings.ollamaModel);
            if (modelIndex !== -1) {
                ollamaModelComboBox.currentIndex = modelIndex;
            }
            fontValue.text = `${_appSettings.fontFamily}, ${_appSettings.fontSize}`;
        }
        timer.start();
    }
}
