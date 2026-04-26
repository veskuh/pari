import QtQuick
import QtCore
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
    
    signal resultClicked(string filePath, int lineNumber)

    property string command: ""
    property string output: ""
    property string branchName: ""
    
    // To allow UI tests to inject mock models, we use a writeable property.
    // In the live app, it defaults to our self-contained internal model.
    property var gitLogModel: internalLogModel
    property var blameModel: (typeof gitBlameModel !== 'undefined') ? gitBlameModel : internalBlameModel
    
    // Self-contained models for multi-window support
    GitLogModel { id: internalLogModel }
    GitBlameModel { id: internalBlameModel }
    GitDiffModel { id: internalDiffModel }

    property alias logView: logView
    property alias outputArea: outputArea
    property alias blameView: blameView

    // Theme helper
    readonly property bool isDark: (typeof appSettings !== 'undefined') ? appSettings.systemThemeIsDark : false

    Settings {
        id: gitWindowSettings
        category: "gitWindow"
        property alias x: gitOutputWindow.x
        property alias y: gitOutputWindow.y
        property alias width: gitOutputWindow.width
        property alias height: gitOutputWindow.height
    }

    // Helper function to populate diff
    function setDiff(rawDiff) {
        internalDiffModel.parseRawDiff(rawDiff);
    }

    Connections {
        target: (typeof toolManager !== 'undefined') ? toolManager : null
        
        function onGitDiffReady(diff) {
            // Only update if this specific window's command matches a diff or show operation.
            if (command.includes("git diff") || command.includes("git show")) {
                 if (typeof internalDiffModel !== 'undefined' && internalDiffModel !== null) {
                    internalDiffModel.parseRawDiff(diff);
                 }
            }
        }
        
        function onGitLogReady(log) {
            // Only update if this window is currently displaying the log
            if (command.includes("git log")) {
                internalLogModel.parseAndSetLog(log);
            }
        }

        function onCommitDetailsReady(sha, details) {
            // Forward dossier data to our internal log model
            internalLogModel.updateDetails(sha, details);
        }
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
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Item { Layout.preferredWidth: 20 }
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
                        if (command.includes("git diff") || command.includes("git show")) {
                            return 4; // High-Fidelity Diff View
                        }
                        if (gitLogModel !== null && command.includes("git log")) {
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

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 4
                                    color: model.color
                                }

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

                                Item {
                                    Layout.preferredWidth: 280
                                    Layout.fillHeight: true
                                    visible: !model.showMetadata
                                }

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

                    // Slot 4: High-Fidelity Diff View
                    GitDiffView {
                        id: diffView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        _model: internalDiffModel
                        onResultClicked: (path, line) => gitOutputWindow.resultClicked(path, line)
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
