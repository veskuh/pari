import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import net.veskuh.pari 1.0
import Kaakao 1.0
import "../common"

PariPaperWell {
    id: findOverlay
    
    property bool active: false
    property int animationDuration: 200
    property real targetHeight: active ? contentColumn.implicitHeight + 16 : 0
    
    implicitHeight: targetHeight
    Layout.preferredHeight: implicitHeight
    
    visible: active || targetHeight > 0
    opacity: active ? 1.0 : 0.0
    clip: true
    
    Behavior on targetHeight {
        NumberAnimation {
            duration: findOverlay.animationDuration
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: findOverlay.animationDuration
            easing.type: Easing.InOutQuad
        }
    }
    
    backgroundColor: findOverlay.isDark ? "#1a1a1a" : "#d8d8d8"
    
    property alias searchText: searchInput.text
    property alias replaceText: replaceInput.text
    property bool matchCase: false
    property bool filterActive: false
    property bool replaceMode: false
    property bool useRegex: false
    property int currentMatchIndex: -1
    property int totalMatches: 0

    signal findNext(bool isIncremental)
    signal findPrevious()
    signal replaceNext()
    signal replaceAll()
    signal closeOverlay()
    signal closed()

    content: Column {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 8

        // --- ROW 1: SEARCH ---
        Item {
            id: searchRow
            width: parent.width
            height: 26

            PariIconButton {
                id: expandToggle
                anchors.left: parent.left
                width: 26; height: 26
                text: findOverlay.replaceMode ? "▼" : "▶"
                onClicked: findOverlay.replaceMode = !findOverlay.replaceMode
            }

            Row {
                id: searchActionGroup
                anchors.right: parent.right
                spacing: 2
                height: 26

                PariIconButton {
                    text: "⏳"; checkable: true; checked: findOverlay.filterActive
                    onCheckedChanged: findOverlay.filterActive = checked
                }
                PariIconButton {
                    text: "Aa"; checkable: true; checked: findOverlay.matchCase
                    onCheckedChanged: findOverlay.matchCase = checked
                }
                PariIconButton {
                    text: ".*"; checkable: true; checked: findOverlay.useRegex
                    onCheckedChanged: findOverlay.useRegex = checked
                }
                PariIconButton {
                    enabled: searchInput.text !== "" && !findOverlay.filterActive && findOverlay.totalMatches > 0 && (findOverlay.currentMatchIndex === -1 || findOverlay.currentMatchIndex > 0)
                    text: "▲"; onClicked: findOverlay.findPrevious()
                }
                PariIconButton {
                    enabled: searchInput.text !== "" && !findOverlay.filterActive && findOverlay.totalMatches > 0 && (findOverlay.currentMatchIndex === -1 || findOverlay.currentMatchIndex < findOverlay.totalMatches - 1)
                    text: "▼"; onClicked: findOverlay.findNext(false)
                }
                PariIconButton {
                    text: "✕"; onClicked: findOverlay.closeOverlay()
                }
            }

            KaakaoLabel {
                id: resultsLabel
                anchors.right: searchActionGroup.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: "0"
                width: 40
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                color: findOverlay.isDark ? "#aaaaaa" : "#666666"
                font.pixelSize: 11
            }

            KaakaoSearchField {
                id: searchInput
                anchors.left: parent.left
                anchors.leftMargin: 34 // Matches replaceInput alignment
                anchors.right: parent.right
                anchors.rightMargin: 226 // Matches replaceInput alignment
                height: 26
                placeholderText: filterActive ? qsTr("Filter lines...") : qsTr("Search...")
                onAccepted: findOverlay.findNext(false)
            }
        }

        // --- ROW 2: REPLACE ---
        Item {
            id: replaceRow
            visible: findOverlay.replaceMode
            width: parent.width
            height: findOverlay.replaceMode ? 26 : 0
            opacity: findOverlay.replaceMode ? 1 : 0
            clip: true

            Behavior on height { NumberAnimation { duration: 150 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            KaakaoTextField {
                id: replaceInput
                anchors.left: parent.left
                anchors.leftMargin: 34 // matches expandToggle.width (26) + leftMargin (8)
                anchors.right: parent.right
                anchors.rightMargin: 226 // matches searchActionGroup.width + resultsLabel.width + margins
                height: 26
                placeholderText: qsTr("Replace with...")
                onAccepted: findOverlay.replaceNext()
            }

            Row {
                id: replaceActionGroup
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                height: 24

                PariButton {
                    text: qsTr("Replace")
                    onClicked: findOverlay.replaceNext()
                    width: 70; height: 24
                }
                PariButton {
                    text: qsTr("Replace All")
                    onClicked: findOverlay.replaceAll()
                    width: 85; height: 24
                }
                Item { width: 26 } // Aligns with the close button in Row 1
            }
        }
    }


    function open() {
        findOverlay.active = true;
        searchInput.forceActiveFocus();
        searchInput.selectAll();
    }

    function close() {
        findOverlay.active = false;
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
