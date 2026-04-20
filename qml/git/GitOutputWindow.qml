import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import net.veskuh.pari 1.0
import "../common"

Window {
    id: gitOutputWindow
    width: 800
    height: 600
    title: qsTr("Git Output")
    property string command: ""
    property string output: ""
    property string branchName: ""
    property var gitLogModel: null
    property var blameModel: (typeof gitBlameModel !== 'undefined') ? gitBlameModel : fallbackBlameModel
    GitBlameModel { id: fallbackBlameModel }

    property alias logView: logView
    property alias outputArea: outputArea
    property alias blameView: blameView

    // Theme helper
    readonly property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false

    onClosing: {
        gitLogModel = null;
    }

    Pane {
        anchors.fill: parent
        background: Rectangle { color: isDark ? "#1e1e1e" : "#f0f0f0" }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: qsTr("Command: ")
                    font.bold: true
                    color: isDark ? "#aaaaaa" : "#555555"
                }
                Label {
                    text: command
                    font.family: "Menlo"
                    color: isDark ? "#ffffff" : "#000000"
                }
                Item { Layout.fillWidth: true }
                Label {
                    text: "🌿 " + branchName
                    font.bold: true
                    visible: branchName !== ""
                    color: isDark ? "#4a9eff" : "#005a9e"
                }
            }

            PariPaperWell {
                id: well
                Layout.fillHeight: true
                
                StackLayout {
                    id: wellStack
                    anchors.fill: parent
                    anchors.margins: 5
                    currentIndex: {
                        if (gitLogModel !== null) {
                            return 0; // Log View
                        }
                        if (command.includes("git blame")) {
                            return 3; // Blame View
                        }
                        return 2; // Output Area
                    }

                    ListView {
                        id: logView
                        objectName: "logView"
                        model: gitLogModel
                        clip: true
                        spacing: 5
                        delegate: GitLogDelegate {}
                    }

                    Label {
                        id: noEntriesLabel
                        text: qsTr("No log entries found.")
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.italic: true
                        color: isDark ? "#888888" : "#666666"
                    }

                    PariReadOnlyTextArea {
                        id: outputArea
                        objectName: "outputArea"
                        text: output
                        textFormat: Text.RichText
                        wrapMode: Text.NoWrap
                        textAreaFont.family: Qt.platform.os === 'osx' ? 'Menlo' : 'Noto Sans Mono'
                    }

                    ListView {
                        id: blameView
                        objectName: "blameView"
                        model: blameModel
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        
                        delegate: Rectangle {
                            width: blameView.width
                            height: Math.max(20, codeLabel.implicitHeight)
                            color: isDark ? "#1e1e1e" : "#ffffff"

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0

                                // Commit grouping sidebar
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 4
                                    color: model.color
                                }

                                // Metadata Column
                                Item {
                                    Layout.preferredWidth: 280
                                    Layout.fillHeight: true
                                    visible: model.showMetadata

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 12
                                        spacing: 10

                                        Label {
                                            text: model.hash
                                            font.family: appSettings.fontFamily
                                            font.pointSize: appSettings.fontSize - 1
                                            color: isDark ? "#888888" : "#666666"
                                            Layout.preferredWidth: 65
                                        }

                                        Label {
                                            text: model.author
                                            font.family: appSettings.fontFamily
                                            font.pointSize: appSettings.fontSize - 1
                                            color: isDark ? "#aaaaaa" : "#444444"
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Label {
                                            text: model.date
                                            font.family: appSettings.fontFamily
                                            font.pointSize: appSettings.fontSize - 1
                                            color: isDark ? "#666666" : "#999999"
                                            Layout.preferredWidth: 80
                                        }
                                    }

                                    ToolTip {
                                        visible: mouseArea.containsMouse
                                        text: "Commit: " + model.hash + "\nAuthor: " + model.author + "\nEmail: " + model.email + "\nDate: " + model.date
                                        delay: 500
                                    }
                                    
                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                    }
                                }

                                // Empty space for lines without metadata (keeps code aligned)
                                Item {
                                    Layout.preferredWidth: 280
                                    Layout.fillHeight: true
                                    visible: !model.showMetadata
                                }

                                // Code Content
                                Label {
                                    id: codeLabel
                                    text: model.content
                                    font.family: appSettings.fontFamily
                                    font.pointSize: appSettings.fontSize
                                    color: isDark ? "#ffffff" : "#000000"
                                    Layout.fillWidth: true
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 15
                                    wrapMode: Text.NoWrap
                                }
                            }
                        }
                    }
                }
            }

            PariButton {
                objectName: "closeButton"
                text: qsTr("Close")
                onClicked: gitOutputWindow.close()
                Layout.alignment: Qt.AlignRight
                highlighted: true
            }
        }
    }
}
