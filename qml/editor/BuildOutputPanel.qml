import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"
import "../app"

PariPaperWell {
    id: root
    property bool expanded: false
    property alias outputArea: outputArea

    // Theme helper
    readonly property var theme: (typeof pariTheme !== 'undefined') ? pariTheme : fallbackTheme
    PariTheme {
        id: fallbackTheme
    }

    // Default visibility is false as it's toggled by actions
    visible: false

    content: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. Header Area (Unified Metallic)
        Rectangle {
            id: headerArea
            Layout.fillWidth: true
            Layout.preferredHeight: 32

            // Unified Metallic Background
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop {
                    position: 0.0
                    color: root.theme.isDark ? "#454545" : "#f0f0f0"
                }
                GradientStop {
                    position: 1.0
                    color: root.theme.isDark ? "#383838" : "#d8d8d8"
                }
            }

            // Bottom "Etched" line to separate from content
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: root.theme.isDark ? "#1a1a1a" : "#b0b0b0"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 4
                spacing: 8

                Label {
                    id: titleLabel
                    text: qsTr("BUILD OUTPUT")
                    font.pixelSize: 10
                    font.bold: true
                    color: root.theme.textColor
                    opacity: 0.8
                }

                Item {
                    Layout.fillWidth: true
                }

                PariIconButton {
                    text: root.expanded ? "-" : "+"
                    onClicked: root.expanded = !root.expanded
                }
                PariIconButton {
                    text: "✕"
                    onClicked: {
                        root.visible = false;
                        root.expanded = false;
                    }
                }
            }
        }

        // 2. Content Area
        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 6
            Flickable {
                id: flickable
                clip: true
                contentHeight: outputArea.implicitHeight
                width: parent.width

                Text {
                    id: outputArea
                    color: root.theme.textColor
                    width: parent.width
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    textFormat: Text.MarkdownText

                    onLinkActivated: function (link) {
                        var parts = link.split(":");
                        if (parts.length > 0) {
                            var filePath = parts[0];
                            var lineNumber = -1;
                            if (parts.length > 1) {
                                lineNumber = parseInt(parts[1], 10);
                            }

                            if (fileSystem.fileExistsInProject(filePath)) {
                                var absolutePath = fileSystem.getAbsolutePath(filePath);
                                if (typeof appWindow !== 'undefined') {
                                    appWindow.goToLineNumber = lineNumber;
                                }
                                documentManager.openFile(absolutePath, false);
                            }
                        }
                    }

                    onContentHeightChanged: {
                        if (outputArea.contentHeight > flickable.height) {
                            flickable.contentY = outputArea.contentHeight - flickable.height;
                        }
                    }
                }
            }
        }
    }
}
