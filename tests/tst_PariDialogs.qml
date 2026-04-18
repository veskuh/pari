import QtQuick
import QtTest
import QtQuick.Controls
import "../qml/app"

Item {
    width: 200
    height: 200

    PariDialogs {
        id: dialogs
    }

    TestCase {
        name: "PariDialogsTests"

        function test_initial_state() {
            verify(dialogs.settingsDialog !== null)
            verify(dialogs.aboutWindow !== null)
            verify(dialogs.chatLogWindow !== null)
            verify(dialogs.buildConfigurationWindow !== null)
            verify(dialogs.goToLineDialog !== null)
            verify(dialogs.gitOutputWindow !== null)
            verify(dialogs.unsavedChangesDialog !== null)
            verify(dialogs.fileDialog !== null)
            verify(dialogs.saveAsDialog !== null)
        }

        function test_signals() {
            var saveConfigCalled = false
            dialogs.saveConfiguration.connect(function() { saveConfigCalled = true })
            dialogs.buildConfigurationWindow.saveConfiguration("make", "run", "clean")
            verify(saveConfigCalled)

            var goToLineCalled = false
            dialogs.goToLine.connect(function() { goToLineCalled = true })
            dialogs.goToLineDialog.goToLine(10)
            verify(goToLineCalled)

            var savedIndex = -1
            dialogs.saveAndClose.connect(function(index) { savedIndex = index })
            dialogs.targetIndex = 5
            dialogs.unsavedChangesDialog.accepted()
            compare(savedIndex, 5)

            var discardedIndex = -1
            dialogs.discardChanges.connect(function(index) { discardedIndex = index })
            dialogs.targetIndex = 3
            dialogs.unsavedChangesDialog.discardClicked()
            compare(discardedIndex, 3)
        }
    }
}
