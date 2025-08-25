import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: gitOutputWindow
    width: 800
    height: 600
    title: "Git Output"
    property string command: ""
    property string output: ""
    property string branchName: ""
    property var gitLogModel: null

    Pane {
        anchors.fill: parent
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            Label {
                text: "Branch: " + branchName
                font.bold: true
                visible: gitLogModel === null
            }

            Label {
                text: "Command: " + command
                font.bold: true
            }

            ListView {
                id: logView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: gitLogModel
                visible: gitLogModel !== null

                delegate: Component {
                    // Use Item as the root for better layout control.
                    // We use anchors.margins on the background Rectangle to create space between delegates.
                    Item {
                        id: delegateRoot
                        width: logView.width
                        height: column.height + 40
                        // This property controls the expanded state.
                        property bool expanded: false

                        // The background Rectangle provides the visual container.
                        Rectangle {
                            id: background
                            // Use anchors and margins for proper spacing and padding.
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            anchors.bottomMargin: 10
                            anchors.topMargin: 10
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
                                width: parent.width - 20
                                x: 10
                                y: 10
                                anchors.margins: 15 // Internal padding for all content
                                spacing: 10 // Space between vertical elements

                                // Header section with author, date, and expand indicator
                                RowLayout {
                                    width: parent.width
                                    anchors.margins: 15 // Internal padding for all content

                                    height: childrenRect.height

                                    // Author Name
                                    Label {
                                        text: model.authorName
                                        font.bold: true
                                        font.pixelSize: 16
                                        color: "#2c3e50" // A dark, modern blue-gray
                                        ToolTip.visible: authorMouseArea.containsMouse
                                        ToolTip.text: model.authorName + " <" + model.authorEmail + ">"

                                        MouseArea {
                                            id: authorMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                        }
                                    }

                                    // Spacer to push the date to the right
                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    // Date
                                    Label {
                                        text: model.date
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

                                    // Expand/Collapse Indicator
                                    Label {
                                        text: "▶" // A simple arrow character
                                        font.pixelSize: 12
                                        color: "#7f8c8d"
                                        Layout.leftMargin: 10
                                        // Rotate the arrow when expanded
                                        transform: Rotation {
                                            origin.x: 5
                                            origin.y: 7
                                            angle: delegateRoot.expanded ? 90 : 0
                                            Behavior on angle {
                                                PropertyAnimation {
                                                    duration: 200
                                                }
                                            }
                                        }
                                    }
                                }

                                // Commit Message Header
                                Label {
                                    id: commit
                                    text: model.messageHeader
                                    width: parent.width
                                    wrapMode: Text.WordWrap
                                    font.pixelSize: 15
                                    color: "#34495e" // Slightly softer than the author name
                                }

                                // --- Key Improvement: Animated Expandable Section ---
                                ColumnLayout {
                                    id: detailsLayout
                                    visible: delegateRoot.expanded
                                    Layout.topMargin: 10
                                    Layout.fillWidth: true
                                    spacing: 8

                                    // Use opacity and height for a smooth animation
                                    opacity: 0
                                    height: 0
                                    Behavior on opacity {
                                        PropertyAnimation {
                                            duration: 200
                                        }
                                    }
                                    Behavior on height {
                                        PropertyAnimation {
                                            duration: 200
                                        }
                                    }

                                    // Update state when visibility changes
                                    states: [
                                        State {
                                            name: "expanded"
                                            when: delegateRoot.expanded
                                            PropertyChanges {
                                                target: detailsLayout
                                                height: detailsLayout.implicitHeight
                                                opacity: 1
                                            }
                                        }
                                    ]

                                    // Divider line for visual separation
                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: "#e0e0e0"
                                        Layout.bottomMargin: 5
                                    }

                                    // Full Commit Message Body
                                    Label {
                                        text: model.messageBody
                                        width: parent.width
                                        wrapMode: Text.WordWrap
                                        color: "#34495e"
                                    }

                                    // Commit SHA
                                    Label {
                                        text: "SHA: " + model.sha
                                        font.family: "monospace"
                                        color: "#95a5a6"
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
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: gitLogModel === null

                TextArea {
                    id: outputArea
                    readOnly: true
                    text: output
                    wrapMode: Text.NoWrap
                    font.family: "monospace"
                }
            }

            Button {
                text: "Close"
                onClicked: gitOutputWindow.close()
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
