import QtQuick
import QtTest
import QtQuick.Controls
import "../qml/editor"

Item {
    width: 400
    height: 600

    // Mock editor for testing coordinates
    TextArea {
        id: mockEditor
        text: "Line 1\nLine 2\nLine 3"
        font.pixelSize: 12
        font.family: "Menlo"
    }

    QtObject {
        id: mockSearchManager
        property bool filterActive: false
        property var filteredLineNumbers: []
    }

    LineNumberGutter {
        id: gutter
        editorFont: mockEditor.font
        isDark: false
        searchManager: mockSearchManager
    }

    TestCase {
        name: "LineNumberGutterTests"
        when: windowShown

        function test_calculation() {
            var coords = gutter.calculateLineCoordinates(mockEditor)
            compare(coords.length, 3)
            // Coordinates should be increasing
            verify(coords[1].y > coords[0].y)
            verify(coords[2].y > coords[1].y)
            // Line numbers should be correct
            compare(coords[0].number, 1)
            compare(coords[1].number, 2)
            compare(coords[2].number, 3)
        }

        function test_refresh() {
            gutter.refresh(mockEditor)
            compare(gutter.lineCoordinates.length, 3)
            compare(gutter.lineCoordinates[0].number, 1)
            
            mockEditor.text = "One line"
            gutter.refresh(mockEditor)
            compare(gutter.lineCoordinates.length, 1)
        }

        function test_highlight() {
            gutter.currentLineIndex = 1
            compare(gutter.currentLineIndex, 1)
        }
    }
}
