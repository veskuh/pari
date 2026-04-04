import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    implicitHeight: 28
    implicitWidth: fileSystemView.width
    height: 28
    required property int depth
    required property bool expanded
    property var appWindow
    property bool isDirectory: fileSystem.isDirectory(model.filePath)
    property bool highlight: model.filePath === fileSystemView.selectedPath
    
    // Check dirty state from documentManager
    property bool isDirty: documentManager.isDirty(model.filePath)
    
    Connections {
        target: documentManager
        function onDirtyStatusChanged() {
            root.isDirty = documentManager.isDirty(model.filePath);
        }
    }
    
    // Helper for theme
    readonly property bool isDark: appSettings.systemThemeIsDark

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

    // --- Indicator (Folder Arrow) ---
    Label {
        id: indicator
        text: isDirectory ? (expanded ? "▼" : "▶") : ""
        x: (root.depth * 16) + 4
        font.pixelSize: 10
        color: root.highlight ? "#ffffff" : (root.isDark ? "#888888" : "#666666")
        anchors.verticalCenter: parent.verticalCenter
        opacity: isDirectory ? 1.0 : 0
    }

    // --- LED Indicator ---
    Rectangle {
        id: stateLed
        width: 6
        height: 6
        radius: 3
        x: indicator.x + 12
        anchors.verticalCenter: parent.verticalCenter
        visible: root.isDirty // Add Git status logic here later
        
        color: root.isDirty ? "#ffaa00" : "transparent"
        
        // Glow effect
        layer.enabled: root.isDirty
        /*
        layer.effect: DropShadow {
            transparentBorder: true
            color: stateLed.color
            radius: 4
            samples: 8
        }*/
    }

    // --- Icon ---
    Image {
        id: fileIcon
        source: {
            if (!model || !model.filePath || model.filePath === null)
                "qrc:/assets/file.png";
            else if (model.filePath.endsWith(".cpp") || model.filePath.endsWith(".h"))
                "qrc:/assets/cpp.png";
            else if (model.filePath.endsWith(".png"))
                "qrc:/assets/png.png";
            else if (model.filePath.endsWith(".qml"))
                "qrc:/assets/qml.png";
            else if (isDirectory)
                "qrc:/assets/folder.png";
            else if (model.filePath.endsWith(".md"))
                "qrc:/assets/md.png";
            else if (model.filePath.endsWith(".txt"))
                "qrc:/assets/txt.png";
            else
                "qrc:/assets/file.png";
        }
        sourceSize.height: 20
        sourceSize.width: 20
        x: indicator.x + 20
        anchors.verticalCenter: parent.verticalCenter
        opacity: root.enabled ? 1.0 : 0.5
    }

    // --- Label ---
    Label {
        text: model.display ? model.display : ""
        x: fileIcon.x + 24
        width: parent.width - x - 10
        clip: true
        elide: Text.ElideRight
        font.pixelSize: 12
        font.bold: root.highlight
        color: root.highlight ? "#ffffff" : (root.isDark ? "#d0d0d0" : "#333333")
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                if (isDirectory) {
                    fileSystemView.toggleExpanded(index);
                } else {
                    documentManager.openFile(model.filePath, false);
                    fileSystemView.selectedPath = model.filePath;
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
            text: qsTr("Open in new tab")
            enabled: !isDirectory
            onTriggered: {
                documentManager.openFile(model.filePath, true);
            }
        }
        MenuItem {
            text: qsTr("Info")
            onTriggered: {
                var fileInfo = fileSystem.getFileInfo(model.filePath);
                var component = Qt.createComponent("FileInfoDialog.qml");
                var dialog = component.createObject(root, {
                    fileName: fileInfo.name,
                    filePath: fileInfo.path,
                    fileSize: fileInfo.size,
                    fileModified: fileInfo.modified
                });
                dialog.show();
            }
        }
        MenuItem {
            text: qsTr("Rename")
            onTriggered: {
                var component = Qt.createComponent("RenameDialog.qml");
                if (component.status === Component.Ready) {
                    var dialog = component.createObject(root, { oldPath: model.filePath });
                    if (dialog) {
                        dialog.onClosed.connect(function() {
                            dialog.destroy();
                        });
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
