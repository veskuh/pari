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
    PariTheme { id: fallbackTheme }
    
    // Default visibility is false as it's toggled by actions
    visible: false
    
    content: ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5

        RowLayout {
            Label {
                text: qsTr("Build Output")
                font.bold: true
                color: root.theme.textColor
            }
            Item {
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                PariIconButton {
                    text: root.expanded ? "➖" : "➕"
                    onClicked: {
                        root.expanded = !root.expanded;
                    }
                }
                PariIconButton {
                    text: "✖️"
                    onClicked: {
                        root.visible = false;
                        root.expanded = false;
                    }
                }
            }
        }

        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
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
