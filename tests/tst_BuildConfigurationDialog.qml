import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml/app"
import "../qml/buildtools"

Item {
    width: 600
    height: 400

    PariTheme {
        id: pariTheme
    }

    // Mock appSettings
    QtObject {
        id: mockSettings
        property bool systemThemeIsDark: false
    }
    property alias appSettings: mockSettings

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

        function test_initial_state() {
            compare(dialog.title, "Configure Build")
        }

        function test_save() {
            dialog.show()
            verify(dialog.visible)

            var buildField = findRecursively(dialog, (item) => item.id === "buildCommandField" || item.placeholderText === "cmake --build build")
            var runField = findRecursively(dialog, (item) => item.id === "runCommandField" || item.placeholderText === "./build/app")
            var cleanField = findRecursively(dialog, (item) => item.id === "cleanCommandField" || item.placeholderText === "rm -rf build")
            
            verify(buildField !== null, "Build field should exist")
            verify(runField !== null, "Run field should exist")
            verify(cleanField !== null, "Clean field should exist")

            buildField.text = "make all"
            runField.text = "./app"
            cleanField.text = "make clean"

            var saveBtn = findRecursively(dialog, (item) => item.objectName === "saveButton" || item.text === "Save")
            verify(saveBtn !== null, "Save button should exist")

            mouseClick(saveBtn)

            compare(saveSpy.count, 1)
            var args = saveSpy.signalArguments[0]
            compare(args[0], "make all")
            compare(args[1], "./app")
            compare(args[2], "make clean")
            verify(!dialog.visible)
        }

        function test_cancel() {
            var cancelBtn = findRecursively(dialog, (item) => item.objectName === "cancelButton" || item.text === "Cancel")
            verify(cancelBtn !== null, "Cancel button should exist")

            dialog.show()
            verify(dialog.visible)
            mouseClick(cancelBtn)

            compare(saveSpy.count, 0)
            verify(!dialog.visible)
        }

        function findRecursively(parent, checkFunc) {
            if (!parent) return null;
            if (checkFunc(parent)) return parent
            
            if (parent.children) {
                for (var j = 0; j < parent.children.length; j++) {
                    var res2 = findRecursively(parent.children[j], checkFunc)
                    if (res2) return res2
                }
            }

            if (parent.contentItem && parent.contentItem !== parent) {
                var res3 = findRecursively(parent.contentItem, checkFunc)
                if (res3) return res3
            }
            
            return null
        }
    }
}
