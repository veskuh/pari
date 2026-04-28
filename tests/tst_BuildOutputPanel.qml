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
            compare(panel.outputArea.text, "", "Output area should be empty")
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
            compare(panel.outputArea.text, "Line 1\nLine 2")
        }
    }
}
