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

    // These mock objects must match the IDs used in the component (which are global context properties)
    property alias textDocumentSearcher: mockSearcher

    // Mock searcher instance
    QtObject {
        id: mockSearcher
        function find(doc, pattern, from, options) {
            if (pattern === "hello") {
                if (from <= 0) return 5;
                if (from >= 5 && from <= 12) return 17;
            }
            return -1;
        }
        function applyFilter() {}
        function clearFilter() {}
    }

    // Mock Overlay
    QtObject {
        id: mockOverlay
        property alias searchText: rootItem.searchText
        property bool matchCase: false
        property bool filterActive: false
        function updateResults(total) {
            rootItem.resultsCount = total
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
        // The property must exist on the Item
        property int incrementalSearchAnchor: 0
    }

    TestCase {
        name: "SearchManagerTests"
        when: windowShown

        function init() {
            mockEditor.cursorPosition = 0
            searchManager.incrementalSearchAnchor = 0
            rootItem.searchText = ""
            rootItem.resultsCount = 0
        }

        function test_findNext() {
            rootItem.searchText = "hello"
            // Typing triggers findNext(true)
            searchManager.findNext(true)
            compare(mockEditor.cursorPosition, 5)
            
            // Clicking Next triggers findNext(false)
            searchManager.findNext(false)
            compare(mockEditor.cursorPosition, 17)
        }

        function test_findPrevious() {
            rootItem.searchText = "hello"
            mockEditor.cursorPosition = 17
            searchManager.findPrevious()
            compare(mockEditor.cursorPosition, 17)
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
