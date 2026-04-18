import QtQuick
import QtTest
import "../qml/app"

Item {
    width: 200
    height: 200

    QtObject {
        id: mockRootWindow
        property var fileSystemView: QtObject { property var model: null }
        property bool hasBuildConfiguration: false
        function showGitOutput(cmd, out, branch) {}
    }

    QtObject {
        id: mockStatusBar
        property string text: ""
        property string modelName: ""
        property string branchName: ""
    }

    property alias fileSystem: mockFileSystem
    property alias appSettings: mockSettings
    property alias documentManager: mockDocumentManager
    property alias buildManager: mockBuildManager
    property alias llm: mockLlm
    property alias toolManager: mockToolManager
    property alias gitManager: mockGitManager

    QtObject {
        id: mockFileSystem
        property string rootPath: "/root"
        property var model: "fileModel"
        property bool showHiddenFiles: false
        signal fileSaved(string filePath)
        signal fileRenamed(string oldPath, string newPath)
    }

    QtObject {
        id: mockSettings
        property bool showHiddenFiles: false
        property string ollamaModel: "test-model"
        function getBuildCommand(path) { return "make" }
    }

    QtObject {
        id: mockDocumentManager
        function updatePath(oldP, newP) {}
    }
    
    QtObject {
        id: mockBuildManager
        signal outputReady(string output)
        signal errorReady(string error)
        signal finished()
    }

    QtObject {
        id: mockLlm
        property bool busy: false
        signal responseReady(string response)
    }

    QtObject {
        id: mockToolManager
        signal outputReady(string command, string output, string branchName)
        signal qmlFileIndented(string formattedContent)
        signal gitLogReady(string log)
    }

    QtObject {
        id: mockGitManager
        property string currentBranch: "main"
    }

    AppLogic {
        id: appLogic
        rootWindow: mockRootWindow
        customStatusBar: mockStatusBar
        outputArea: QtObject { property string text: "" }
        aiOutputPane: QtObject { property string text: ""; function updateDiff(text) {} }
        gitLogModel: QtObject { function parseAndSetLog(log) {} }
        injectedGitManager: mockGitManager
        stackLayout: QtObject { property int currentIndex: 0 }
        dialogs: QtObject {}
    }

    TestCase {
        name: "AppLogicTests"

        function test_initial_state() {
            verify(appLogic !== null)
        }
    }
}
