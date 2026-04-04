import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import net.veskuh.pari 1.0

ColumnLayout {
    id: aiPane
    property var currentEditor: null
    property bool isThinking: false
    property string thinkingText: ""
    property bool diffVisible: false

    property alias text: aiOutputPane.text
    property alias diff: diffView.text

    readonly property bool isDark: appSettings.systemThemeIsDark

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
        aiOutputPane.text = "";
        diffView.text = "";
        var prompt = aiMessagePane.text;
        if (currentEditor && currentEditor.selection != "" ) {
            llm.sendPrompt("You are AI code assistant. \
Follow the instructions by user. You will get a full file content and user selection at the code in the end of message.\
 Be short in your response, no chatting or politness, just code or comment. User: " + prompt + "File: \n```\n" + currentEditor.text + "\n```"+ "Selection: \n```\n" + currentEditor.selection + "\n```");
        } else if (currentEditor) {
            llm.sendPrompt("You are AI code assistant. Follow the instructions given for the code in the end of message. Be short in your response, no chatting or politness, just code or comment. " + prompt + "\n```\n" + currentEditor.text + "\n```");
        }
    }

    // --- AI Output Area (The 'Paper' Well) ---
    Rectangle {
        id: aiOutputWell
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 4
        radius: 2
        color: isDark ? "#1a1a1a" : "#ffffff"
        border.color: isDark ? "#121212" : "#bcbcbc"
        border.width: 1

        // Inset shadow for depth
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            color: "transparent"
            border.color: isDark ? "#000000" : "black"
            opacity: isDark ? 0.2 : 0.05
            radius: 2
        }

        StackLayout {
            id: rightSideStackLayout
            anchors.fill: parent
            anchors.margins: 2
            currentIndex: aiPane.diffVisible ? 1 : 0

            // AI Output View
            ScrollView {
                clip: true
                TextArea {
                    id: aiOutputPane
                    readOnly: true
                    placeholderText: "✨ AI assistant output..."
                    wrapMode: Text.WordWrap
                    textFormat: Text.MarkdownText
                    font.family: appSettings.fontFamily
                    font.pointSize: appSettings.fontSize - 1
                    color: isDark ? "#d0d0d0" : "#1a1c1c"
                    padding: 10
                    background: null
                }
            }

            // Diff View
            ScrollView {
                clip: true
                TextArea {
                    id: diffView
                    textFormat: Text.RichText
                    readOnly: true
                    placeholderText: "Diff view..."
                    wrapMode: Text.NoWrap
                    font.family: "Menlo"
                    font.pointSize: appSettings.fontSize - 1
                    color: isDark ? "#d0d0d0" : "#1a1c1c"
                    padding: 10
                    background: null
                }
            }
        }

        // --- LCD Thinking Indicator ---
        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            visible: aiPane.isThinking
            radius: 4
            z: 10
            
            color: isDark ? "#2a1a00" : "#fff9e6" // Warm LCD amber base
            border.color: isDark ? "#ffaa00" : "#ffcc00"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                
                RowLayout {
                    spacing: 8
                    Rectangle {
                        width: 8; height: 8; radius: 4
                        color: "#ffaa00"
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.3; duration: 800 }
                            NumberAnimation { from: 0.3; to: 1.0; duration: 800 }
                        }
                    }
                    Label {
                        text: "AI IS THINKING..."
                        font.family: "Menlo"
                        font.pixelSize: 12
                        font.bold: true
                        color: isDark ? "#ffaa00" : "#805500"
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    Flickable {
                        id: thinkingFlickable
                        anchors.fill: parent
                        contentHeight: thinkingOutput.height
                        clip: true
                        
                        Text {
                            id: thinkingOutput
                            width: thinkingFlickable.width
                            text: aiPane.thinkingText
                            color: isDark ? "#ffaa00" : "#805500"
                            wrapMode: Text.WordWrap
                            font.family: "Menlo"
                            font.pixelSize: 11
                            
                            onTextChanged: {
                                if (contentHeight > thinkingFlickable.height) {
                                    thinkingFlickable.contentY = contentHeight - thinkingFlickable.height;
                                }
                            }
                        }
                    }
                }
            }
            
            // Subtle scanline effect for LCD
            Rectangle {
                anchors.fill: parent
                opacity: 0.05
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "black" }
                    GradientStop { position: 0.5; color: "transparent" }
                    GradientStop { position: 1.0; color: "black" }
                }
            }
        }
    }

    // --- AI Input Area (The 'Machine' Control) ---
    ColumnLayout {
        Layout.fillWidth: true
        Layout.margins: 10
        spacing: 8

        Label {
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
                TextArea {
                    id: aiMessagePane
                    placeholderText: "Command the machine..."
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

            ComboBox {
                id: promptComboBox
                Layout.fillWidth: true
                property string prompt: "Add comments to the following code."
                model: ["Comment code", "Explain code", "Refactor code", "Write tests", "Custom prompt"]
                
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0: prompt = "Add comments to the following code. Do not add any other text, just the commented code."; break;
                    case 1: prompt = "Explain the following code in a clear and concise way."; break;
                    case 2: prompt = "Refactor the following code to improve its readability."; break;
                    case 3: prompt = "Write unit tests for the following code using Qt Test."; break;
                    }
                    if (currentIndex < 4) aiMessagePane.text = prompt;
                }
            }

            PariToolButton {
                id: sendButton
                text: "SEND"
                iconSource: "qrc:/assets/send.png"
                isPrimary: true
                enabled: currentEditor && currentEditor.text !== "" && aiMessagePane.text !== "" && !llm.busy
                onClicked: {
                    aiPane.diffVisible = false;
                    aiPane.sendPrompt();
                }
            }
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
