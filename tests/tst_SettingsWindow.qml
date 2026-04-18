import QtQuick
import QtTest
import QtQuick.Controls
import "../qml/app"
import "../qml/settings"
import "../qml/common"

Item {
    width: 800
    height: 600

    PariTheme {
        id: pariTheme
    }

    // Mock appSettings
    QtObject {
        id: mockSettings
        property string ollamaUrl: "http://test:11434"
        property string ollamaModel: "test-model"
        property var availableModels: ["test-model", "other-model"]
        property string fontFamily: "Courier"
        property int fontSize: 14
        property bool indentWithSpaces: true
        property int indentSize: 4
        
        property var darkTheme: QtObject {
            property color keywordColor: "#ff0000"
            property color stringColor: "#00ff00"
            property color commentColor: "#0000ff"
            property color typeColor: "#ffff00"
            property color numberColor: "#00ffff"
            property color preprocessorColor: "#ff00ff"
        }
        
        property var lightTheme: QtObject {
            property color keywordColor: "#880000"
            property color stringColor: "#008800"
            property color commentColor: "#000088"
            property color typeColor: "#888800"
            property color numberColor: "#008888"
            property color preprocessorColor: "#880088"
        }

        function saveColors() { savedColorsCalled = true }
        property bool savedColorsCalled: false
        
        function getBuildCommand(path) { return "" }
        function getRunCommand(path) { return "" }
        function getCleanCommand(path) { return "" }
    }

    // Mock llm
    QtObject {
        id: mockLlm
        function listModels() { listModelsCalled = true }
        property bool listModelsCalled: false
    }

    // Providers for the component
    property alias appSettings: mockSettings
    property alias llm: mockLlm

    SettingsWindow {
        id: window
        visible: true
    }

    TestCase {
        name: "SettingsWindowTests"
        when: windowShown

        function init() {
            // Reset state before each test
            mockSettings.ollamaUrl = "http://test:11434"
            mockSettings.ollamaModel = "test-model"
            mockSettings.savedColorsCalled = false
            mockLlm.listModelsCalled = false
            
            var urlField = findChild(window, "ollamaUrlField")
            if (urlField) urlField.text = "http://test:11434"
        }

        function test_initial_values() {
            var urlField = findChild(window, "ollamaUrlField")
            verify(urlField !== null, "URL field should be found")
            compare(urlField.text, "http://test:11434")
            
            var modelCombo = findChild(window, "ollamaModelComboBox")
            verify(modelCombo !== null, "Model combo should be found")
            compare(modelCombo.currentText, "test-model")
        }

        function test_apply_settings() {
            var urlField = findChild(window, "ollamaUrlField")
            urlField.text = "http://new-url:9999"
            
            var applyButton = findChild(window, "applyButton")
            verify(applyButton !== null, "Apply button should be found")
            mouseClick(applyButton)
            
            compare(mockSettings.ollamaUrl, "http://new-url:9999")
            verify(mockSettings.savedColorsCalled)
        }

        function test_refresh_models() {
            var refreshButton = findChild(window, "refreshButton")
            verify(refreshButton !== null, "Refresh button should be found")
            mouseClick(refreshButton)
            verify(mockLlm.listModelsCalled)
        }

        function findChild(parent, objName) {
            return findRecursively(parent, function(obj) { return obj.objectName === objName })
        }

        function findRecursively(parent, checkFunc) {
            if (!parent) return null
            if (checkFunc(parent)) return parent
            
            if (parent.data) {
                for (var i = 0; i < parent.data.length; i++) {
                    var res = findRecursively(parent.data[i], checkFunc)
                    if (res) return res
                }
            }
            
            if (parent.children) {
                for (var j = 0; j < parent.children.length; j++) {
                    var res2 = findRecursively(parent.children[j], checkFunc)
                    if (res2) return res2
                }
            }

            if (parent.contentItem && parent.contentItem !== parent) {
                var res3 = findRecursively(parent.contentItem, checkFunc)
                if (res3) return res3
            }
            
            return null
        }
    }
}
