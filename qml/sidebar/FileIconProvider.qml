import QtQuick

Item {
    id: iconProvider
    property string filePath: ""
    property bool isDirectory: false
    property int size: 20

    readonly property string source: {
        if (!filePath || filePath === "")
            return "qrc:/assets/file.png";
        
        var lowerPath = filePath.toLowerCase();
        if (lowerPath.endsWith(".cpp") || lowerPath.endsWith(".h") || lowerPath.endsWith(".hpp") || lowerPath.endsWith(".cc"))
            return "qrc:/assets/cpp.png";
        if (lowerPath.endsWith(".png") || lowerPath.endsWith(".jpg") || lowerPath.endsWith(".jpeg") || lowerPath.endsWith(".gif"))
            return "qrc:/assets/png.png";
        if (lowerPath.endsWith(".qml"))
            return "qrc:/assets/qml.png";
        if (isDirectory)
            return "qrc:/assets/folder.png";
        if (lowerPath.endsWith(".md"))
            return "qrc:/assets/md.png";
        if (lowerPath.endsWith(".txt"))
            return "qrc:/assets/txt.png";
        
        return "qrc:/assets/file.png";
    }
}
