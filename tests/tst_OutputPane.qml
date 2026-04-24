import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml/app"
import "../qml/ai"

Item {
    id: root
    width: 400
    height: 600

    PariTheme {
        id: pariTheme
    }

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
        id: markdownFormatter
        function toHtml(md) {
            return md.replace("<", "&lt;").replace(">", "&gt;")
        }
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
            outputPane.fullAiText = ""
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
            // "Some text " was immediately before the tag, currently not followed by \n
            verify(outputPane.fullAiText.indexOf("Some text ") !== -1)
            verify(outputPane.isThinking)
            // Original thinking logic: if (trim != "") += "\n\n"
            compare(outputPane.thinkingText, "AI is contemplating\n\n")

            llm.newLineReceived(" the meaning of code</think>Final response")
            verify(!outputPane.isThinking)
            // Added " the meaning of code", then tag hit -> += "\n\n"
            compare(outputPane.thinkingText, "AI is contemplating\n\n the meaning of code\n\n")
            // "Final response" is correctly followed by \n
            verify(outputPane.fullAiText.indexOf("Final response\n") !== -1)
        }

        function test_diff_update() {
            outputPane.fullAiText = "NewText"
            outputPane.updateDiff("OldText")
            verify(outputPane.diff.indexOf("OldText") !== -1, "Should contain OldText")
            verify(outputPane.diff.indexOf("NewText") !== -1, "Should contain NewText")
        }

        function test_backslash_stability_regression() {
            outputPane.fullAiText = ""
            var backslashLine = "Path: C:\\\\Users\\\\Name"
            
            for (var i = 0; i < 5; i++) {
                llm.newLineReceived(backslashLine)
            }
            
            // Should add exactly one \n per chunk
            var expectedLength = (backslashLine.length + 1) * 5
            compare(outputPane.fullAiText.length, expectedLength)
            
            // Count backslashes: should be exactly 2 * 5 = 10
            var matches = outputPane.fullAiText.match(/\\\\/g)
            compare(matches ? matches.length : 0, 10)
        }

        function test_complex_cpp_output_stability() {
            var aiOutputPane = findChild(outputPane, "aiOutputPane")
            verify(aiOutputPane !== null)

            // Verify the specific complex snippet reported by the user
            outputPane.fullAiText = ""
            // Llm signal emits lines WITHOUT the newline char
            var complexSnippet = [
                "```cpp",
                "#include <iostream>",
                "using namespace std;",
                "",
                "int main() {",
                "    cout << \"In windows we can have path c:\\\\kissa.txt\\n\";",
                "    cout << \"\\\\ \\n\";",
                "    cout << \"\\\\\\n\";",
                "    cout << \"\\\"This is a \\\"test\\\" string with \\\\\\\\backslash\\\"\\n\";",
                "    cout << \"C:\\\\Program Files\\\\MyApp\\\\\\n\";",
                "    cout << \"echo \\\"Hello\\\" world\\n\";",
                "    cout << \"This is a * wildcard\\n\";",
                "    cout << \"This is a ? wildcard\\n\";",
                "    cout << \"This is a $ variable\\n\";",
                "    cout << \"This is a | pipe\\n\";",
                "    cout << \"This is a `command`]\\n\";",
                "    cout << \"\\\"This is a \\\"escaped\\\" string\\\"\\n\";",
                "    cout << \"This is a \\\\n newline\\n\";",
                "    return 0;",
                "}",
                "```"
            ]

            for (var i = 0; i < complexSnippet.length; i++) {
                llm.newLineReceived(complexSnippet[i])
                wait(10)
            }

            // Verify total length: (each line length + 1 for added \n)
            var expectedLength = 0;
            for (var i = 0; i < complexSnippet.length; i++) {
                expectedLength += complexSnippet[i].length + 1;
            }
            compare(outputPane.fullAiText.length, expectedLength)

            // Verify specific problematic lines were preserved exactly in the buffer
            verify(outputPane.fullAiText.indexOf("C:\\\\Program Files") !== -1)
            verify(outputPane.fullAiText.indexOf("* wildcard") !== -1)
            verify(outputPane.fullAiText.indexOf("`command`") !== -1)

            // Verify the actual TextArea property received the text and it's escaped
            verify(aiOutputPane.text.indexOf("&lt;iostream&gt;") !== -1)
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
