import QtQuick

Rectangle {
    id: root

    width: 50
    height: 25

    border.color: "gray"
    border.width: 1

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }

    signal clicked
}
