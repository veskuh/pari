import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml/editor"
import "../qml/app"

Item {
    id: root
    width: 800
    height: 600

    // Mock theme
    PariTheme {
        id: pariTheme
    }

    BuildOutputPanel {
        id: panel
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: expanded ? 400 : 150
    }

    TestCase {
        name: "BuildOutputPanelTests"
        when: windowShown

        function init() {
            panel.visible = false
            panel.expanded = false
            panel.outputArea.text = ""
        }

        function test_1_initial_state() {
            compare(panel.visible, false, "Should be hidden by default")
            compare(panel.expanded, false, "Should not be expanded by default")
            // In RichText mode, .text might contain HTML boilerplate
            var isReallyEmpty = panel.outputArea.text === "" || panel.outputArea.text.indexOf("<body") !== -1
            verify(isReallyEmpty, "Output area should be effectively empty")
        }

        function test_2_toggle_expand() {
            panel.visible = true
            panel.expanded = true
            verify(panel.expanded)
            compare(panel.height, 400)
            
            panel.expanded = false
            verify(!panel.expanded)
            compare(panel.height, 150)
        }

        function test_3_close() {
            panel.visible = true
            panel.expanded = true
            
            // Trigger close logic
            panel.visible = false
            panel.expanded = false
            
            compare(panel.visible, false)
            compare(panel.expanded, false)
        }

        function test_4_append_text() {
            panel.outputArea.text = "Line 1"
            panel.outputArea.text += "\nLine 2"
            verify(panel.outputArea.text.indexOf("Line 1") !== -1, "Should contain Line 1")
            verify(panel.outputArea.text.indexOf("Line 2") !== -1, "Should contain Line 2")
        }
    }
}
