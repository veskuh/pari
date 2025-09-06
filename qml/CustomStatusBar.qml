import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    id: customStatusBar

    property alias text: statusLabel.text
    property alias modelName: modelLabel.text
    property alias branchName: branchLabel.text

    Label {
        id: branchLabel
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 5
        text: qsTr("")
    }

    Label {
        id: modelLabel
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: branchLabel.right
        anchors.leftMargin: 5
        text: qsTr("")
    }

    Label {
        id: statusLabel
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 5
        text: qsTr("Ready")
    }
}
