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
            
            var outputArea = findChild(gitOutputWindow, "outputArea")
            verify(outputArea !== null, "outputArea not found")
            compare(outputArea.text, "On branch main\nnothing to commit")
            verify(outputArea.visible, "outputArea should be visible")
            
            var logView = findChild(gitOutputWindow, "logView")
            verify(logView !== null, "logView not found")
            verify(!logView.visible, "logView should be hidden")
        }

        function test_git_log_mode() {
            gitOutputWindow.command = "git log"
            gitOutputWindow.gitLogModel = mockLogModel
            
            var logView = findChild(gitOutputWindow, "logView")
            verify(logView !== null, "logView not found")
            verify(logView.visible, "logView should be visible")
            compare(logView.count, 1)
            
            var outputArea = findChild(gitOutputWindow, "outputArea")
            verify(!outputArea.visible, "outputArea should be hidden")
        }

        function findChild(parent, objectName) {
            for (var i = 0; i < parent.contentItem.children.length; i++) {
                var child = parent.contentItem.children[i];
                if (child.objectName === objectName) return child;
                var found = findChildRecursive(child, objectName);
                if (found) return found;
            }
            return null;
        }

        function findChildRecursive(parent, objectName) {
            if (parent.objectName === objectName) return parent;
            if (parent.children) {
                for (var i = 0; i < parent.children.length; i++) {
                    var found = findChildRecursive(parent.children[i], objectName);
                    if (found) return found;
                }
            }
            return null;
        }
    }
}
