import QtQuick
import QtTest
import QtQuick.Controls
import "../qml"

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

    LineNumberGutter {
        id: gutter
        editorFont: mockEditor.font
        isDark: false
    }

    TestCase {
        name: "LineNumberGutterTests"
        when: windowShown

        function test_calculation() {
            var coords = gutter.calculateLineCoordinates(mockEditor)
            compare(coords.length, 3)
            // Coordinates should be increasing
            verify(coords[1] > coords[0])
            verify(coords[2] > coords[1])
        }

        function test_refresh() {
            gutter.refresh(mockEditor)
            compare(gutter.lineCoordinates.length, 3)
            
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
