import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml/common"

Item {
    width: 200
    height: 200

    // Mock appSettings which is used by PariToolButton
    QtObject {
        id: mockSettings
        property bool systemThemeIsDark: false
    }

    // PariToolButton expects 'appSettings' to be in scope
    property alias appSettings: mockSettings

    PariToolButton {
        id: button
        anchors.centerIn: parent
        text: "Test"
        iconSource: "qrc:/assets/build.png"
    }

    SignalSpy {
        id: clickSpy
        target: button
        signalName: "clicked"
    }

    TestCase {
        name: "PariToolButtonTests"
        when: windowShown

        function init() {
            clickSpy.clear()
            button.checkable = false
            button.checked = false
            mockSettings.systemThemeIsDark = false
        }

        function test_initial_state() {
            compare(button.text, "Test")
            compare(button.isPrimary, false)
            compare(button.checked, false)
            compare(button.enabled, true)
        }

        function test_click() {
            mouseClick(button)
            compare(clickSpy.count, 1)
        }

        function test_checkable() {
            button.checkable = true
            mouseClick(button)
            compare(button.checked, true)
            mouseClick(button)
            compare(button.checked, false)
        }

        function test_theme_change() {
            mockSettings.systemThemeIsDark = true
            compare(button.isDark, true)
            mockSettings.systemThemeIsDark = false
            compare(button.isDark, false)
        }
    }
}
