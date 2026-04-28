import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml/sidebar"

Item {
    width: 600
    height: 400

    QtObject {
        id: mockFileSystem
        property bool renameResult: true
        property string lastOldPath: ""
        property string lastNewPath: ""

        function renameFile(oldPath, newPath) {
            lastOldPath = oldPath;
            lastNewPath = newPath;
            return renameResult;
        }
    }

    property alias fileSystem: mockFileSystem

    RenameDialog {
        id: renameDialog
        oldPath: "/fake/path/old_file.txt"
    }

    TestCase {
        name: "RenameDialogTests"
        when: windowShown

        function init() {
            renameDialog.oldPath = "/fake/path/old_file.txt"
            mockFileSystem.renameResult = true
            mockFileSystem.lastOldPath = ""
            mockFileSystem.lastNewPath = ""
            // To clear the text input
            var textInput = findChildByProperty(renameDialog.contentItem, "placeholderText", "New name");
            if (textInput) {
                textInput.text = "";
            }
        }

        // QML test helper to find a child by a specific type and optionally property
        function findChildByText(parent, text) {
            if (parent.text === text) return parent;
            for (var i = 0; i < parent.children.length; ++i) {
                var found = findChildByText(parent.children[i], text)
                if (found) return found
            }
            return null
        }

        function findChildByProperty(parent, prop, val) {
            if (parent[prop] === val) return parent;
            for (var i = 0; i < parent.children.length; ++i) {
                var found = findChildByProperty(parent.children[i], prop, val)
                if (found) return found
            }
            return null
        }

        function test_initial_state() {
            compare(renameDialog.title, "Rename File")
            compare(renameDialog.oldPath, "/fake/path/old_file.txt")
        }

        function test_rename_success() {
            renameDialog.open()
            verify(renameDialog.visible)

            var textInput = findChildByProperty(renameDialog.contentItem, "placeholderText", "New name")
            verify(textInput !== null, "TextField should exist")

            textInput.text = "new_file.txt"

            var okBtn = findChild(renameDialog, "renameButton")
            verify(okBtn !== null, "Rename button should exist")

            // Should be enabled now
            verify(okBtn.enabled)

            mouseClick(okBtn)

            compare(mockFileSystem.lastOldPath, "/fake/path/old_file.txt")
            compare(mockFileSystem.lastNewPath, "/fake/path/new_file.txt")
            verify(!renameDialog.visible)
        }

        function test_rename_validation_empty() {
            renameDialog.open()
            verify(renameDialog.visible)

            var textInput = findChildByProperty(renameDialog.contentItem, "placeholderText", "New name")
            textInput.text = "   "

            var okBtn = findChild(renameDialog, "renameButton")
            verify(!okBtn.enabled, "Rename button should be disabled for empty text")

            renameDialog.reject()
        }

        function test_rename_validation_slash() {
            renameDialog.open()
            verify(renameDialog.visible)

            var textInput = findChildByProperty(renameDialog.contentItem, "placeholderText", "New name")
            textInput.text = "folder/file.txt"

            var okBtn = findChild(renameDialog, "renameButton")
            verify(!okBtn.enabled, "Rename button should be disabled when text has slash")

            renameDialog.reject()
        }

        function test_rename_failure() {
            mockFileSystem.renameResult = false

            renameDialog.open()
            verify(renameDialog.visible)

            var textInput = findChildByProperty(renameDialog.contentItem, "placeholderText", "New name")
            textInput.text = "new_file.txt"

            var okBtn = findChild(renameDialog, "renameButton")
            mouseClick(okBtn)

            // Dialog should stay visible because it failed
            verify(renameDialog.visible)

            renameDialog.reject()
        }
    }
}
