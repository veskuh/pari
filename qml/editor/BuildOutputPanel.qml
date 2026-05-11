import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"
import "../app"

PariPaperWell {
    id: root
    property bool expanded: false
    property alias outputArea: outputArea

    // Default visibility is false as it's toggled by actions
    visible: false

    // Theme helper
    readonly property var theme: (typeof pariTheme !== 'undefined') ? pariTheme : fallbackTheme
    PariTheme {
        id: fallbackTheme
    }

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
                spacing: 8
                anchors {
                    fill: parent
                    leftMargin: 8
                    rightMargin: 4
                }

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
            clip: true

            TextArea {
                id: outputArea
                readOnly: true
                selectByMouse: true
                hoverEnabled: true
                color: root.theme.textColor
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText
                background: null

                // In PlainText mode, links are not natively clickable.
                // We'll need to handle clicks manually or keep Markdown for links.
                // Re-evaluating: To keep links clickable AND newlines working, 
                // we should stick to Markdown but fix the formatting.
                // The test failure suggests that Markdown adds extra padding/newlines.
                onLinkActivated: (link) => {
                    const parts = link.split(":");
                    if (parts.length > 0) {
                        const filePath = parts[0];
                        let lineNumber = -1;
                        if (parts.length > 1) {
                            lineNumber = parseInt(parts[1], 10);
                        }

                        if (fileSystem.fileExistsInProject(filePath)) {
                            const absolutePath = fileSystem.getAbsolutePath(filePath);
                            if (typeof appWindow !== 'undefined' && appWindow) {
                                appWindow.goToLineNumber = lineNumber;
                            }
                            if (typeof documentManager !== 'undefined' && documentManager) {
                                documentManager.openFile(absolutePath, false);
                            }
                        }
                    }
                }

                onTextChanged: {
                    // Auto-scroll to bottom using Qt.callLater to ensure layout is updated
                    Qt.callLater(() => {
                        scrollView.ScrollBar.vertical.position = 1.0 - scrollView.ScrollBar.vertical.size;
                    });
                }
            }
        }
    }
}
