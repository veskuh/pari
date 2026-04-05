import QtQuick
import QtTest
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
            // Access text fields via id isn't possible directly from outside if they aren't property aliases,
            // but we can test the behavior by setting the properties which initialize them or using findChild if it's an object.
            // Actually, TextField `text` is bound to dialog.buildCommand initially, but setting text via QML test might be tricky without IDs exposed.
            // Let's rely on finding children.
        }

        // QML test helper to find a child by a specific type and optionally property
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
            if (parent.toString().indexOf("QQuickTextField") !== -1 || parent.toString().indexOf("TextField") !== -1) {
                results.push(parent)
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

            // BuildConfigurationDialog has 3 text fields
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
