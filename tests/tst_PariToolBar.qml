import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml"

Item {
    width: 600
    height: 200

    QtObject {
        id: mockSettings
        property bool systemThemeIsDark: false
    }

    property alias appSettings: mockSettings

    PariToolBar {
        id: toolBar
        anchors.centerIn: parent
    }

    TestCase {
        name: "PariToolBarTests"
        when: windowShown

        function init() {
            mockSettings.systemThemeIsDark = false
        }

        function test_initial_state() {
            compare(toolBar.implicitHeight, 64)
            compare(toolBar.isDark, false)
        }

        function test_theme_change() {
            mockSettings.systemThemeIsDark = true
            compare(toolBar.isDark, true)
            mockSettings.systemThemeIsDark = false
            compare(toolBar.isDark, false)
        }
    }
}
