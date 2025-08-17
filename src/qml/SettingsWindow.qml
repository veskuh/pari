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
            fontValue.text = `${fontDialog.selectedFont.family}, ${fontDialog.selectedFont.pointSize}`
        }
    }

    ColorDialog {
        id: colorDialog
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

            Label { text: "Font:" }
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

            Label { text: "Dark:" }
            Label { text: "Light:" }

            Label { text: "Keyword Color:" }
            ColorButton {
                width: 50
                height: 25
                color: appSettings.darkTheme.keywordColor
                border.color: "gray"
                border.width: 1
                onClicked: () => {
                    colorDialog.selectedColor = appSettings.darkTheme.keywordColor;
                    colorDialog.open();
                    colorDialog.accepted.disconnect(this.updateColor); // Disconnect previous
                    colorDialog.accepted.connect(this.updateColor); // Connect new
                }
                function updateColor() {
                    appSettings.darkTheme.keywordColor = colorDialog.selectedColor;
                }
            }
            ColorButton {
                width: 50
                height: 25
                color: appSettings.lightTheme.keywordColor
                border.color: "gray"
                border.width: 1
                onClicked: () => {
                    colorDialog.selectedColor = appSettings.lightTheme.keywordColor;
                    colorDialog.open();
                    colorDialog.accepted.disconnect(this.updateColor); // Disconnect previous
                    colorDialog.accepted.connect(this.updateColor); // Connect new
                }
                function updateColor() {
                    appSettings.lightTheme.keywordColor = colorDialog.selectedColor;
                }
            }

            Label { text: "String Color:" }
            ColorButton {
                width: 50
                height: 25
                color: appSettings.darkTheme.stringColor
                border.color: "gray"
                border.width: 1
                onClicked: () => {
                    colorDialog.selectedColor = appSettings.darkTheme.stringColor;
                    colorDialog.open();
                    colorDialog.accepted.disconnect(this.updateColor); // Disconnect previous
                    colorDialog.accepted.connect(this.updateColor); // Connect new
                }
                function updateColor() {
                    appSettings.darkTheme.stringColor = colorDialog.selectedColor;
                }
            }
            ColorButton {
                width: 50
                height: 25
                color: appSettings.lightTheme.stringColor
                border.color: "gray"
                border.width: 1
                onClicked: () => {
                    colorDialog.selectedColor = appSettings.lightTheme.stringColor;
                    colorDialog.open();
                    colorDialog.accepted.disconnect(this.updateColor); // Disconnect previous
                    colorDialog.accepted.connect(this.updateColor); // Connect new
                }
                function updateColor() {
                    appSettings.lightTheme.stringColor = colorDialog.selectedColor;
                }
            }

            Label { text: "Comment Color:" }
            ColorButton {
                width: 50
                height: 25
                color: appSettings.darkTheme.commentColor
                border.color: "gray"
                border.width: 1
                onClicked: () => {
                    colorDialog.selectedColor = appSettings.darkTheme.commentColor;
                    colorDialog.open();
                    colorDialog.accepted.disconnect(this.updateColor); // Disconnect previous
                    colorDialog.accepted.connect(this.updateColor); // Connect new
                }
                function updateColor() {
                    appSettings.darkTheme.commentColor = colorDialog.selectedColor;
                }
            }
            ColorButton {
                width: 50
                height: 25
                color: appSettings.lightTheme.commentColor
                border.color: "gray"
                border.width: 1
                onClicked: () => {
                    colorDialog.selectedColor = appSettings.lightTheme.commentColor;
                    colorDialog.open();
                    colorDialog.accepted.disconnect(this.updateColor); // Disconnect previous
                    colorDialog.accepted.connect(this.updateColor); // Connect new
                }
                function updateColor() {
                    appSettings.lightTheme.commentColor = colorDialog.selectedColor;
                }
            }

            Label { text: "Type Color:" }
            ColorButton {
                width: 50
                height: 25
                color: appSettings.darkTheme.typeColor
                border.color: "gray"
                border.width: 1
                onClicked: () => {
                    colorDialog.selectedColor = appSettings.darkTheme.typeColor;
                    colorDialog.open();
                    colorDialog.accepted.disconnect(this.updateColor); // Disconnect previous
                    colorDialog.accepted.connect(this.updateColor); // Connect new
                }
                function updateColor() {
                    appSettings.darkTheme.typeColor = colorDialog.selectedColor;
                }
            }
            ColorButton {
                width: 50
                height: 25
                color: appSettings.lightTheme.typeColor
                border.color: "gray"
                border.width: 1
                onClicked: () => {
                    colorDialog.selectedColor = appSettings.lightTheme.typeColor;
                    colorDialog.open();
                    colorDialog.accepted.disconnect(this.updateColor); // Disconnect previous
                    colorDialog.accepted.connect(this.updateColor); // Connect new
                }
                function updateColor() {
                    appSettings.lightTheme.typeColor = colorDialog.selectedColor;
                }
            }

            Label { text: "Number Color:" }
            ColorButton {
                width: 50
                height: 25
                color: appSettings.darkTheme.numberColor
                border.color: "gray"
                border.width: 1
                onClicked: () => {
                    colorDialog.selectedColor = appSettings.darkTheme.numberColor;
                    colorDialog.open();
                    colorDialog.accepted.disconnect(this.updateColor); // Disconnect previous
                    colorDialog.accepted.connect(this.updateColor); // Connect new
                }
                function updateColor() {
                    appSettings.darkTheme.numberColor = colorDialog.selectedColor;
                }
            }
            ColorButton {
                width: 50
                height: 25
                color: appSettings.lightTheme.numberColor
                border.color: "gray"
                border.width: 1
                onClicked: () => {
                    colorDialog.selectedColor = appSettings.lightTheme.numberColor;
                    colorDialog.open();
                    colorDialog.accepted.disconnect(this.updateColor); // Disconnect previous
                    colorDialog.accepted.connect(this.updateColor); // Connect new
                }
                function updateColor() {
                    appSettings.lightTheme.numberColor = colorDialog.selectedColor;
                }
            }

            Label { text: "Preprocessor Color:" }
            ColorButton {
                width: 50
                height: 25
                color: appSettings.darkTheme.preprocessorColor
                border.color: "gray"
                border.width: 1
                onClicked: () => {
                    colorDialog.selectedColor = appSettings.darkTheme.preprocessorColor;
                    colorDialog.open();
                    colorDialog.accepted.disconnect(this.updateColor); // Disconnect previous
                    colorDialog.accepted.connect(this.updateColor); // Connect new
                }
                function updateColor() {
                    appSettings.darkTheme.preprocessorColor = colorDialog.selectedColor;
                }
            }
            ColorButton {
                width: 50
                height: 25
                color: appSettings.lightTheme.preprocessorColor
                border.color: "gray"
                border.width: 1
                onClicked: () => {
                    colorDialog.selectedColor = appSettings.lightTheme.preprocessorColor;
                    colorDialog.open();
                    colorDialog.accepted.disconnect(this.updateColor); // Disconnect previous
                    colorDialog.accepted.connect(this.updateColor); // Connect new
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
                    appSettings.ollamaUrl = ollamaUrlField.text
                    appSettings.ollamaModel = ollamaModelComboBox.currentValue
                    appSettings.fontFamily = fontDialog.selectedFont.family
                    appSettings.fontSize = fontDialog.selectedFont.pointSize

                    appSettings.saveColors()

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

    Timer {
        id: timer
        // Populate selectionList a bit later as content is not ready so quick
        interval: 1000
        repeat: false
        onTriggered: {
            var modelIndex = appSettings.availableModels.indexOf(appSettings.ollamaModel)
            if (modelIndex !== -1) {
                ollamaModelComboBox.currentIndex = modelIndex
            }
        }
    }


    Component.onCompleted: {
        ollamaUrlField.text = appSettings.ollamaUrl
        var modelIndex = appSettings.availableModels.indexOf(appSettings.ollamaModel)
        if (modelIndex !== -1) {
            ollamaModelComboBox.currentIndex = modelIndex
        }
        fontValue.text = `${appSettings.fontFamily}, ${appSettings.fontSize}`

        // Colors are now directly bound, no need to update here

        console.log("Colors set")


        timer.start()
    }
}
