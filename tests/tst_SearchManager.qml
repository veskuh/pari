import QtQuick
import QtTest
import QtQuick.Controls
import "../qml/editor"

Item {
    id: rootItem
    width: 400
    height: 600

    property string searchText: ""
    property string replaceText: ""
    property int resultsCount: 0
    property int dirtyCount: 0

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
        property alias replaceText: rootItem.replaceText
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

    // Mock Pane
    Item {
        id: mockPane
        signal textChangedByUser()
        function refreshLineNumbers() {}
        
        Connections {
            target: mockPane
            function onTextChangedByUser() {
                rootItem.dirtyCount++;
            }
        }
    }

    SearchManager {
        id: searchManager
        editor: mockEditor
        overlay: mockOverlay
        pane: mockPane
    }

    TestCase {
        name: "SearchManagerTests"
        when: windowShown

        function init() {
            mockEditor.text = "hello world\nhello again"
            mockEditor.cursorPosition = 0
            searchManager.sessionStartPosition = 0
            rootItem.searchText = ""
            rootItem.replaceText = ""
            rootItem.resultsCount = 0
            rootItem.dirtyCount = 0
        }

        function test_findNext() {
            rootItem.searchText = "hello"
            searchManager.findNext(true)
            compare(mockEditor.cursorPosition, 5)
            
            searchManager.findNext(false)
            compare(mockEditor.cursorPosition, 17)
        }

        function test_findPrevious() {
            rootItem.searchText = "hello"
            mockEditor.cursorPosition = 17
            searchManager.findPrevious()
            compare(mockEditor.cursorPosition, 17)
        }

        function test_replaceNext() {
            rootItem.searchText = "hello"
            rootItem.replaceText = "hi"
            
            // First find it
            searchManager.findNext(true)
            compare(mockEditor.selectionStart, 0)
            compare(mockEditor.selectionEnd, 5)
            
            // Replace it
            searchManager.replaceNext()
            // Text should be "hi world\nhello again"
            compare(mockEditor.text, "hi world\nhello again")
            // It should have marked as dirty
            compare(rootItem.dirtyCount, 1)
            // It should have found the next one
            compare(mockEditor.selectionStart, 9)
            compare(mockEditor.selectionEnd, 14)
        }

        function test_replaceAll() {
            rootItem.searchText = "hello"
            rootItem.replaceText = "hi"
            
            searchManager.replaceAll()
            compare(mockEditor.text, "hi world\nhi again")
            // It should have marked as dirty
            compare(rootItem.dirtyCount, 1)
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
