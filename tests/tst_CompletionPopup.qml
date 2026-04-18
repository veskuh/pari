import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml/editor"

Item {
    width: 600
    height: 400

    QtObject {
        id: mockCodeEditor
        property string text: "Hello World"
        property int cursorPosition: 5
    }

    property alias codeEditor: mockCodeEditor

    CompletionPopup {
        id: completionPopup
    }

    TestCase {
        name: "CompletionPopupTests"
        when: windowShown

        function init() {
            completionPopup.close()
            mockCodeEditor.text = "Hello World"
            mockCodeEditor.cursorPosition = 5
            completionPopup.typedCharacters = ""
        }

        // QML test helper to find a child by type string
        function findChildByType(parent, typeString) {
            if (parent.toString().indexOf(typeString) !== -1) return parent;
            for (var i = 0; i < parent.children.length; ++i) {
                var found = findChildByType(parent.children[i], typeString)
                if (found) return found
            }
            return null
        }

        function getListView() {
            return findChildByType(completionPopup.contentItem, "QQuickListView")
        }

        function test_showCompletions() {
            var items = ["apple", "banana", "cherry"]
            completionPopup.showCompletions(items)

            verify(completionPopup.visible, "Popup should be visible")

            var listView = getListView()
            verify(listView !== null, "ListView should exist")
            compare(listView.count, 3, "ListView should have 3 items")
            compare(listView.currentIndex, 0, "Current index should be 0")
        }

        function test_filtering() {
            var items = ["apple", "banana", "apricot", "cherry"]
            completionPopup.showCompletions(items)

            var listView = getListView()
            compare(listView.count, 4)

            completionPopup.typedCharacters = "ap"

            // Wait for bindings/signals to process
            wait(50)

            compare(listView.count, 2, "List should be filtered to 'apple' and 'apricot'")
        }

        function test_keyboard_navigation_and_insertion() {
            var items = ["apple", "banana", "cherry"]
            completionPopup.showCompletions(items)

            var listView = getListView()
            compare(listView.currentIndex, 0)

            // Simulate Down arrow key press
            keyClick(Qt.Key_Down)
            compare(listView.currentIndex, 1)

            // Simulate Up arrow key press
            keyClick(Qt.Key_Up)
            compare(listView.currentIndex, 0)

            // Go to 'banana'
            keyClick(Qt.Key_Down)
            compare(listView.currentIndex, 1)

            // Simulate Return key press to insert
            keyClick(Qt.Key_Return)

            compare(mockCodeEditor.text, "Hellobanana World")
            compare(mockCodeEditor.cursorPosition, 11) // 5 (initial) + 6 (banana)

            verify(!completionPopup.visible, "Popup should close after insertion")
        }

        function test_backspace() {
            var items = ["apple", "banana", "cherry"]
            completionPopup.showCompletions(items)

            completionPopup.typedCharacters = "app"

            keyClick(Qt.Key_Backspace)
            compare(completionPopup.typedCharacters, "ap")
        }

        function test_typing() {
            var items = ["apple", "banana", "cherry"]
            completionPopup.showCompletions(items)

            completionPopup.typedCharacters = ""

            keyClick(Qt.Key_A)
            compare(completionPopup.typedCharacters, "a")

            keyClick(Qt.Key_P)
            compare(completionPopup.typedCharacters, "ap")
        }
    }
}
