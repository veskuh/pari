import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    implicitHeight: 28
    implicitWidth: typeof fileSystemView !== 'undefined' ? fileSystemView.width : 200
    height: 28
    
    // Roles from QFileSystemModel/TreeView
    required property string filePath
    required property string fileName
    required property var display
    
    required property int depth
    required property bool expanded
    
    property var mainWindow
    property bool isDirectory: fileSystem.isDirectory(root.filePath)
    property bool highlight: (typeof fileSystemView !== 'undefined') ? (root.filePath === fileSystemView.selectedPath) : false
    
    // Check dirty state from documentManager
    property bool isDirty: false
    
    function updateDirtyState() {
        if (root.filePath) {
            isDirty = documentManager.isDirty(root.filePath);
        } else {
            isDirty = false;
        }
    }
    
    onFilePathChanged: updateDirtyState()
    Component.onCompleted: updateDirtyState()
    
    Connections {
        target: documentManager
        function onDirtyStatusChanged() {
            root.updateDirtyState();
        }
    }
    
    // Helper for theme
    readonly property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false

    // --- Background (Selection/Hover) ---
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        radius: 4
        visible: root.highlight || mouseArea.containsMouse
        
        gradient: Gradient {
            GradientStop { 
                position: 0.0
                color: root.highlight ? "#0069d3" : (root.isDark ? "#ffffff" : "#000000")
            }
            GradientStop { 
                position: 1.0
                color: root.highlight ? "#0051a6" : (root.isDark ? "#eeeeee" : "#333333")
            }
        }
        
        opacity: root.highlight ? 1.0 : (root.isDark ? 0.05 : 0.08)
        
        // Light-catching edge for selection
        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: "#ffffff"
            opacity: 0.3
            visible: root.highlight
            radius: 4
        }
    }

    // --- Progressive Depth (Etched line) ---
    Rectangle {
        id: depthLine
        visible: root.depth > 0
        x: (root.depth * 16) - 8
        width: 1
        height: parent.height
        color: root.isDark ? "#404040" : "#d0d0d0"
        opacity: 0.5
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: (root.depth * 16) + 4
        spacing: 4

        // --- Indicator (Folder Arrow) ---
        Label {
            id: indicator
            text: isDirectory ? (expanded ? "▼" : "▶") : ""
            font.pixelSize: 10
            color: root.highlight ? "#ffffff" : (root.isDark ? "#888888" : "#666666")
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 12
            horizontalAlignment: Text.AlignHCenter
        }

        // --- Status LED (Dirty Indicator) ---
        Rectangle {
            id: statusLed
            width: 6
            height: 6
            radius: 3
            visible: root.isDirty
            color: root.isDirty ? "#ffaa00" : "transparent"
            Layout.alignment: Qt.AlignVCenter
        }

        // --- Icon ---
        FileIconProvider {
            id: iconProvider
            filePath: root.filePath
            isDirectory: root.isDirectory
        }

        Image {
            id: fileIcon
            objectName: "fileIcon"
            source: iconProvider.source
            sourceSize.height: 20
            sourceSize.width: 20
            Layout.alignment: Qt.AlignVCenter
            opacity: root.enabled ? 1.0 : 0.5
        }

        // --- Label ---
        Label {
            text: root.display ? root.display : ""
            Layout.fillWidth: true
            clip: true
            elide: Text.ElideRight
            font.pixelSize: 12
            font.bold: root.highlight
            color: root.highlight ? "#ffffff" : (root.isDark ? "#d0d0d0" : "#333333")
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                if (isDirectory) {
                    if (typeof fileSystemView !== 'undefined') fileSystemView.toggleExpanded(index);
                } else {
                    documentManager.openFile(root.filePath, false);
                    if (typeof fileSystemView !== 'undefined') fileSystemView.selectedPath = root.filePath;
                }
            }
        }

        onPressed: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                contextMenu.popup();
            }
        }
    }

    Menu {
        id: contextMenu

        MenuItem {
            text: qsTr("New File...")
            enabled: isDirectory
            onTriggered: {
                var dialog = dialogs.newFileDialog;
                dialog.folderPath = root.filePath;
                // Dialog (Popup) coordinates are relative to parent (window content area)
                dialog.x = (mainWindow.width - dialog.width) / 2;
                dialog.y = (mainWindow.height - dialog.height) / 2;
                dialog.open();
            }
        }
        MenuItem {
            text: qsTr("Open in new tab")
            enabled: !isDirectory
            onTriggered: {
                documentManager.openFile(root.filePath, true);
                if (typeof fileSystemView !== 'undefined') fileSystemView.selectedPath = root.filePath;
            }
        }
        MenuItem {
            text: qsTr("Info")
            onTriggered: {
                var fileInfo = fileSystem.getFileInfo(root.filePath);
                var component = Qt.createComponent("FileInfoDialog.qml");
                var dialog = component.createObject(root, {
                    fileName: fileInfo.name,
                    filePath: fileInfo.path,
                    fileSize: fileInfo.size,
                    fileModified: fileInfo.modified
                });
                if (dialog) {
                    // ApplicationWindow coordinates are screen-relative
                    dialog.x = mainWindow.x + (mainWindow.width - dialog.width) / 2;
                    dialog.y = mainWindow.y + (mainWindow.height - dialog.height) / 2;
                    dialog.show();
                }
            }
        }
        MenuItem {
            text: qsTr("Rename")
            onTriggered: {
                var component = Qt.createComponent("RenameDialog.qml");
                if (component.status === Component.Ready) {
                    var dialog = component.createObject(mainWindow.contentItem, { oldPath: root.filePath });
                    if (dialog) {
                        dialog.onClosed.connect(function() {
                            dialog.destroy();
                        });
                        // Dialog (Popup) coordinates are relative to parent (window content area)
                        dialog.x = (mainWindow.width - dialog.width) / 2;
                        dialog.y = (mainWindow.height - dialog.height) / 2;
                        dialog.open();
                    } else {
                        console.error("Failed to create Rename dialog object");
                    }
                } else {
                    console.error("RenameDialog component is not ready. Status:", component.status, "Error:", component.errorString());
                }
            }
        }
    }
}
