import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml"

Item {
    width: 400
    height: 400

    QtObject {
        id: mockSettings
        property bool systemThemeIsDark: false
    }

    property alias appSettings: mockSettings

    EmptyStateCard {
        id: card
        anchors.centerIn: parent
        title: "Test Title"
        description: "Test Description"
        cardIcon: "🚀"
    }

    TestCase {
        name: "EmptyStateCardTests"
        when: windowShown

        function init() {
            mockSettings.systemThemeIsDark = false
        }

        function test_initial_state() {
            compare(card.title, "Test Title")
            compare(card.description, "Test Description")
            compare(card.cardIcon, "🚀")
            compare(card.isDark, false)
        }

        function test_theme_change() {
            mockSettings.systemThemeIsDark = true
            compare(card.isDark, true)
            mockSettings.systemThemeIsDark = false
            compare(card.isDark, false)
        }
    }
}
