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

    SystemPalette {
        id: palette
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        radius: 5
        visible: highlight || mouseArea.containsMouse
        opacity: highlight ? 1.0 : 0.15
        color: highlight ? palette.highlight : palette.shadow
    }

    Label {
        id: indicator
        text: (isDirectory ? "▶" : " ")
        x: (root.depth * 10) + 10
        rotation: expanded ? 90 : 0
        anchors.verticalCenter: parent.verticalCenter
    }

    Image {
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
        x: indicator.x + 14
        anchors.verticalCenter: parent.verticalCenter
    }

    Label {
        text: model.display ? model.display : ""
        x: indicator.x + 38
        width: parent.width - x - 10
        clip: true
        elide: Text.ElideRight
        font.bold: highlight
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
    }
}

