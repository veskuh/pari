import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts

PariPaperWell {
    id: findOverlay
    height: 36
    width: 350
    visible: false
    
    Layout.fillHeight: false
    Layout.preferredHeight: height

    property alias searchText: searchInput.text

    signal findNext()
    signal findPrevious()
    signal closeOverlay()

    content: RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8

        TextField {
            id: searchInput
            Layout.fillWidth: true
            Layout.fillHeight: true
            placeholderText: qsTr("Search...")
            onAccepted: findOverlay.findNext()
            onTextChanged: findOverlay.findNext() // Incremental search feel
            
            color: findOverlay.isDark ? "#ffffff" : "#000000"
            selectionColor: findOverlay.isDark ? "#4a9eff" : "#0078d7"
            
            leftPadding: 30
            
            background: Rectangle {
                color: findOverlay.isDark ? "#1e1e1e" : "#fdfdfd"
                border.color: searchInput.activeFocus ? (findOverlay.isDark ? "#4a9eff" : "#0078d7") : (findOverlay.isDark ? "#333333" : "#cccccc")
                border.width: 1
                radius: 3
                
                Label {
                    text: "🔍"
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 0.5
                }
            }
        }

        Label {
            id: resultsLabel
            text: "0"
            Layout.minimumWidth: 30
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: findOverlay.isDark ? "#aaaaaa" : "#666666"
            font.pixelSize: 11
        }

        Row {
            spacing: 2
            Layout.fillHeight: true
            
            ToolButton {
                enabled: searchInput.text !== ""
                text: "▲"
                onClicked: findOverlay.findPrevious()
                width: 28
                height: parent.height
            }

            ToolButton {
                enabled: searchInput.text !== ""
                text: "▼"
                onClicked: findOverlay.findNext()
                width: 28
                height: parent.height
            }

            ToolButton {
                text: "✕"
                onClicked: findOverlay.closeOverlay()
                width: 28
                height: parent.height
            }
        }
    }

    function open() {
        findOverlay.visible = true;
        searchInput.forceActiveFocus();
        searchInput.selectAll();
    }

    function close() {
        findOverlay.visible = false;
    }

    function updateResults(total) {
        resultsLabel.text = total;
    }
}
