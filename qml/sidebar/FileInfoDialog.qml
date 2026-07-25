import QtQuick
import QtQuick.Controls
import Kaakao 1.0

KaakaoDialog {
    id: fileInfoDialog
    title: qsTr("File Info")

    property string fileName: ""
    property string filePath: ""
    property string fileSize: ""
    property string fileModified: ""

    width: 400
    height: 180

    contentItem: Column {
        spacing: 10
        padding: 16

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
