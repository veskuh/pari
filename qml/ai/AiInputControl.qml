import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kaakao 1.0
import "../common"

ColumnLayout {
    id: inputControl
    property bool isDark: false
    property bool llmBusy: false
    property var currentEditor: null
    property alias messageText: aiMessagePane.text

    signal sendClicked

    spacing: 8

    KaakaoLabel {
        text: qsTr("AI PROMPT")
        font.family: "Public Sans"
        font.pixelSize: 10
        font.bold: true
        color: isDark ? "#888888" : "#646464"
    }

    // Recessed Input Well
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        radius: 4
        color: isDark ? "#121212" : "#fdfdfd"
        border.color: isDark ? "#1a1a1a" : "#bcbcbc"
        border.width: 1

        ScrollView {
            anchors.fill: parent
            anchors.margins: 4
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            KaakaoTextArea {
                id: aiMessagePane
                objectName: "aiMessagePane"
                placeholderText: qsTr("Command the machine...")
                wrapMode: Text.WordWrap
                font.family: "Menlo"
                font.pixelSize: 12
                color: isDark ? "#4aa9ff" : "#0051a6"
                background: null
                padding: 8

                onTextChanged: {
                    if (text !== promptComboBox.prompt) {
                        promptComboBox.currentIndex = 4;
                    }
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        KaakaoComboBox {
            id: promptComboBox
            objectName: "promptComboBox"
            Layout.fillWidth: true
            property string prompt: "Add comments to the following code."
            model: [qsTr("Comment code"), qsTr("Explain code"), qsTr("Refactor code"), qsTr("Write tests"), qsTr("Custom prompt")]

            onCurrentIndexChanged: {
                switch (currentIndex) {
                case 0:
                    prompt = "Add comments to the following code. Do not add any other text, just the commented code.";
                    break;
                case 1:
                    prompt = "Explain the following code in a clear and concise way.";
                    break;
                case 2:
                    prompt = "Refactor the following code to improve its readability.";
                    break;
                case 3:
                    prompt = "Write unit tests for the following code using Qt Test.";
                    break;
                }
                if (currentIndex < 4)
                    aiMessagePane.text = prompt;
            }
        }

        PariToolButton {
            id: sendButton
            objectName: "sendButton"
            text: qsTr("SEND")
            iconSource: "qrc:/assets/send.png"
            isPrimary: true
            enabled: currentEditor && currentEditor.text !== "" && aiMessagePane.text !== "" && !llmBusy
            onClicked: inputControl.sendClicked()
        }
    }
}
