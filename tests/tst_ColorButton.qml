import QtQuick
import QtTest
import "../qml"

Item {
    width: 200
    height: 200

    ColorButton {
        id: button
        anchors.centerIn: parent
        color: "red"
    }

    SignalSpy {
        id: clickSpy
        target: button
        signalName: "clicked"
    }

    TestCase {
        name: "ColorButtonTests"
        when: windowShown

        function init() {
            clickSpy.clear()
            button.color = "red"
        }

        function test_initial_state() {
            compare(button.width, 50)
            compare(button.height, 25)
            compare(button.color, "#ff0000") // "red"
        }

        function test_color_change() {
            button.color = "blue"
            compare(button.color, "#0000ff")
            button.color = "#123456"
            compare(button.color, "#123456")
        }

        function test_click() {
            mouseClick(button)
            compare(clickSpy.count, 1)
        }
    }
}
