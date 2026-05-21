import Kaakao
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

/**
 * A reusable row for the SettingsWindow that displays a label
 * and two ColorButtons (for Dark and Light themes).
 */
RowLayout {
    id: root
    spacing: 10

    property string labelText: ""
    property color darkColor: "black"
    property color lightColor: "white"
    
    // The dialog to open when a button is clicked
    property var colorDialog

    // Signals to notify the parent when a color is changed
    // Note: Renamed to avoid collision with automatically generated darkColorChanged property signal
    signal darkColorSelected(color newColor)
    signal lightColorSelected(color newColor)

    KaakaoLabel {
        text: root.labelText
        Layout.preferredWidth: 120
    }

    ColorButton {
        color: root.darkColor
        onClicked: {
            root.colorDialog.openForColor(this, root.darkColor);
        }
        function updateColor() {
            root.darkColorSelected(root.colorDialog.selectedColor);
        }
    }

    ColorButton {
        color: root.lightColor
        onClicked: {
            root.colorDialog.openForColor(this, root.lightColor);
        }
        function updateColor() {
            root.lightColorSelected(root.colorDialog.selectedColor);
        }
    }
}
