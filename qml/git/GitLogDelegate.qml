import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../common"

Item {
    id: delegateRoot
    width: ListView.view ? ListView.view.width : 500
    height: cardContainer.height + 12
    
    property bool expanded: false
    readonly property bool isDark: (typeof pariTheme !== 'undefined') ? pariTheme.isDark : false

    // SAFETY PROPERTIES
    readonly property string _sha: (model && model.sha) ? model.sha : ""
    readonly property string _details: (model && model.details) ? model.details : ""
    readonly property bool _detailsLoading: (model && model.detailsLoading) ? model.detailsLoading : false

    // JIT Loading Logic
    onExpandedChanged: {
        if (expanded && _details === "" && _sha !== "") {
            gitLogModel.setDetailsLoading(_sha, true);
            toolManager.runCommand("git show --stat " + _sha, fileSystem.rootPath);
        }
    }

    // --- 1. THE MECHANICAL RAIL ---
    Rectangle {
        id: rail
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: (typeof pariTheme !== 'undefined') ? pariTheme.sidebarBorder : "#333"
        opacity: 0.5
        z: 1
    }

    // --- 2. THE RAIL BOLT ---
    Rectangle {
        id: bolt
        anchors.horizontalCenter: rail.horizontalCenter
        y: 20
        width: 8
        height: 8
        radius: 4
        z: 2
        color: delegateRoot.expanded ? ((typeof pariTheme !== 'undefined') ? pariTheme.accentColor : "#0078d7") : (isDark ? "#444" : "#cbd1d6")
        border.color: isDark ? "#111" : "#999"
        border.width: 1

        Rectangle {
            anchors.centerIn: parent
            width: 16
            height: 16
            radius: 8
            color: (typeof pariTheme !== 'undefined') ? pariTheme.accentColor : "#0078d7"
            opacity: mouseArea.containsMouse ? 0.2 : 0
            visible: !delegateRoot.expanded
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }

    // --- 3. THE INDEX CARD ---
    Rectangle {
        id: cardContainer
        anchors.left: rail.right
        anchors.right: parent.right
        anchors.leftMargin: 20
        anchors.rightMargin: 15
        anchors.verticalCenter: parent.verticalCenter
        
        height: contentColumn.implicitHeight + 24
        radius: 4
        color: isDark ? "#252525" : "#ffffff"
        border.color: delegateRoot.expanded ? ((typeof pariTheme !== 'undefined') ? pariTheme.accentColor : "#0078d7") : ((typeof pariTheme !== 'undefined') ? pariTheme.sidebarBorder : "#ccc")
        border.width: 1

        layer.enabled: delegateRoot.expanded || mouseArea.containsMouse
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "black"
            shadowOpacity: isDark ? 0.4 : 0.1
            shadowBlur: 0.2
            shadowVerticalOffset: delegateRoot.expanded ? 4 : 2
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            // INTERACTIVE HEADER AREA
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: headerLayout.implicitHeight + 24
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: delegateRoot.expanded = !delegateRoot.expanded
                }

                ColumnLayout {
                    id: headerLayout
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // TOP ROW: SHA Plate + Date
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Rectangle {
                            id: shaPlate
                            Layout.preferredWidth: 70
                            Layout.preferredHeight: 18
                            radius: 3
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: isDark ? "#2a2a2a" : "#e0e4e9" }
                                GradientStop { position: 1.0; color: isDark ? "#323232" : "#edf1f5" }
                            }
                            border.color: isDark ? "#111" : "#b0b7be"
                            
                            Label {
                                anchors.centerIn: parent
                                text: _sha.substring(0, 7)
                                font.family: "Menlo"
                                font.pixelSize: 10
                                font.bold: true
                                color: isDark ? "#aaa" : "#555"
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (typeof clipboard !== 'undefined') {
                                        clipboard.setText(_sha);
                                        copyTooltip.show("Copied!");
                                    }
                                }
                                ToolTip {
                                    id: copyTooltip
                                    text: qsTr("Click to copy SHA")
                                    visible: parent.containsMouse
                                    delay: 500
                                    
                                    function show(msg) {
                                        var oldText = text;
                                        text = msg;
                                        visible = true;
                                        timer.start();
                                    }

                                    Timer {
                                        id: timer
                                        interval: 1000
                                        onTriggered: {
                                            copyTooltip.visible = false;
                                            copyTooltip.text = qsTr("Click to copy SHA");
                                        }
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Label {
                            text: (model && model.date) ? (model.date + " " + model.time) : ""
                            font.family: "Menlo"
                            font.pixelSize: 10
                            color: ((typeof pariTheme !== 'undefined') ? pariTheme.textColor : "#000")
                            opacity: 0.5
                        }
                    }

                    // HEADLINE ROW
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: delegateRoot.expanded ? "▼" : "▶"
                            font.pixelSize: 8
                            color: ((typeof pariTheme !== 'undefined') ? pariTheme.accentColor : "#0078d7")
                            opacity: 0.8
                        }

                        Label {
                            Layout.fillWidth: true
                            text: (model && model.messageHeader) ? model.messageHeader : ""
                            font.bold: true
                            font.pixelSize: 13
                            color: (typeof pariTheme !== 'undefined') ? pariTheme.textColor : "#000"
                            elide: Text.ElideRight
                        }
                    }

                    // AUTHOR AREA
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        spacing: 6
                        opacity: 0.7

                        Label { text: "👤"; font.pixelSize: 10 }
                        Label {
                            text: (model && model.authorName) ? model.authorName : ""
                            font.pixelSize: 11
                            color: ((typeof pariTheme !== 'undefined') ? pariTheme.textColor : "#000")
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // --- REFACTORING DOSSIER (Expanded) ---
            ColumnLayout {
                id: bodyLayout
                Layout.fillWidth: true
                Layout.leftMargin: 28
                Layout.rightMargin: 12
                Layout.bottomMargin: 12
                visible: delegateRoot.expanded
                spacing: 12
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: ((typeof pariTheme !== 'undefined') ? pariTheme.sidebarBorder : "#ccc")
                    opacity: 0.5
                }

                Label {
                    Layout.fillWidth: true
                    text: (model && model.messageBody) ? model.messageBody : ""
                    font.pixelSize: 12
                    color: ((typeof pariTheme !== 'undefined') ? pariTheme.textColor : "#000")
                    opacity: 0.9
                    wrapMode: Text.WordWrap
                    visible: text !== ""
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    // Loading State
                    RowLayout {
                        visible: _detailsLoading
                        spacing: 8
                        Label { text: "⚙️"; font.pixelSize: 12 }
                        Label { 
                            text: qsTr("Fetching Refactoring Dossier...")
                            font.pixelSize: 11; font.italic: true; opacity: 0.6
                            color: ((typeof pariTheme !== 'undefined') ? pariTheme.textColor : "#000")
                        }
                    }

                    // Stats & Files
                    ColumnLayout {
                        visible: !_detailsLoading && _details !== ""
                        Layout.fillWidth: true
                        spacing: 10

                        Label {
                            text: "📑 <a href='diff_full:all'>View Full Diff</a>"
                            textFormat: Text.RichText
                            font.pixelSize: 11
                            font.bold: true
                            color: (typeof pariTheme !== 'undefined') ? pariTheme.accentColor : "#0078d7"
                            onLinkActivated: (link) => {
                                var cmd = "git show " + _sha;
                                appWindow.showGitOutput(cmd, "", "");
                            }
                        }

                        Label {
                            id: statsText
                            Layout.fillWidth: true
                            textFormat: Text.RichText
                            font.family: "Menlo"
                            font.pixelSize: 11
                            color: (typeof pariTheme !== 'undefined') ? pariTheme.textColor : "#000"
                            text: {
                                if (_details === "") return "";
                                var lines = _details.split('\n');
                                var formatted = "";
                                for (var i=0; i < lines.length; i++) {
                                    var line = lines[i].trim();
                                    if (line.includes('|')) {
                                        var parts = line.split('|');
                                        var filePath = parts[0].trim();
                                        formatted += "📄 <a href='diff:" + filePath + "'>" + filePath + "</a>" + parts[1] + "<br/>";
                                    } else if (line.includes('changed')) {
                                        formatted += "<br/><b>" + line + "</b>";
                                    }
                                }
                                return formatted;
                            }
                            
                            onLinkActivated: (link) => {
                                if (link.startsWith("diff:")) {
                                    var file = link.substring(5);
                                    var cmd = "git show " + _sha + " -- " + file;
                                    appWindow.showGitOutput(cmd, "", "");
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    scale: mouseArea.pressed ? 0.98 : 1.0
    Behavior on scale { NumberAnimation { duration: 100 } }
}
