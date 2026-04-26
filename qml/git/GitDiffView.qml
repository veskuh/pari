import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

Item {
    id: root
    
    readonly property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false
    readonly property var _model: (typeof gitDiffModel !== 'undefined') ? gitDiffModel : null

    ListView {
        id: diffList
        anchors.fill: parent
        model: _model
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        
        delegate: Rectangle {
            width: diffList.width
            // 0: Context, 1: Addition, 2: Deletion, 3: FileHeader, 4: HunkHeader, 5: UntrackedFile
            height: {
                if (type === 3) return 40; // Substantial FileHeader
                if (type === 4) return 22; // HunkHeader
                if (type === 5) return 28; // Untracked File row
                return Math.max(20, contentLabel.implicitHeight); // Code lines
            }
            
            color: {
                if (type === 1) return isDark ? "#1a331a" : "#e6ffe6"; // Addition
                if (type === 2) return isDark ? "#331a1a" : "#ffe6e6"; // Deletion
                if (type === 4) return isDark ? "#1a2533" : "#eef4ff"; // HunkHeader
                if (type === 5) return isDark ? "#1e2e1e" : "#f5fff5"; // Untracked
                return "transparent";
            }

            // --- 1. FILE HEADER STYLE ---
            gradient: (type === 3) ? fileHeaderGradient : null
            border.color: (type === 3) ? (isDark ? "#000000" : "#aab2b9") : "transparent"
            border.width: (type === 3) ? 1 : 0

            Gradient {
                id: fileHeaderGradient
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: isDark ? "#2a2e33" : "#d0d7de" }
                GradientStop { position: 0.5; color: isDark ? "#383d44" : "#e1e8ef" }
                GradientStop { position: 1.0; color: isDark ? "#2a2e33" : "#d0d7de" }
            }

            // --- 2. LAYOUT ENGINE ---
            RowLayout {
                anchors.fill: parent
                spacing: 0

                // TACTILE GUTTER
                Rectangle {
                    visible: type !== 3 && type !== 5
                    Layout.fillHeight: true
                    Layout.preferredWidth: 80
                    color: {
                        if (type === 4) return isDark ? "#1a2533" : "#eef4ff"; 
                        return isDark ? "#252525" : "#f5f5f5";
                    }
                    
                    Rectangle {
                        anchors.right: parent.right
                        width: 1
                        height: parent.height
                        color: isDark ? "#111111" : "#dddddd"
                        visible: type !== 4
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        anchors.rightMargin: 8
                        spacing: 8
                        visible: type !== 4

                        Label {
                            Layout.preferredWidth: 25
                            text: (typeof oldLine === 'number' && oldLine > 0) ? oldLine : ""
                            font.family: "Menlo"
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignRight
                            color: isDark ? "#666666" : "#999999"
                        }
                        Label {
                            Layout.preferredWidth: 25
                            text: (typeof newLine === 'number' && newLine > 0) ? newLine : ""
                            font.family: "Menlo"
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignRight
                            color: isDark ? "#666666" : "#999999"
                        }
                        Label {
                            Layout.fillWidth: true
                            text: {
                                if (type === 1) return "+";
                                if (type === 2) return "-";
                                return " ";
                            }
                            font.bold: true
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            color: {
                                if (type === 1) return "#228b22";
                                if (type === 2) return "#cc0000";
                                return "#aaaaaa";
                            }
                        }
                    }
                }

                // CONTENT AREA
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: {
                        if (type === 3) return 12;
                        if (type === 5) return 12;
                        if (type === 4) return 50;
                        return 10;
                    }
                    spacing: 8

                    Label {
                        text: type === 3 ? "🛠️" : (type === 5 ? "➕📄" : "")
                        visible: type === 3 || type === 5
                        font.pixelSize: 14
                    }
                    
                    Rectangle {
                        visible: type === 5
                        width: 34
                        height: 16
                        radius: 3
                        color: isDark ? "#228b22" : "#e6ffe6"
                        border.color: isDark ? "#1a331a" : "#228b22"
                        Label {
                            anchors.centerIn: parent
                            text: "NEW"
                            font.bold: true
                            font.pixelSize: 8
                            color: isDark ? "#ffffff" : "#228b22"
                        }
                    }

                    Label {
                        id: contentLabel
                        Layout.fillWidth: true
                        text: {
                            if (type === 3 || type === 5) return content;
                            if (type === 1 || type === 2 || (type === 0 && content.startsWith(" "))) {
                                 return content.substring(1); 
                            }
                            return content;
                        }
                        font.family: "Menlo"
                        font.pixelSize: (type === 3 || type === 5) ? 12 : (type === 4 ? 10 : 12)
                        font.bold: type === 3
                        color: {
                            if (type === 4) return isDark ? "#4a9eff" : "#005a9e";
                            if (type === 3) return isDark ? "#ffffff" : "#000000";
                            if (type === 5) return isDark ? "#d0d0d0" : "#228b22";
                            return isDark ? "#d0d0d0" : "#1a1c1c";
                        }
                        opacity: type === 4 ? 0.8 : 1.0
                        wrapMode: Text.NoWrap
                        verticalAlignment: Text.AlignVCenter
                        elide: (type === 3 || type === 5) ? Text.ElideLeft : Text.ElideNone
                    }
                }
            }
            
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: isDark ? "#ffffff" : "#ffffff"
                opacity: 0.05
                visible: type === 3
            }
        }
        
        ScrollIndicator.vertical: ScrollIndicator { }
        ScrollIndicator.horizontal: ScrollIndicator { }
    }
}
