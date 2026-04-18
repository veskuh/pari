import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

ColumnLayout {
    id: aiPane
    property var currentEditor: null
    property bool isThinking: false
    property string thinkingText: ""
    property bool diffVisible: false

    property alias text: aiOutputPane.text
    property alias diff: diffView.text

    property var diffUtils: null

    readonly property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false

    function updateDiff(code) {
        if (diffUtils && code.length > 0 && aiOutputPane.text.length > 0) {
            aiPane.diff = diffUtils.createDiff(code, aiOutputPane.text);
        } else {
            aiPane.diff = "";
        }
    }

    function sendPrompt() {
        aiOutputPane.text = "";
        diffView.text = "";
        var prompt = aiInput.messageText;
        if (currentEditor && currentEditor.selection != "" ) {
            llm.sendPrompt("You are AI code assistant. \
Follow the instructions by user. You will get a full file content and user selection at the code in the end of message.\
 Be short in your response, no chatting or politness, just code or comment. User: " + prompt + "File: \n```\n" + currentEditor.text + "\n```"+ "Selection: \n```\n" + currentEditor.selection + "\n```");
        } else if (currentEditor) {
            llm.sendPrompt("You are AI code assistant. Follow the instructions given for the code in the end of message. Be short in your response, no chatting or politness, just code or comment. " + prompt + "\n```\n" + currentEditor.text + "\n```");
        }
    }

    PariPaperWell {
        id: aiOutputWell
        isDark: aiPane.isDark
        Layout.fillHeight: true
        
        StackLayout {
            id: rightSideStackLayout
            anchors.fill: parent
            currentIndex: aiPane.diffVisible ? 1 : 0

            PariReadOnlyTextArea {
                id: aiOutputPane
                objectName: "aiOutputPane"
                placeholderText: qsTr("✨ AI assistant output...")
            }

            PariReadOnlyTextArea {
                id: diffView
                objectName: "diffView"
                textFormat: Text.RichText
                placeholderText: qsTr("Diff view...")
                wrapMode: Text.NoWrap
                textAreaFont.family: "Menlo"
            }
        }

        AiThinkingIndicator {
            id: thinkingIndicator
            objectName: "thinkingIndicator"
            visible: aiPane.isThinking
            isDark: aiPane.isDark
            thinkingText: aiPane.thinkingText
        }
    }

    // --- AI Input Area (The 'Machine' Control) ---
    AiInputControl {
        id: aiInput
        objectName: "aiInput"
        Layout.fillWidth: true
        Layout.margins: 10
        isDark: aiPane.isDark
        llmBusy: llm.busy
        currentEditor: aiPane.currentEditor
        onSendClicked: {
            aiPane.diffVisible = false;
            aiPane.sendPrompt();
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
                        if (currentLine.trim() !== "") aiPane.thinkingText += "\n\n";
                        currentLine = "";
                    }
                } else {
                    var startThinkIndex = currentLine.indexOf("<think>");
                    if (startThinkIndex !== -1) {
                        aiOutputPane.text += currentLine.substring(0, startThinkIndex);
                        aiPane.isThinking = true;
                        aiPane.thinkingText = "";
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
