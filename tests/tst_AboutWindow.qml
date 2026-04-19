import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml/app"

Item {
    width: 600
    height: 600

    AboutWindow {
        id: aboutWindow
    }

    TestCase {
        name: "AboutWindowTests"
        when: windowShown

        function init() {
            // Nothing to init
        }

        function test_initial_state() {
            compare(aboutWindow.title, "About Pari")
            compare(aboutWindow.width, 400)
            compare(aboutWindow.height, 320)
            compare(aboutWindow.modality, Qt.ApplicationModal)
        }
    }
}
