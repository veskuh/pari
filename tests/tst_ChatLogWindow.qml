import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml"

Item {
    width: 800
    height: 600

    PariTheme {
        id: pariTheme
    }

    // Mock LLM object
    QtObject {
        id: mockLlm
        property var chatLog: ["USER: Hello", "AI: Hi there!"]
    }

    ChatLogWindow {
        id: chatLogWindow
        chatLlm: mockLlm
    }

    TestCase {
        name: "ChatLogWindowTests"
        when: windowShown

        function init() {
            chatLogWindow.chatLlm = mockLlm
            mockLlm.chatLog = ["USER: Hello", "AI: Hi there!"]
        }

        function test_initial_content() {
            var listView = findChild(chatLogWindow, "chatLogView")
            verify(listView !== null, "ListView not found")
            compare(listView.count, 2)
        }

        function test_update_content() {
            var listView = findChild(chatLogWindow, "chatLogView")
            mockLlm.chatLog = ["USER: Hello", "AI: Hi there!", "USER: How are you?"]
            compare(listView.count, 3)
        }

        function test_empty_content() {
            chatLogWindow.chatLlm = null
            var listView = findChild(chatLogWindow, "chatLogView")
            compare(listView.count, 0)
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
