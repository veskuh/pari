import QtQuick
import QtTest
import QtQuick.Controls
import Kaakao
import QtQuick.Layouts
import "../qml/editor"

Item {
    width: 600
    height: 400

    GoToLineDialog {
        id: goToLineDialog
    }

    SignalSpy {
        id: spy
        target: goToLineDialog
        signalName: "goToLine"
    }

    TestCase {
        name: "GoToLineDialogTests"
        when: windowShown

        function init() {
            spy.clear()
            // Clear text field
            var textInput = findChildByType(goToLineDialog.contentItem, "QQuickTextField")
            if (textInput) {
                textInput.text = ""
            }
        }

        // QML test helper to find a child by type string
        function findChildByType(parent, typeString) {
            if (parent.toString().indexOf(typeString) !== -1 || parent.toString().indexOf("TextField") !== -1) return parent;
            for (var i = 0; i < parent.children.length; ++i) {
                var found = findChildByType(parent.children[i], typeString)
                if (found) return found
            }
            return null
        }

        function findChildByText(parent, text) {
            if (parent.text === text) return parent;
            for (var i = 0; i < parent.children.length; ++i) {
                var found = findChildByText(parent.children[i], text)
                if (found) return found
            }
            return null
        }

        function test_initial_state() {
            compare(goToLineDialog.title, "Go to Line")
        }

        function test_goto_line_success() {
            goToLineDialog.open()
            verify(goToLineDialog.visible)

            var textInput = findChildByType(goToLineDialog.contentItem, "QQuickTextField")
            verify(textInput !== null, "TextField should exist")

            textInput.text = "42"

            var okBtn = findChild(goToLineDialog, "okButton")
            verify(okBtn !== null, "OK button should exist")
            mouseClick(okBtn)

            compare(spy.count, 1)
            var args = spy.signalArguments[0]
            compare(args[0], 42)
        }

        function findChild(parent, objectName) {
            if (!parent) return null;
            if (parent.objectName === objectName) return parent;

            if (parent.children) {
                for (var i = 0; i < parent.children.length; i++) {
                    var found = findChild(parent.children[i], objectName);
                    if (found) return found;
                }
            }
            if (parent.contentItem && parent.contentItem !== parent) {
                var foundInContent = findChild(parent.contentItem, objectName);
                if (foundInContent) return foundInContent;
            }
            return null;
        }
    }
}
