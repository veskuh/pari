import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Control {
    id: customStatusBar
    Layout.fillWidth: true
    height: 25
    background: Rectangle {
            color: "#000000"

    }

    property alias text: statusLabel.text

    Label {
        id: statusLabel
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 5
        text: qsTr("Ready")
        color: "#f0f0f0"

    }
}
