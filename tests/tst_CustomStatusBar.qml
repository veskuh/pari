import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml"

Item {
    width: 600
    height: 100

    QtObject {
        id: mockSettings
        property bool systemThemeIsDark: false
    }

    property alias appSettings: mockSettings

    CustomStatusBar {
        id: statusBar
        anchors.centerIn: parent
        text: "Test Status"
        modelName: "test-model"
        branchName: "main"
    }

    TestCase {
        name: "CustomStatusBarTests"
        when: windowShown

        function init() {
            mockSettings.systemThemeIsDark = false
        }

        function test_initial_state() {
            compare(statusBar.text, "Test Status")
            compare(statusBar.modelName, "test-model")
            compare(statusBar.branchName, "main")
            compare(statusBar.isDark, false)
        }

        function test_property_updates() {
            statusBar.text = "New Status"
            compare(statusBar.text, "New Status")

            statusBar.modelName = "new-model"
            compare(statusBar.modelName, "new-model")

            statusBar.branchName = "feature-branch"
            compare(statusBar.branchName, "feature-branch")
        }

        function test_theme_change() {
            mockSettings.systemThemeIsDark = true
            compare(statusBar.isDark, true)
            mockSettings.systemThemeIsDark = false
            compare(statusBar.isDark, false)
        }
    }
}
