import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../common"

PariPaperWell {
    id: findOverlay
    height: replaceMode ? 76 : 40
    width: 480
    visible: false
    
    Layout.fillHeight: false
    Layout.preferredHeight: height

    property alias searchText: searchInput.text
    property alias replaceText: replaceInput.text
    property bool matchCase: false
    property bool filterActive: false
    property bool replaceMode: false

    signal findNext(bool isIncremental)
    signal findPrevious()
    signal replaceNext()
    signal replaceAll()
    signal closeOverlay()
    signal closed()

    // Animation for height change
    Behavior on height {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    content: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        // Top Row: Search
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8

            ToolButton {
                id: expandToggle
                text: findOverlay.replaceMode ? "▼" : "▶"
                ToolTip.visible: hovered
                ToolTip.text: findOverlay.replaceMode ? qsTr("Hide Replace") : qsTr("Show Replace")
                onClicked: findOverlay.replaceMode = !findOverlay.replaceMode
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
            }

            TextField {
                id: searchInput
                Layout.fillWidth: true
                Layout.minimumWidth: 150
                Layout.preferredHeight: 26
                placeholderText: filterActive ? qsTr("Filter lines...") : qsTr("Search...")
                onAccepted: findOverlay.findNext(false)
                
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
                Layout.minimumWidth: 60
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: findOverlay.isDark ? "#aaaaaa" : "#666666"
                font.pixelSize: 11
            }

            RowLayout {
                spacing: 2
                Layout.preferredHeight: 28

                ToolButton {
                    id: filterToggle
                    text: "⏳"
                    checkable: true
                    checked: findOverlay.filterActive
                    onCheckedChanged: findOverlay.filterActive = checked
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Filter lines (Grep mode)")
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 26
                    
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
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 26
                    
                    background: Rectangle {
                        color: caseToggle.checked ? (findOverlay.isDark ? "#00458d" : "#e0eeff") : "transparent"
                        radius: 2
                    }
                }
                
                ToolButton {
                    enabled: searchInput.text !== "" && !findOverlay.filterActive
                    text: "▲"
                    onClicked: findOverlay.findPrevious()
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 26
                }

                ToolButton {
                    enabled: searchInput.text !== "" && !findOverlay.filterActive
                    text: "▼"
                    onClicked: findOverlay.findNext(false)
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 26
                }

                ToolButton {
                    text: "✕"
                    onClicked: findOverlay.closeOverlay()
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 26
                }
            }
        }

        // Bottom Row: Replace
        RowLayout {
            visible: findOverlay.replaceMode
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            spacing: 8
            
            // Spacer to align with search input (matching expandToggle width + spacing)
            Item { Layout.preferredWidth: 24 }

            TextField {
                id: replaceInput
                Layout.fillWidth: true
                Layout.minimumWidth: 150
                Layout.preferredHeight: 26
                placeholderText: qsTr("Replace with...")
                onAccepted: findOverlay.replaceNext()
                
                color: findOverlay.isDark ? "#ffffff" : "#000000"
                selectionColor: findOverlay.isDark ? "#4a9eff" : "#0078d7"
                
                background: Rectangle {
                    color: findOverlay.isDark ? "#1e1e1e" : "#fdfdfd"
                    border.color: replaceInput.activeFocus ? (findOverlay.isDark ? "#4a9eff" : "#0078d7") : (findOverlay.isDark ? "#333333" : "#cccccc")
                    border.width: 1
                    radius: 3
                }
            }

            RowLayout {
                spacing: 4
                Layout.preferredHeight: 28

                Button {
                    text: qsTr("Replace")
                    enabled: searchInput.text !== "" && !findOverlay.filterActive
                    onClicked: findOverlay.replaceNext()
                    implicitHeight: 24
                    Layout.preferredHeight: 24
                    Layout.alignment: Qt.AlignVCenter
                }

                Button {
                    text: qsTr("All")
                    enabled: searchInput.text !== "" && !findOverlay.filterActive
                    onClicked: findOverlay.replaceAll()
                    implicitHeight: 24
                    Layout.preferredHeight: 24
                    Layout.alignment: Qt.AlignVCenter
                }
                
                // Align with the "✕" button above
                Item { Layout.preferredWidth: 28 }
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
