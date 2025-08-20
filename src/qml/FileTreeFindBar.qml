import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    height: findBarLayout.height
    color: palette.window

    property color textColor: palette.text
    property color textBackgroundColor: palette.base
    property color borderColor: palette.windowText

    SystemPalette { id: palette }

    signal findChanged(string pattern)
    signal closed()

    RowLayout {
        id: findBarLayout
        width: parent.width
        anchors.margins: 4

        Label {
            text: qsTr("Find:")
            color: root.textColor
        }

        TextField {
            id: findTextField
            Layout.fillWidth: true
            placeholderText: qsTr("Enter file pattern...")
            onTextChanged: root.findChanged(text)
            color: root.textColor
            background: Rectangle {
                color: root.textBackgroundColor
                border.color: root.borderColor
                border.width: 1
            }
        }

        Button {
            id: closeButton
            text: qsTr("Close")
            onClicked: root.closed()
        }
    }
}
