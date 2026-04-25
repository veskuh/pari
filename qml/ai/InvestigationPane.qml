import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

Rectangle {
    id: root
    color: pariTheme.sidebarBg
    
    signal resultClicked(string filePath, int lineNumber)
    
    property bool replaceMode: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. Title Area
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Label {
                text: qsTr("GLOBAL SEARCH")
                font.pixelSize: 10
                font.bold: true
                Layout.leftMargin: 10
                Layout.topMargin: 10
                Layout.bottomMargin: 8
                color: pariTheme.textColor
                opacity: 0.6
            }
        }

        // 2. Search/Replace Interface
        PariPaperWell {
            Layout.fillWidth: true
            Layout.preferredHeight: root.replaceMode ? 180 : 145
            
            content: ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6

                // Row 1: Wide Search Input
                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: qsTr("Search for...")
                    color: pariTheme.textColor
                    onAccepted: projectSearchModel.search(fileSystem.rootPath, text, caseCheck.checked, regexCheck.checked, scopeInput.text)
                }

                // Row 2: Replace Toggle + Search Options (Checkboxes)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    ToolButton {
                        text: root.replaceMode ? "▼" : "▶"
                        onClicked: root.replaceMode = !root.replaceMode
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        font.pixelSize: 10
                    }

                    CheckBox {
                        id: regexCheck
                        text: qsTr("Regex")
                        font.pixelSize: 11
                    }

                    CheckBox {
                        id: caseCheck
                        text: qsTr("Match Case")
                        font.pixelSize: 11
                    }
                    
                    Item { Layout.fillWidth: true }
                }

                // Row 3: Replace (Collapsible)
                RowLayout {
                    visible: root.replaceMode
                    Layout.fillWidth: true
                    spacing: 8
                    
                    TextField {
                        id: replaceInput
                        Layout.fillWidth: true
                        placeholderText: qsTr("Replace with...")
                        color: pariTheme.textColor
                    }
                    
                    Button {
                        text: qsTr("Replace All")
                        enabled: projectSearchModel.resultCount > 0
                        onClicked: replaceConfirmDialog.open()
                    }
                }

                // Row 4: Scope & Search Button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: qsTr("Scope:")
                        font.pixelSize: 11
                        opacity: 0.7
                        color: pariTheme.textColor
                    }

                    TextField {
                        id: scopeInput
                        Layout.preferredWidth: 80
                        placeholderText: "*.cpp"
                        text: "*"
                        font.pixelSize: 11
                        color: pariTheme.textColor
                    }

                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: qsTr("Search")
                        highlighted: true
                        onClicked: projectSearchModel.search(fileSystem.rootPath, searchInput.text, caseCheck.checked, regexCheck.checked, scopeInput.text)
                    }
                }
                
                ProgressBar {
                    Layout.fillWidth: true
                    visible: projectSearchModel.isSearching
                    indeterminate: true
                }
            }
        }

        // 3. Results List
        ListView {
            id: resultsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: projectSearchModel
            clip: true
            
            section.property: "filePath"
            section.delegate: Rectangle {
                width: resultsList.width
                height: 24
                color: pariTheme.isDark ? "#3d3d3d" : "#e0e0e0"
                
                Label {
                    text: section.replace(fileSystem.rootPath + "/", "")
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                    font.pixelSize: 11
                    color: pariTheme.textColor
                    elide: Text.ElideLeft
                    width: parent.width - 20
                }
            }

            delegate: ItemDelegate {
                width: resultsList.width
                height: 45
                
                contentItem: ColumnLayout {
                    spacing: 2
                    Label {
                        text: "Line " + model.lineNumber
                        font.pixelSize: 10
                        color: pariTheme.accentColor
                        opacity: 0.8
                    }
                    Label {
                        text: model.lineText
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        font.family: "Menlo"
                        font.pixelSize: 11
                        color: pariTheme.textColor
                    }
                }
                
                onClicked: {
                    root.resultClicked(model.filePath, model.lineNumber);
                }
            }
            
            ScrollIndicator.vertical: ScrollIndicator { }
        }
        
        // 4. Footer Status
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            color: pariTheme.sidebarBg
            Label {
                anchors.centerIn: parent
                text: projectSearchModel.isSearching ? qsTr("Searching...") : qsTr("%1 matches found").arg(projectSearchModel.resultCount)
                font.pixelSize: 10
                opacity: 0.7
                color: pariTheme.textColor
            }
        }
    }

    Dialog {
        id: replaceConfirmDialog
        title: qsTr("Confirm Replace All")
        standardButtons: Dialog.Yes | Dialog.No
        
        anchors.centerIn: Overlay.overlay
        modal: true
        
        Label {
            text: qsTr("Are you sure you want to replace all %1 occurrences in the project?").arg(projectSearchModel.resultCount)
            color: pariTheme.textColor
        }
        
        onAccepted: projectSearchModel.replaceAll(replaceInput.text)
    }
}
