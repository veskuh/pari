import QtQuick
import QtTest
import QtQuick.Controls
import "../qml/editor"

Item {
    id: rootItem
    width: 400
    height: 600

    property string searchText: ""
    property int resultsCount: 0

    // Mock Overlay
    QtObject {
        id: mockOverlay
        property string searchText: rootItem.searchText
        function updateResults(count) {
            rootItem.resultsCount = count
        }
    }

    // Mock Editor
    TextArea {
        id: mockEditor
        text: "hello world\nhello again"
    }

    SearchManager {
        id: searchManager
        editor: mockEditor
        overlay: mockOverlay
    }

    TestCase {
        name: "SearchManagerTests"
        when: windowShown

        function init() {
            mockEditor.text = "hello world\nhello again"
            mockEditor.cursorPosition = 0
            rootItem.searchText = ""
            rootItem.resultsCount = 0
        }

        function test_findNext() {
            rootItem.searchText = "hello"
            searchManager.findNext()
            compare(mockEditor.cursorPosition, 5)
            compare(mockEditor.selectedText, "hello")
            
            searchManager.findNext()
            // "hello world\n" starts at 0. 12 chars.
            // second "hello" starts at 12. ends at 17.
            compare(mockEditor.cursorPosition, 17)
            compare(rootItem.resultsCount, 2)
        }

        function test_findPrevious() {
            rootItem.searchText = "hello"
            mockEditor.cursorPosition = 17
            searchManager.findPrevious()
            compare(mockEditor.cursorPosition, 5)
        }

        function test_updateResults() {
            rootItem.searchText = "hello"
            searchManager.updateResults()
            compare(rootItem.resultsCount, 2)
            
            rootItem.searchText = "nonexistent"
            searchManager.updateResults()
            compare(rootItem.resultsCount, 0)
        }
    }
}
