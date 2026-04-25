import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../common"

PariPaperWell {
    id: findOverlay
    height: 36
    width: 400
    visible: false
    
    Layout.fillHeight: false
    Layout.preferredHeight: height

    property alias searchText: searchInput.text
    property bool matchCase: false
    property bool filterActive: false

    signal findNext(bool isIncremental)
    signal findPrevious()
    signal closeOverlay()
    signal closed()

    content: RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8

        TextField {
            id: searchInput
            Layout.fillWidth: true
            Layout.fillHeight: true
            placeholderText: filterActive ? qsTr("Filter lines...") : qsTr("Search...")
            onAccepted: findOverlay.findNext(false)
            // Removed onTextChanged to prevent duplicate signals with SearchManager Connections
            
            color: findOverlay.isDark ? "#ffffff" : "#000000"
            selectionColor: findOverlay.isDark ? "#4a9eff" : "#0078d7"
            
            leftPadding: 30
            
            background: Rectangle {
                color: findOverlay.isDark ? "#1e1e1e" : "#fdfdfd"
                border.color: searchInput.activeFocus ? (findOverlay.isDark ? "#4a9eff" : "#0078d7") : (findOverlay.isDark ? "#333333" : "#cccccc")
                border.width: 1
                radius: 3
                
                Label {
                    text: filterActive ? "⏳" : "🔍"
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
            Layout.minimumWidth: 50
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: findOverlay.isDark ? "#aaaaaa" : "#666666"
            font.pixelSize: 11
        }

        Row {
            spacing: 2
            Layout.fillHeight: true

            ToolButton {
                id: filterToggle
                text: "⏳"
                checkable: true
                checked: findOverlay.filterActive
                onCheckedChanged: findOverlay.filterActive = checked
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Filter lines (Grep mode)")
                width: 28
                height: parent.height
                
                background: Rectangle {
                    color: filterToggle.checked ? (findOverlay.isDark ? "#00458d" : "#e0eeff") : "transparent"
                    radius: 2
                }
            }

            ToolButton {
                id: caseToggle
                text: "Aa"
                checkable: true
                checked: findOverlay.matchCase
                onCheckedChanged: findOverlay.matchCase = checked
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Match Case")
                width: 28
                height: parent.height
                
                background: Rectangle {
                    color: caseToggle.checked ? (findOverlay.isDark ? "#00458d" : "#e0eeff") : "transparent"
                    radius: 2
                }
            }
            
            ToolButton {
                enabled: searchInput.text !== "" && !findOverlay.filterActive
                text: "▲"
                onClicked: findOverlay.findPrevious()
                width: 28
                height: parent.height
            }

            ToolButton {
                enabled: searchInput.text !== "" && !findOverlay.filterActive
                text: "▼"
                onClicked: findOverlay.findNext(false)
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
        closed();
    }

    function updateResults(total) {
        if (findOverlay.filterActive) {
            resultsLabel.text = qsTr("%1 lines").arg(total);
        } else {
            resultsLabel.text = total;
        }
    }
}
