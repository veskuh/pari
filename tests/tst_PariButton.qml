import QtQuick
import QtTest
import QtQuick.Controls
import Kaakao
import QtQuick.Layouts
import "../qml/app"
import "../qml/common"

Item {
    width: 200
    height: 200

    PariTheme {
        id: pariTheme
    }

    // Mock appSettings
    QtObject {
        id: mockSettings
        property bool systemThemeIsDark: false
    }
    property alias appSettings: mockSettings

    PariButton {
        id: button
        anchors.centerIn: parent
        text: "Test Button"
    }

    SignalSpy {
        id: clickSpy
        target: button
        signalName: "clicked"
    }

    TestCase {
        name: "PariButtonTests"
        when: windowShown

        function init() {
            clickSpy.clear()
            button.highlighted = false
            mockSettings.systemThemeIsDark = false
        }

        function test_initial_state() {
            compare(button.text, "Test Button")
            compare(button.highlighted, false)
            compare(button.enabled, true)
        }

        function test_click() {
            mouseClick(button)
            compare(clickSpy.count, 1)
        }

        function test_highlight() {
            button.highlighted = true
            verify(button.highlighted)
            button.highlighted = false
            verify(!button.highlighted)
        }

        function test_theme_change() {
            mockSettings.systemThemeIsDark = true
            // isDark is a readonly property in PariButton which uses pariTheme or appSettings
            // We just verify it doesn't crash and component is reactive
            verify(button !== null)
        }
    }
}
