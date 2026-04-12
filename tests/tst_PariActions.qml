import QtQuick
import QtTest
import QtQuick.Controls
import "../qml"

Item {
    width: 200
    height: 200

    QtObject {
        id: mockRootWindow
        property var currentEditor: QtObject {
            property string text: "Initial Content"
            function find() {}
            function saveCursorPosition() {}
            function format() {}
        }
        property alias aiOutputPane: mockAiPane
        property alias treeColumn: mockTreeColumn
    }

    QtObject {
        id: mockAiPane
        property bool visible: false
    }

    QtObject {
        id: mockTreeColumn
        property bool visible: true
    }

    property alias fileSystem: mockFileSystem
    property alias documentManager: mockDocumentManager
    property alias appSettings: mockAppSettings
    property alias buildManager: mockBuildManager

    QtObject {
        id: mockFileSystem
        property string rootPath: "/test/path"
    }

    QtObject {
        id: mockDocumentManager
        property var documents: [
            { isDirty: false, filePath: "file1.cpp", text: "file1 text" }
        ]
        function saveFile(index, text) {}
        function closeFile(index) {}
    }

    QtObject {
        id: mockAppSettings
        property bool showHiddenFiles: false
        function getBuildCommand(path) { return "make" }
        function getRunCommand(path) { return "./app" }
        function getCleanCommand(path) { return "make clean" }
    }

    QtObject {
        id: mockBuildManager
        function executeCommand(cmd, path) {}
    }

    QtObject {
        id: mockDialogs
        property var fileDialog: QtObject { function open() {} }
        property var saveAsDialog: QtObject { function open() {} }
        property var unsavedChangesDialog: QtObject { function open() {} }
        property var buildConfigurationWindow: QtObject {
            property string buildCommand: ""
            property string runCommand: ""
            property string cleanCommand: ""
            property bool visible: false
        }
        property var goToLineDialog: QtObject {
            property int x: 0
            property int y: 0
            property int width: 100
            property int height: 50
            function open() {}
        }
    }

    PariActions {
        id: actions
        rootWindow: mockRootWindow
        dialogs: mockDialogs
        stackLayout: QtObject { property int currentIndex: 0 }
        outputPanel: QtObject { property bool visible: false }
        hasBuildConfiguration: true
    }

    TestCase {
        name: "PariActionsTests"

        function test_initial_state() {
            verify(actions.openAction !== null)
            verify(actions.saveAction !== null)
            verify(actions.buildAction !== null)
        }

        function test_toggle_ai_pane() {
            actions.showAiPaneAction.trigger()
            verify(mockAiPane.visible)
            actions.showAiPaneAction.trigger()
            verify(!mockAiPane.visible)
        }

        function test_toggle_tree_pane() {
            actions.showTreePaneAction.trigger()
            verify(!mockTreeColumn.visible)
            actions.showTreePaneAction.trigger()
            verify(mockTreeColumn.visible)
        }
    }
}
