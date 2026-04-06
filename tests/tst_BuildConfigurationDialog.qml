import QtQuick
import QtTest
import QtQuick.Controls
import "../qml"

Item {
    width: 450
    height: 250

    BuildConfigurationDialog {
        id: dialog
    }

    SignalSpy {
        id: saveSpy
        target: dialog
        signalName: "saveConfiguration"
    }

    TestCase {
        name: "BuildConfigurationDialogTests"
        when: windowShown

        function init() {
            saveSpy.clear()
            dialog.buildCommand = ""
            dialog.runCommand = ""
            dialog.cleanCommand = ""
        }

        function findChildByText(parent, text) {
            for (var i = 0; i < parent.children.length; ++i) {
                var child = parent.children[i]
                if (child.text === text)
                    return child

                var found = findChildByText(child, text)
                if (found) return found
            }
            return null
        }

        function findTextFields(parent, results) {
            // Check if it's actually a TextField by looking for common properties
            if (parent.hasOwnProperty("placeholderText") && parent.hasOwnProperty("text")) {
                // Ensure we don't count internal components of the TextField
                results.push(parent)
                return; // Don't look at children of TextField
            }
            for (var i = 0; i < parent.children.length; ++i) {
                findTextFields(parent.children[i], results)
            }
        }

        function test_initial_state() {
            compare(dialog.title, "Configure Build")
        }

        function test_save() {
            var textFields = []
            findTextFields(dialog.contentItem, textFields)

            // Should find exactly 3 TextFields: build, run, clean
            compare(textFields.length, 3, "Expected 3 text fields")

            var buildCommandField = textFields[0]
            var runCommandField = textFields[1]
            var cleanCommandField = textFields[2]

            buildCommandField.text = "make all"
            runCommandField.text = "./app"
            cleanCommandField.text = "make clean"

            var saveBtn = findChildByText(dialog.contentItem, "Save")
            verify(saveBtn !== null, "Save button should exist")

            mouseClick(saveBtn)

            compare(saveSpy.count, 1)
            var args = saveSpy.signalArguments[0]
            compare(args[0], "make all")
            compare(args[1], "./app")
            compare(args[2], "make clean")
        }

        function test_cancel() {
            var cancelBtn = findChildByText(dialog.contentItem, "Cancel")
            verify(cancelBtn !== null, "Cancel button should exist")

            dialog.visible = true
            mouseClick(cancelBtn)

            compare(saveSpy.count, 0)
            verify(!dialog.visible)
        }
    }
}
