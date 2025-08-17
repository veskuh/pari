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

    Component {
        id: colorPickerButtonComponent
        Button {
            property color displayColor: "transparent"
            property bool done: false

            width: 50
            height: 25

            background: Rectangle {
                color: displayColor
                border.color: "gray"
                border.width: 1
            }

            onClicked: {
                colorDialog.selectedColor = displayColor;
                done = false
                colorDialog.open();
//                colorDialog.accepted.disconnectAll(updateDisplayColor);
//colorDialog.accepted.disconnectAll();
                colorDialog.accepted.connect(updateDisplayColor);
            }
            function updateDisplayColor() {
                if (!done) {
                    displayColor = colorDialog.selectedColor;
                    done = true
                }
                //colorDialog.disconnect(updateDisplayColor)

            }
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
            Loader {
                id: darkKeywordColorLoader
                sourceComponent: colorPickerButtonComponent
                property color displayColor: appSettings.darkTheme.keywordColor
            }
            Loader {
                id: lightKeywordColorLoader
                sourceComponent: colorPickerButtonComponent
                property color displayColor: appSettings.lightTheme.keywordColor
            }

            Label { text: "String Color:" }
            Loader {
                id: darkStringColorLoader
                sourceComponent: colorPickerButtonComponent
                property color displayColor: appSettings.darkTheme.stringColor
            }
            Loader {
                id: lightStringColorLoader
                sourceComponent: colorPickerButtonComponent
                property color displayColor: appSettings.lightTheme.stringColor
            }

            Label { text: "Comment Color:" }
            Loader {
                id: darkCommentColorLoader
                sourceComponent: colorPickerButtonComponent
                property color displayColor: appSettings.darkTheme.commentColor
            }
            Loader {
                id: lightCommentColorLoader
                sourceComponent: colorPickerButtonComponent
                property color displayColor: appSettings.lightTheme.commentColor
            }

            Label { text: "Type Color:" }
            Loader {
                id: darkTypeColorLoader
                sourceComponent: colorPickerButtonComponent
                property color displayColor: appSettings.darkTheme.typeColor
            }
            Loader {
                id: lightTypeColorLoader
                sourceComponent: colorPickerButtonComponent
                property color displayColor: appSettings.lightTheme.typeColor
            }

            Label { text: "Number Color:" }
            Loader {
                id: darkNumberColorLoader
                sourceComponent: colorPickerButtonComponent
                property color displayColor: appSettings.darkTheme.numberColor
            }
            Loader {
                id: lightNumberColorLoader
                sourceComponent: colorPickerButtonComponent
                property color displayColor: appSettings.lightTheme.numberColor
            }

            Label { text: "Preprocessor Color:" }
            Loader {
                id: darkPreprocessorColorLoader
                sourceComponent: colorPickerButtonComponent
                property color displayColor: appSettings.darkTheme.preprocessorColor
            }
            Loader {
                id: lightPreprocessorColorLoader
                sourceComponent: colorPickerButtonComponent
                property color displayColor: appSettings.lightTheme.preprocessorColor
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

                    var currentTheme = appSettings.darkTheme;
                    currentTheme.keywordColor = darkKeywordColorLoader.item.displayColor;
                    currentTheme.stringColor = darkStringColorLoader.item.displayColor;
                    currentTheme.commentColor = darkCommentColorLoader.item.displayColor;
                    currentTheme.typeColor = darkTypeColorLoader.item.displayColor;
                    currentTheme.numberColor = darkNumberColorLoader.item.displayColor;
                    currentTheme.preprocessorColor = darkPreprocessorColorLoader.item.displayColor;


                    currentTheme = appSettings.lightTheme;
                    currentTheme.keywordColor = lightKeywordColorLoader.item.displayColor;
                    currentTheme.stringColor = lightStringColorLoader.item.displayColor;
                    currentTheme.commentColor = lightCommentColorLoader.item.displayColor;
                    currentTheme.typeColor = lightTypeColorLoader.item.displayColor;
                    currentTheme.numberColor = lightNumberColorLoader.item.displayColor;
                    currentTheme.preprocessorColor = lightPreprocessorColorLoader.item.displayColor;

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

        var currentTheme = appSettings.lightTheme;
        lightKeywordColorLoader.item.displayColor = currentTheme.keywordColor;
        lightStringColorLoader.item.displayColor = currentTheme.stringColor;
        lightCommentColorLoader.item.displayColor = currentTheme.commentColor;
        lightTypeColorLoader.item.displayColor = currentTheme.typeColor;
        lightNumberColorLoader.item.displayColor = currentTheme.numberColor;
        lightPreprocessorColorLoader.item.displayColor = currentTheme.preprocessorColor;

        currentTheme = appSettings.darkTheme;
        darkKeywordColorLoader.item.displayColor = currentTheme.keywordColor;
        darkStringColorLoader.item.displayColor = currentTheme.stringColor;
        darkCommentColorLoader.item.displayColor = currentTheme.commentColor;
        darkTypeColorLoader.item.displayColor = currentTheme.typeColor;
        darkNumberColorLoader.item.displayColor = currentTheme.numberColor;
        darkPreprocessorColorLoader.item.displayColor = currentTheme.preprocessorColor;

        console.log("Colors set")


        timer.start()
    }
}
