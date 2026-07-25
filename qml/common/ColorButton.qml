import QtQuick
import Kaakao 1.0

KaakaoButton {
    id: root

    property alias color: swatch.color

    implicitWidth: 50
    implicitHeight: 25

    padding: 3

    contentItem: Rectangle {
        id: swatch
        implicitWidth: 44
        implicitHeight: 19
        radius: Theme.radiusSmall
        border.color: Theme.buttonBorder
        border.width: 1
    }
}
