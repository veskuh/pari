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
                Layout.fillWidth: true
            }

            Label {
                text: "Model:"
            }
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

        GridLayout {
            columns: 3
            columnSpacing: 10

            Item {}

            Label {
                text: "Dark:"
            }
            Label {
                text: "Light:"
            }

            Label {
                text: "Keyword Color:"
            }
            ColorButton {
                color: appSettings.darkTheme.keywordColor
                onClicked: () => {
                    colorDialog.openForColor(this, appSettings.darkTheme.keywordColor);
                }
                function updateColor() {
                    appSettings.darkTheme.keywordColor = colorDialog.selectedColor;
                }
            }
            ColorButton {
                color: appSettings.lightTheme.keywordColor
                onClicked: () => {
                    colorDialog.openForColor(this, appSettings.lightTheme.keywordColor);
                }
                function updateColor() {
                    appSettings.lightTheme.keywordColor = colorDialog.selectedColor;
                }
            }

            Label {
                text: "String Color:"
            }
            ColorButton {
                color: appSettings.darkTheme.stringColor
                onClicked: () => {
                    colorDialog.openForColor(this, appSettings.darkTheme.stringColor);
                }
                function updateColor() {
                    appSettings.darkTheme.stringColor = colorDialog.selectedColor;
                }
            }
            ColorButton {
                color: appSettings.lightTheme.stringColor
                onClicked: () => {
                    colorDialog.openForColor(this, appSettings.lightTheme.stringColor);
                }
                function updateColor() {
                    appSettings.lightTheme.stringColor = colorDialog.selectedColor;
                }
            }

            Label {
                text: "Comment Color:"
            }
            ColorButton {
                color: appSettings.darkTheme.commentColor
                onClicked: () => {
                    colorDialog.openForColor(this, appSettings.darkTheme.commentColor);
                }
                function updateColor() {
                    appSettings.darkTheme.commentColor = colorDialog.selectedColor;
                }
            }
            ColorButton {
                color: appSettings.lightTheme.commentColor
                onClicked: () => {
                    colorDialog.openForColor(this, appSettings.lightTheme.commentColor);
                }
                function updateColor() {
                    appSettings.lightTheme.commentColor = colorDialog.selectedColor;
                }
            }

            Label {
                text: "Type Color:"
            }
            ColorButton {
                color: appSettings.darkTheme.typeColor
                onClicked: () => {
                    colorDialog.openForColor(this, appSettings.darkTheme.typeColor);
                }
                function updateColor() {
                    appSettings.darkTheme.typeColor = colorDialog.selectedColor;
                }
            }
            ColorButton {
                color: appSettings.lightTheme.typeColor
                onClicked: () => {
                    colorDialog.openForColor(this, appSettings.lightTheme.typeColor);
                }
                function updateColor() {
                    appSettings.lightTheme.typeColor = colorDialog.selectedColor;
                }
            }

            Label {
                text: "Number Color:"
            }
            ColorButton {
                color: appSettings.darkTheme.numberColor
                onClicked: () => {
                    colorDialog.openForColor(this, appSettings.darkTheme.numberColor);
                }
                function updateColor() {
                    appSettings.darkTheme.numberColor = colorDialog.selectedColor;
                }
            }
            ColorButton {
                color: appSettings.lightTheme.numberColor
                onClicked: () => {
                    colorDialog.openForColor(this, appSettings.lightTheme.numberColor);
                }
                function updateColor() {
                    appSettings.lightTheme.numberColor = colorDialog.selectedColor;
                }
            }

            Label {
                text: "Preprocessor Color:"
            }
            ColorButton {
                color: appSettings.darkTheme.preprocessorColor
                onClicked: () => {
                    colorDialog.openForColor(this, appSettings.darkTheme.preprocessorColor);
                }
                function updateColor() {
                    appSettings.darkTheme.preprocessorColor = colorDialog.selectedColor;
                }
            }
            ColorButton {
                color: appSettings.lightTheme.preprocessorColor
                onClicked: () => {
                    colorDialog.openForColor(this, appSettings.lightTheme.preprocessorColor);
                }
                function updateColor() {
                    appSettings.lightTheme.preprocessorColor = colorDialog.selectedColor;
                }
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
