import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: fileInfoDialog
    title: qsTr("File Info")

    property string fileName: ""
    property string filePath: ""
    property string fileSize: ""
    property string fileModified: ""

    width: 400
    height: 180

    Column {
        anchors{
            fill: parent
            margins: 10
        }

        spacing: 10

        Label {
            text: qsTr("Name: %1").arg(fileName)
        }
        Label {
            text: qsTr("Path: %1").arg(filePath)
        }
        Label {
            text: qsTr("Size: %1").arg(fileSize)
        }
        Label {
            text: qsTr("Modified: %1").arg(fileModified)
        }
    }
}
