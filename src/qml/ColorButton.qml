import QtQuick

Rectangle {
    id: root

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }

    signal clicked

}
