import QtQuick
import QtTest
import QtQuick.Controls
import Kaakao
import QtQuick.Layouts
import "../qml/app"
import "../qml/editor"

Item {
    width: 800
    height: 600

    PariTheme {
        id: pariTheme
    }

    // Mock appSettings
    QtObject {
        id: mockAppSettings
        property bool systemThemeIsDark: false
        property string fontFamily: "Menlo"
        property int fontSize: 12
    }

    // Mock lspClient
    QtObject {
        id: mockLsp
        signal formattingResult(string result)
        signal completionItems(var items)
        function format(path, text) {}
        function documentChanged(path, text) {}
        function requestCompletion(path, line, character) {}
    }

    // Mock appWindow for palette
    Item {
        id: mockAppWindow
        property var palette: {
            "window": "white",
            "windowText": "black",
            "text": "black",
            "base": "white"
        }
    }

    CodeEditorPane {
        id: editorPane
        anchors.fill: parent
        // dependencies provided by scope lookup from rootItem
        filePath: "test.cpp"
    }

    TestCase {
        name: "CodeEditorPaneTests"
        when: windowShown

        function init() {
            editorPane.text = ""
            editorPane.dirty = false
        }

        SignalSpy {
            id: spy
            target: editorPane
            signalName: "textChangedByUser"
        }

        function test_text_entry() {
            var textArea = findChild(editorPane, "codeEditor")
            verify(textArea !== null)
            
            spy.clear()
            textArea.forceActiveFocus()
            textArea.text = "Hello"
            keyClick(" ")
            verify(spy.count >= 1)
        }

        function test_line_numbers() {
            editorPane.text = "Line 1\nLine 2\nLine 3"
            var gutter = findChild(editorPane, "lineNumberGutter")
            verify(gutter !== null)
            // Wait for refresh (it happens onTextChanged)
            wait(100)
            compare(gutter.lineCoordinates.length, 3)
        }

        function findChild(parent, objectName) {
            if (parent.objectName === objectName) return parent;
            
            // Search children
            if (parent.children) {
                for (var i = 0; i < parent.children.length; i++) {
                    var found = findChild(parent.children[i], objectName);
                    if (found) return found;
                }
            }
            
            // Search contentItem for Controls
            if (parent.contentItem) {
                var foundInContent = findChild(parent.contentItem, objectName);
                if (foundInContent) return foundInContent;
            }
            
            return null;
        }
    }
}
