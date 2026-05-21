import Kaakao
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

Rectangle {
    id: root
    
    property bool replaceMode: false

    signal resultClicked(string filePath, int lineNumber)
    
    color: pariTheme.sidebarBg

    Connections {
        target: fileSystem
        function onRootPathChanged() {
            projectSearchModel.clear();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. Title Area
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            
            KaakaoLabel {
                text: qsTr("GLOBAL SEARCH")
                color: pariTheme.textColor
                font.pixelSize: 10
                font.bold: true
                opacity: 0.6
                Layout.leftMargin: 10
                Layout.topMargin: 10
                Layout.bottomMargin: 8
            }
        }

        // 2. Search/Replace Interface
        PariPaperWell {
            id: searchWell
            backgroundColor: pariTheme.isDark ? "#1a1a1a" : "#d8d8d8"
            Layout.fillWidth: true
            Layout.preferredHeight: root.replaceMode ? 180 : 145
            
            content: ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6

                // Row 1: Wide Search Input
                TextField {
                    id: searchInput
                    color: pariTheme.textColor
                    Layout.fillWidth: true
                    placeholderText: qsTr("Search for...")
                    onAccepted: projectSearchModel.search(fileSystem.rootPath, text, caseCheck.checked, regexCheck.checked, scopeInput.text)
                    onTextChanged: {
                        if (projectSearchModel.resultCount > 0 || projectSearchModel.isSearching) {
                            projectSearchModel.cancel();
                            projectSearchModel.clear();
                        }
                    }
                }

                // Row 2: Replace Toggle + Search Options (Checkboxes)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    PariIconButton {
                        text: root.replaceMode ? "▼" : "▶"
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        onClicked: root.replaceMode = !root.replaceMode
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
                    Layout.fillWidth: true
                    spacing: 8
                    visible: root.replaceMode
                    
                    TextField {
                        id: replaceInput
                        color: pariTheme.textColor
                        Layout.fillWidth: true
                        placeholderText: qsTr("Replace with...")
                    }
                    
                    PariButton {
                        text: qsTr("Replace All")
                        enabled: projectSearchModel.resultCount > 0
                        onClicked: replaceConfirmDialog.open()
                    }
                }

                // Row 4: Scope & Search KaakaoButton
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    KaakaoLabel {
                        text: qsTr("Scope:")
                        color: pariTheme.textColor
                        font.pixelSize: 11
                        opacity: 0.7
                    }

                    TextField {
                        id: scopeInput
                        color: pariTheme.textColor
                        text: "*"
                        placeholderText: "*.cpp"
                        font.pixelSize: 11
                        Layout.preferredWidth: 80
                    }

                    Item { Layout.fillWidth: true }
                    
                    PariButton {
                        text: projectSearchModel.isSearching ? qsTr("Cancel") : qsTr("Search")
                        highlighted: !projectSearchModel.isSearching
                        onClicked: {
                            if (projectSearchModel.isSearching) {
                                projectSearchModel.cancel();
                            } else {
                                projectSearchModel.search(fileSystem.rootPath, searchInput.text, caseCheck.checked, regexCheck.checked, scopeInput.text);
                            }
                        }
                    }
                }
                
                ProgressBar {
                    visible: projectSearchModel.isSearching
                    Layout.fillWidth: true
                    indeterminate: true
                }
            }
        }

        // 3. Results List
        ListView {
            id: resultsList
            model: projectSearchModel
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            section.property: "filePath"
            section.delegate: Rectangle {
                width: resultsList.width
                height: 24
                color: pariTheme.isDark ? "#3d3d3d" : "#e0e0e0"
                
                KaakaoLabel {
                    text: (typeof section !== "undefined" ? section : "").replace(fileSystem.rootPath + "/", "")
                    color: pariTheme.textColor
                    font.bold: true
                    font.pixelSize: 11
                    elide: Text.ElideLeft
                    width: parent.width - 20
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                }
            }

            delegate: ItemDelegate {
                id: delegate
                width: resultsList.width
                height: 45
                
                contentItem: ColumnLayout {
                    spacing: 2
                    
                    KaakaoLabel {
                        text: model.lineNumber === 0 ? qsTr("Filename match") : qsTr("Line %1").arg(model.lineNumber)
                        color: pariTheme.accentColor
                        font.pixelSize: 10
                        opacity: 0.8
                    }
                    
                    KaakaoLabel {
                        text: model.lineText
                        color: pariTheme.textColor
                        font.family: "Menlo"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
                
                onClicked: {
                    root.resultClicked(model.filePath, model.lineNumber);
                }
            }
            
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOn }
        }
        
        // 4. Footer Status
        Rectangle {
            color: pariTheme.sidebarBg
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            
            KaakaoLabel {
                text: {
                    if (projectSearchModel.isSearching) {
                        return qsTr("Searching...");
                    }
                    return qsTr("%1 matches found").arg(projectSearchModel.resultCount);
                }
                color: pariTheme.textColor
                font.pixelSize: 10
                opacity: 0.7
                anchors.centerIn: parent
            }
        }
    }

    Dialog {
        id: replaceConfirmDialog
        title: qsTr("Confirm Replace All")
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: Overlay.overlay
        modal: true
        implicitWidth: 350
        
        KaakaoLabel {
            anchors.left: parent.left
            anchors.right: parent.right
            text: qsTr("Are you sure you want to replace all %1 occurrences in the project?").arg(projectSearchModel.resultCount)
            color: pariTheme.textColor
            wrapMode: Text.WordWrap
        }
        
        onAccepted: projectSearchModel.replaceAll(replaceInput.text)
    }
}
