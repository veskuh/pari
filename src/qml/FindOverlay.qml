import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: findOverlay
    height: 40
    color: "black"
    property color borderColor: "#a0a0a0"
    property color textColor: "#000000"
    property color textBackgroundColor: "#ffffff"

    border.width: 1
    radius: 5
    visible: false

    property alias searchText: searchInput.text

    signal findNext()
    signal findPrevious()
    signal closeOverlay()



    RowLayout {
        anchors.fill: parent
        anchors.margins: 5

        TextField {
            id: searchInput
            Layout.fillWidth: true
            placeholderText: "Search..."
            onAccepted: findOverlay.findNext()
            color: findOverlay.textColor
            background: Rectangle {
                color: findOverlay.textBackgroundColor
            }
        }

        Label {
            id: resultsLabel
            text: "0"
            Layout.minimumWidth: 50
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: findOverlay.textColor
        }

        Button {
            enabled: searchInput.text!==""
            text: "▲"
            onClicked: findOverlay.findPrevious()
        }

        Button {
            enabled: searchInput.text!==""
            text: "▼"
            onClicked: findOverlay.findNext()
        }

        Button {
            text: "✕"
            onClicked: findOverlay.closeOverlay()
        }
    }

    function open() {
        findOverlay.visible = true;
        searchInput.forceActiveFocus();
    }

    function close() {
        findOverlay.visible = false;
    }

    function updateResults(total) {
        resultsLabel.text = total;
    }
}
