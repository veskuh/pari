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
                    Item {
                        width: parent.width
                        height: childrenRect.height
                        property bool expanded: false

                        ColumnLayout {
                            width: parent.width

                            RowLayout {
                                Label {
                                    text: model.authorName
                                    font.bold: true
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        ToolTip.visible: hovered
                                        ToolTip.text: model.authorName + " <" + model.authorEmail + ">"
                                    }
                                }
                                Label {
                                    text: model.date
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        ToolTip.visible: hovered
                                        ToolTip.text: model.date + " " + model.time
                                    }
                                }
                            }

                            Label {
                                text: model.messageHeader
                                wrapMode: Text.WordWrap
                            }

                            ColumnLayout {
                                visible: parent.parent.expanded
                                Label {
                                    text: "SHA: " + model.sha
                                    font.family: "monospace"
                                }
                                Label {
                                    text: model.messageBody
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: parent.expanded = !parent.expanded
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
