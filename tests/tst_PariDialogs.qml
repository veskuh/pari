import QtQuick
import QtTest
import QtQuick.Controls
import "../qml"

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

            var discardCalled = false
            dialogs.discardChanges.connect(function() { discardCalled = true })
            // MessageDialog result is handled in onAccepted
            // We can't easily trigger the MessageDialog buttons in a headless test without mocking MessageDialog itself,
            // but we can check if the signals are connected.
        }
    }
}
