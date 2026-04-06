import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml"

Item {
    id: root
    width: 400
    height: 600

    property QtObject appSettings: QtObject {
        property bool systemThemeIsDark: false
        property string fontFamily: "Menlo"
        property int fontSize: 12
    }

    property QtObject llm: QtObject {
        id: mockLlm
        property bool busy: false
        signal sendPrompt(string prompt)
        signal newLineReceived(string line)
    }

    QtObject {
        id: mockDiffUtils
        function createDiff(oldText, newText) {
            return "DIFF[" + oldText + "][" + newText + "]"
        }
    }

    OutputPane {
        id: outputPane
        anchors.fill: parent
        diffUtils: mockDiffUtils
    }

    TestCase {
        name: "OutputPaneTests"
        when: windowShown

        function init() {
            outputPane.text = ""
            outputPane.diff = ""
            outputPane.isThinking = false
            outputPane.thinkingText = ""
            outputPane.diffVisible = false
            llm.busy = false
        }

        function test_initial_state() {
            var aiOutputPane = findChild(outputPane, "aiOutputPane")
            verify(aiOutputPane !== null)
            
            var diffView = findChild(outputPane, "diffView")
            verify(diffView !== null)
            
            var thinkingIndicator = findChild(outputPane, "thinkingIndicator")
            verify(!thinkingIndicator.visible)
        }

        function test_thinking_tags_parsing() {
            llm.newLineReceived("Some text <think>AI is contemplating")
            verify(outputPane.text.indexOf("Some text") !== -1)
            verify(outputPane.isThinking)
            compare(outputPane.thinkingText, "AI is contemplating\n\n")

            llm.newLineReceived(" the meaning of code</think>Final response")
            verify(!outputPane.isThinking)
            // Note: The logic adds \n\n twice in this specific sequence
            compare(outputPane.thinkingText, "AI is contemplating\n\n the meaning of code\n\n")
            verify(outputPane.text.indexOf("Final response") !== -1)
        }

        function test_diff_update() {
            outputPane.text = "NewText"
            outputPane.updateDiff("OldText")
            verify(outputPane.diff.indexOf("OldText") !== -1, "Should contain OldText")
            verify(outputPane.diff.indexOf("NewText") !== -1, "Should contain NewText")
        }

        function findChild(parent, objectName) {
            if (parent.objectName === objectName) return parent;
            
            if (parent.children) {
                for (var i = 0; i < parent.children.length; i++) {
                    var found = findChild(parent.children[i], objectName);
                    if (found) return found;
                }
            }
            
            if (parent.contentItem) {
                var foundInContent = findChild(parent.contentItem, objectName);
                if (foundInContent) return foundInContent;
            }
            
            return null;
        }
    }
}
