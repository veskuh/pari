import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Use Item as the root for better layout control.
// We use anchors.margins on the background Rectangle to create space between delegates.
Item {
    id: delegateRoot
    width: ListView.view.width
    height: background.height + 20
    // This property controls the expanded state.
    property bool expanded: false

    // The background Rectangle provides the visual container.
    Rectangle {
        id: background
        // Use anchors and margins for proper spacing and padding.
        width: parent.width - 20
        height: column.implicitHeight + 20
        anchors.centerIn: parent

        // The radius for rounded corners.
        radius: 8

        // --- Key Improvement: Alternating Row Colors ---
        // The color changes based on the item's index in the model.
        color: index % 2 === 0 ? "#ffffff" : "#f7f9fa"
        border.color: "#e0e0e0" // Subtle border for better separation
        border.width: 1

        // The main layout for all content, with internal padding.
        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10 // Space between vertical elements

            // Header section with author, date, and expand indicator
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Expand/Collapse Indicator
                Label {
                    id: arrow
                    text: "▶" // A simple arrow character
                    font.pixelSize: 12
                    color: "#7f8c8d"
                    // Rotate the arrow when expanded
                    transform: Rotation {
                        origin.x: arrow.width / 2
                        origin.y: arrow.height / 2
                        angle: delegateRoot.expanded ? 90 : 0
                        Behavior on angle {
                            PropertyAnimation {
                                duration: 200
                            }
                        }
                    }
                }

                // Date
                Label {
                    id: dateLabel
                    text: "📅 " + model.date
                    font.pixelSize: 13
                    color: "#7f8c8d" // A muted gray for secondary info
                    ToolTip.visible: dateMouseArea.containsMouse
                    ToolTip.text: model.date + " " + model.time

                    MouseArea {
                        id: dateMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }

                // Header
                Label {
                    id: headline
                    text: model.messageHeader
                    font.bold: true
                    font.pixelSize: 16
                    color: "#2c3e50" // A dark, modern blue-gray
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            // Commit Message Header
            Label {
                id: authorLabel
                text: "👤 " + model.authorName
                font.pixelSize: 13
                color: "#7f8c8d" // A muted gray for secondary info
                wrapMode: Text.WordWrap
                ToolTip.visible: authorMouseArea.containsMouse
                ToolTip.text: model.authorName + " <" + model.authorEmail + ">"
                Layout.leftMargin: 25

                MouseArea {
                    id: authorMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }

            // --- Key Improvement: Animated Expandable Section ---
            ColumnLayout {
                id: detailsLayout
                visible: delegateRoot.expanded
                Layout.fillWidth: true
                Layout.leftMargin: 25
                spacing: 8

                // Divider line for visual separation
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#e0e0e0"
                }

                // Full Commit Message Body
                Label {
                    id: messageBody
                    text: model.messageBody
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    textFormat: Text.PlainText
                    color: "#34495e"
                    visible: text !== ""
                }

                // Divider line for visual separation
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#e0e0e0"
                    visible: messageBody.visible
                }

                // Commit SHA
                Label {
                    text: "🔗 SHA: " + model.sha
                    font.family: "monospace"
                    color: "#95a5a6"
                    font.pixelSize: 11
                }
            }
        }
    }

    // --- Key Improvement: Clickable Area ---
    // A full-sized MouseArea to toggle the expanded state.
    MouseArea {
        anchors.fill: parent
        onClicked: delegateRoot.expanded = !delegateRoot.expanded
    }
}
