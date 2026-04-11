import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml"

Item {
    width: 800
    height: 600

    GitOutputWindow {
        id: gitOutputWindow
    }

    ListModel {
        id: mockLogModel
        ListElement {
            sha: "sha1"
            authorName: "Author One"
            authorEmail: "one@example.com"
            date: "2024-06-03"
            time: "10:00:00"
            messageHeader: "feat: Initial commit"
            messageBody: "This is the body."
        }
    }

    TestCase {
        name: "GitOutputWindowTests"
        when: windowShown

        function init() {
            gitOutputWindow.command = ""
            gitOutputWindow.output = ""
            gitOutputWindow.branchName = ""
            gitOutputWindow.gitLogModel = null
        }

        function test_generic_output() {
            gitOutputWindow.command = "git status"
            gitOutputWindow.output = "On branch main\nnothing to commit"
            gitOutputWindow.branchName = "main"
            
            // Wait for bindings
            wait(100)

            var outputArea = gitOutputWindow.outputArea
            verify(outputArea !== null, "outputArea not found")
            verify(outputArea.text.indexOf("On branch main") !== -1, "Output should contain 'On branch main'")
            verify(outputArea.text.indexOf("nothing to commit") !== -1, "Output should contain 'nothing to commit'")
            verify(outputArea.visible, "outputArea should be visible")
            
            var logView = gitOutputWindow.logView
            verify(logView !== null, "logView not found")
            verify(!logView.visible, "logView should be hidden")
        }

        function test_git_log_mode() {
            gitOutputWindow.command = "git log"
            gitOutputWindow.gitLogModel = mockLogModel
            
            wait(100)

            var logView = gitOutputWindow.logView
            verify(logView !== null, "logView not found")
            verify(logView.visible, "logView should be visible")
            compare(logView.count, 1)
            
            var outputArea = gitOutputWindow.outputArea
            verify(outputArea !== null, "outputArea found")
            verify(!outputArea.visible, "outputArea should be hidden")
        }
    }
}
