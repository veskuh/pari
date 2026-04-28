import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml/sidebar"

Item {
    id: root
    width: 300
    height: 100

    property QtObject appSettings: QtObject {
        property bool systemThemeIsDark: false
    }

    property QtObject fileSystem: QtObject {
        function isDirectory(path) {
            if (!path) return false;
            return path.endsWith("/") || path.indexOf(".") === -1
        }
        function getFileInfo(path) {
            return { name: "test", path: path, size: "1 KB", modified: "now" }
        }
    }

    property QtObject documentManager: QtObject {
        signal dirtyStatusChanged()
        function isDirty(path) {
            return path === "dirty.cpp"
        }
        function openFile(path, newTab) {
            openedFile = path
            openedInNewTab = newTab
        }
        property string openedFile: ""
        property bool openedInNewTab: false
    }

    Item {
        id: fileSystemView
        property string selectedPath: "selected.cpp"
        function toggleExpanded(index) {}
    }

    // Wrap in a component that provides required properties
    Item {
        id: delegateContainer
        anchors.fill: parent
        property string testFilePath: "test.cpp"
        property string testDisplay: "test.cpp"

        FileTreeDelegate {
            id: delegate
            anchors.fill: parent
            filePath: delegateContainer.testFilePath
            fileName: "test.cpp"
            display: delegateContainer.testDisplay
            depth: 1
            expanded: false
        }
    }

    TestCase {
        name: "FileTreeDelegateTests"
        when: windowShown

        function init() {
            delegateContainer.testFilePath = "test.cpp"
            delegateContainer.testDisplay = "test.cpp"
            delegate.depth = 1
            delegate.expanded = false
            fileSystemView.selectedPath = "selected.cpp"
            documentManager.openedFile = ""
        }

        function test_initial_state() {
            compare(delegate.isDirectory, false)
            verify(!delegate.highlight, "Highlight should be false")
            compare(delegate.isDirty, false)
        }

        function test_highlight() {
            delegateContainer.testFilePath = "selected.cpp"
            verify(delegate.highlight, "Highlight should be true")
        }

        function test_dirty_state() {
            delegateContainer.testFilePath = "dirty.cpp"
            documentManager.dirtyStatusChanged()
            compare(delegate.isDirty, true)
        }

        function test_directory_detection() {
            delegateContainer.testFilePath = "src/"
            compare(delegate.isDirectory, true)
        }

        function test_icon_selection() {
            var icon = findChild(delegate, "fileIcon")
            verify(icon !== null)
            
            // CPP file
            delegateContainer.testFilePath = "test.cpp"
            verify(icon.source.toString().indexOf("cpp.png") !== -1, "Expected cpp.png, got " + icon.source)
            
            // QML file
            delegateContainer.testFilePath = "test.qml"
            verify(icon.source.toString().indexOf("qml.png") !== -1, "Expected qml.png, got " + icon.source)
            
            // Folder
            delegateContainer.testFilePath = "folder"
            compare(delegate.isDirectory, true)
            verify(icon.source.toString().indexOf("folder.png") !== -1, "Expected folder.png, got " + icon.source)
        }

        function findChild(parent, objectName) {
            if (parent.objectName === objectName) return parent;
            
            if (parent.children) {
                for (var i = 0; i < parent.children.length; i++) {
                    var found = findChild(parent.children[i], objectName);
                    if (found) return found;
                }
            }
            
            if (parent.contentItem) {
                var foundInContent = findChild(parent.contentItem, objectName);
                if (foundInContent) return foundInContent;
            }
            
            return null;
        }
    }
}
