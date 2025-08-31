import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import net.veskuh.pari 1.0

ColumnLayout {
    id: aiPane // Keep the ID for isThinking property
    property bool isThinking: false
    property string thinkingText: ""

    property alias text: aiOutputPane.text
    property alias diff: diffView.text

    DiffUtils {
        id: diffUtils
    }

    function updateDiff(code) {
        if (code.length > 0 && aiOutputPane.text.length > 0) {
            aiPane.diff = diffUtils.createDiff(code, aiOutputPane.text);
        } else {
            aiPane.diff = "";
        }
    }

    function sendPrompt() {
        aiOutputPane.text = ""; // Clear previous output
        diffView.text = ""; // Clear previous diff
        var prompt = aiMessagePane.text;
        if (codeEditor.selection != "" ) {
            llm.sendPrompt("You are AI code assistant. \
Follow the instructions by user. You will get a full file content and user selection at the code in the end of message.\
 Be short in your response, no chatting or politness, just code or comment. User: " + prompt + "File: \n```\n" + codeEditor.text + "\n```"+ "Selection: \n```\n" + codeEditor.selection + "\n```");
        } else {
            llm.sendPrompt("You are AI code assistant. Follow the instructions given for the code in the end of message. Be short in your response, no chatting or politness, just code or comment. " + prompt + "\n```\n" + codeEditor.text + "\n```");
        }
    }

    TabBar {
        id: rightSideTabBar
        Layout.fillWidth: true
        currentIndex: 0
        TabButton {
            text: qsTr("AI Output")
        }
        TabButton {
            text: qsTr("Diff View")
        }
    }

    StackLayout {
        id: rightSideStackLayout
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: rightSideTabBar.currentIndex

        // Pane for AI Output
        Item {
            id: aiOutputItem
            ScrollView {
                id: aiOutputScrollView
                width: aiOutputItem.width
                height: aiOutputItem.height
                clip: true

                TextArea {
                    id: aiOutputPane
                    readOnly: true
                    placeholderText: "AI assistant output will appear here..."
                    wrapMode: Text.WordWrap
                    textFormat: Text.MarkdownText
                }
            }

            // Thinking Overlay
            Rectangle {
                id: thinkingOverlay
                anchors.fill: parent
                color: "#AA000000"
                opacity: aiPane.isThinking ? 1.0 : 0.0
                visible: opacity > 0.01
                z: 10
                Behavior on opacity {
                    PropertyAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Label {
                        text: "Thinking..."
                        font.bold: true
                        color: "white"
                    }
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        Flickable {
                            id: flickable
                            clip: true
                            Text {
                                id: thinkingOutput
                                width: parent.width

                                text: aiPane.thinkingText
                                color: "white"
                                wrapMode: Text.WordWrap
                                font.family: appSettings.fontFamily
                                font.pointSize: appSettings.fontSize
                                onTextChanged: {
                                    if (contentHeight > flickable.height) {
                                        flickable.contentY = contentHeight - flickable.height;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Pane for Diff View
        Item {
            id: diffViewItem
            ScrollView {
                width: diffViewItem.width
                height: diffViewItem.height
                clip: true
                TextArea {
                    id: diffView
                    textFormat: Text.RichText
                    readOnly: true
                    placeholderText: "Diff will appear here..."
                    wrapMode: Text.NoWrap
                    font.family: "Courier"
                }
            }
        }
    }

    // AI Input Controls - Placed below the tab view
    Label {
        text: qsTr("AI Prompt")
        font.bold: true
        Layout.topMargin: 10
        Layout.leftMargin: 10
    }
    TextField {
        id: aiMessagePane
        Layout.fillWidth: true
        Layout.preferredHeight: 80
        Layout.rightMargin: 10
        Layout.leftMargin: 10
        wrapMode: Text.WordWrap

        placeholderText: "Type a prompt or select a command..."
        onTextChanged: {
            if (text !== promptComboBox.prompt) {
                promptComboBox.currentIndex = 4;
            }
        }
        onAccepted: {
            aiPane.sendPrompt();
        }
    }
    RowLayout {
        Layout.topMargin: 5
        Layout.alignment: Qt.AlignRight

        ComboBox {
            id: promptComboBox
            property string prompt: "Add comments to the following code. Do not add any other text, just the commented code."
            model: ["Comment the code", "Explain the code", "Refactor the code", "Write unit tests", "Custom prompt"]
            onCurrentTextChanged: {
                switch (currentIndex) {
                case 0:
                    prompt = "Add comments to the following code. Do not add any other text, just the commented code.";
                    break;
                case 1:
                    prompt = "Explain the following code in a clear and concise way. Focus on the overall purpose of the code and the role of each major component.";
                    break;
                case 2:
                    prompt = "Refactor the following code to improve its readability, performance, and maintainability. Do not add any new functionality.";
                    break;
                case 3:
                    prompt = "Write unit tests for the following code. Use the Qt Test framework and cover all major functionality.";
                    break;
                }
                aiMessagePane.text = prompt;
            }
        }
        Button {
            id: sendButton
            text: "Send"
            enabled: codeEditor.text !== "" && aiMessagePane.text !== "" && !llm.busy
            icon.source: "qrc:/assets/send.png"
            icon.height: 24
            icon.width: 24

            onClicked: {
                aiPane.sendPrompt();
            }
            highlighted: true
        }
    }

    Connections {
        target: llm
        function onNewLineReceived(line) {
            var currentLine = line;
            while (currentLine.length > 0) {
                if (aiPane.isThinking) {
                    var endThinkIndex = currentLine.indexOf("</think>");
                    if (endThinkIndex !== -1) {
                        aiPane.thinkingText += currentLine.substring(0, endThinkIndex);
                        aiPane.thinkingText += "\n\n";
                        aiPane.isThinking = false;
                        currentLine = currentLine.substring(endThinkIndex + 8);
                    } else {
                        aiPane.thinkingText += currentLine;

                        if (currentLine.trim() !== "") {
                            aiPane.thinkingText += "\n\n";
                        }

                        currentLine = "";
                    }
                } else {
                    var startThinkIndex = currentLine.indexOf("<think>");
                    if (startThinkIndex !== -1) {
                        aiOutputPane.text += currentLine.substring(0, startThinkIndex);
                        aiPane.isThinking = true;
                        aiPane.thinkingText = ""; // Clear previous thinking
                        currentLine = currentLine.substring(startThinkIndex + 7);
                    } else {
                        aiOutputPane.text += currentLine;
                        currentLine = "";
                    }
                }
            }
        }
    }
}
