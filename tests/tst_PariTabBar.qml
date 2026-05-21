import QtQuick
import QtTest
import QtQuick.Controls
import Kaakao
import QtQuick.Layouts
import "../qml/common"

Item {
    width: 600
    height: 100

    property var mockDocuments: [
        { fileName: "file1.cpp", isDirty: true },
        { fileName: "file2.h", isDirty: false },
        { fileName: "file3.qml", isDirty: false }
    ]

    PariTabBar {
        id: tabBar
        anchors.fill: parent
        model: mockDocuments
    }

    SignalSpy {
        id: clickSpy
        target: tabBar
        signalName: "tabClicked"
    }

    SignalSpy {
        id: closeSpy
        target: tabBar
        signalName: "closeTab"
    }

    TestCase {
        name: "PariTabBarTests"
        when: windowShown

        function init() {
            clickSpy.clear()
            closeSpy.clear()
            tabBar.currentIndex = 0
        }

        function test_initial_state() {
            compare(tabBar.currentIndex, 0)
        }

        function test_modify_currentIndex() {
            tabBar.currentIndex = 1
            compare(tabBar.currentIndex, 1)
        }

        function test_tabClicked() {
            // Each tab item has a MouseArea that covers most of it.
            // We find the second tab by its label text.
            var label = findChildByText(tabBar, "file2.h")
            verify(label !== null, "Label for second tab should be found")
            
            // MouseArea is a sibling of the label in our delegate
            var mouseArea = label.parent.children[label.parent.children.length - 1]
            mouseArea.clicked(null)
            
            compare(tabBar.currentIndex, 1)
            compare(clickSpy.count, 1)
        }

        function test_close_tab() {
            // Find the first tab's close button (the ✕ label)
            var closeLabel = findChildByText(tabBar, "✕")
            verify(closeLabel !== null, "Close label should be found")
            mouseClick(closeLabel)
            compare(closeSpy.count, 1)
            compare(closeSpy.signalArguments[0][0], 0)
        }

        function findChildByText(parent, text) {
            if (!parent) return null;
            if (parent.text === text) return parent;
            if (parent.children) {
                for (var i = 0; i < parent.children.length; i++) {
                    var found = findChildByText(parent.children[i], text)
                    if (found) return found
                }
            }
            return null;
        }
    }
}
