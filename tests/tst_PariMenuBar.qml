import QtQuick
import QtTest
import QtQuick.Controls
import "../qml/app"

Item {
    width: 800
    height: 600

    QtObject {
        id: mockActions
        property bool hasBuildConfiguration: true
        property var newAction: Action { text: "New" }
        property var openAction: Action { text: "Open" }
        property var saveAction: Action { text: "Save" }
        property var saveAsAction: Action { text: "Save As..." }
        property var closeAction: Action { text: "Close" }
        property var findAction: Action { text: "Find" }
        property var indentAction: Action { text: "Indent" }
        property var goToAction: Action { text: "Go to line..." }
        property var buildAction: Action { text: "Build" }
        property var runAction: Action { text: "Run" }
        property var configureBuildAction: Action { text: "Build setup..." }
        property var showAiPaneAction: Action { text: "Show AI"; checkable: true; checked: true }
        property var showTreePaneAction: Action { text: "Show Files"; checkable: true; checked: true }
        property var toggleHiddenFilesAction: Action { text: "Show Hidden"; checkable: true; checked: false }
        
        property var outputArea: QtObject { property string text: "" }
        property var outputPanel: QtObject { property bool visible: false }
    }

    // These mock objects must match the IDs used in the component (which are global context properties)
    property alias appSettings: mockAppSettings
    property alias fileSystem: mockFileSystem
    property alias toolManager: mockToolManager
    property alias buildManager: mockBuildManager

    QtObject {
        id: mockAppSettings
        property var recentFolders: ["/home/user/project1", "/home/user/project2"]
        function getCleanCommand(path) { return "make clean" }
        function clearRecentFolders() {}
    }

    QtObject {
        id: mockFileSystem
        property bool isGitRepository: true
        property string rootPath: "/home/user/project"
        property string currentFilePath: "main.cpp"
        function setRootPath(path) {}
    }

    QtObject {
        id: mockToolManager
        signal runCommand(string cmd, string path)
    }

    QtObject {
        id: mockBuildManager
        signal executeCommand(string cmd, string path)
    }

    QtObject {
        id: mockDialogs
        property var settingsDialog: QtObject { function show() {} }
        property var chatLogWindow: QtObject { function show() {} }
        property var aboutWindow: QtObject { function show() {} }
    }

    PariMenuBar {
        id: menuBar
        actions: mockActions
        dialogs: mockDialogs
    }

    TestCase {
        name: "PariMenuBarTests"
        when: windowShown

        function test_initial_state() {
            verify(menuBar !== null)
            compare(menuBar.menus.length, 6)
            compare(menuBar.menus[0].title, "File")
            compare(menuBar.menus[1].title, "Edit")
            compare(menuBar.menus[2].title, "View")
            compare(menuBar.menus[3].title, "Build")
            compare(menuBar.menus[4].title, "Help")
            compare(menuBar.menus[5].title, "Git")
        }

        function test_file_menu() {
            var fileMenu = menuBar.menus[0]
            compare(fileMenu.title, "File")
        }

        function test_git_menu_enabled() {
            mockFileSystem.isGitRepository = true
            var gitMenu = menuBar.menus[5]
            verify(gitMenu.count > 0)
        }
    }
}
