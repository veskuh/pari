import QtQuick
import QtTest
import QtQuick.Controls
import "../qml/editor"

Item {
    width: 400
    height: 600

    property string lastDocumentChanged: ""
    property string lastCompletionRequest: ""

    // Mock LSP Client
    QtObject {
        id: mockLsp
        function documentChanged(path, text) {
            lastDocumentChanged = path
        }
        function requestCompletion(path, line, character) {
            lastCompletionRequest = path + ":" + line + ":" + character
        }
    }

    // Mock Editor (simulating just enough for logic)
    QtObject {
        id: mockEditor
        property string text: ""
        property int length: 0
        property int cursorPosition: 0
        property bool activeFocus: true
        
        function getText(start, end) {
            return text.substring(start, end)
        }
        
        function insert(pos, string) {
            text = text.substring(0, pos) + string + text.substring(pos)
        }
    }

    EditorLogic {
        id: editorLogic
        editor: mockEditor
        lspClient: mockLsp
        filePath: "test.cpp"
    }

    TestCase {
        name: "EditorLogicTests"
        when: windowShown

        function init() {
            mockEditor.text = ""
            mockEditor.length = 0
            mockEditor.cursorPosition = 0
            lastDocumentChanged = ""
            lastCompletionRequest = ""
            editorLogic.previousLength = 0
        }

        function test_autoIndent() {
            mockEditor.text = "void main() {\n"
            mockEditor.cursorPosition = mockEditor.text.length
            editorLogic.handleAutoIndent()
            compare(mockEditor.text, "void main() {\n    ")
        }

        function test_lspTrigger() {
            // Simulate typing a dot
            mockEditor.text = "obj."
            mockEditor.length = 4
            mockEditor.cursorPosition = 4
            // EditorLogic expects length to increase by 1
            editorLogic.previousLength = 3
            
            editorLogic.handleTextChanged()
            compare(lastDocumentChanged, "test.cpp")
            verify(lastCompletionRequest.indexOf("test.cpp:0:4") !== -1)
        }
    }
}
