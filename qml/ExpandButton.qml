import QtQuick
import QtQuick.Controls

ToolButton {
    id: expandButton
    property bool expanded: false
    text: expanded ? "[-]" : "[+]"
}
