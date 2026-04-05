import QtQuick
import QtTest
import "../qml"

Item {
    width: 600
    height: 40

    PariTabBar {
        id: tabBar
        anchors.fill: parent
        model: [
            { fileName: "file1.cpp", isDirty: false },
            { fileName: "file2.h", isDirty: true },
            { fileName: "file3.qml", isDirty: false }
        ]
    }

    SignalSpy {
        id: clickSpy
        target: tabBar
        signalName: "tabClicked"
    }

    TestCase {
        name: "PariTabBarTests"
        when: windowShown

        function init() {
            clickSpy.clear()
            tabBar.currentIndex = 0
        }

        function test_initial_state() {
            compare(tabBar.currentIndex, 0)
        }

        function test_modify_currentIndex() {
            tabBar.currentIndex = 2
            compare(tabBar.currentIndex, 2)
        }

        function test_tabClicked() {
            // tabBar width is 600, we have 3 tabs, each tab is 200 width.
            // Click tab at index 1 (x: 300, y: 20)
            mouseClick(tabBar, 300, 20)

            compare(clickSpy.count, 1)
            compare(clickSpy.signalArguments[0][0], 1)
            compare(tabBar.currentIndex, 1)

            // Click tab at index 2 (x: 500, y: 20)
            mouseClick(tabBar, 500, 20)
            compare(clickSpy.count, 2)
            compare(clickSpy.signalArguments[1][0], 2)
            compare(tabBar.currentIndex, 2)
        }
    }
}
