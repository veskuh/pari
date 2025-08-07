import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: customStatusBar
   
    property alias text: statusLabel.text

    Label {
        id: statusLabel
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 5
        text: qsTr("Ready")
    }
}
