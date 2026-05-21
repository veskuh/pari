import Kaakao
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

        KaakaoLabel {
            text: qsTr("Name: %1").arg(fileName)
        }
        KaakaoLabel {
            text: qsTr("Path: %1").arg(filePath)
        }
        KaakaoLabel {
            text: qsTr("Size: %1").arg(fileSize)
        }
        KaakaoLabel {
            text: qsTr("Modified: %1").arg(fileModified)
        }
    }
}
