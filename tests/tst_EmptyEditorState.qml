import QtQuick
import QtTest
import QtQuick.Controls
import QtQuick.Layouts
import "../qml"

Item {
    width: 600
    height: 400

    QtObject {
        id: mockSettings
        property bool systemThemeIsDark: false
    }

    QtObject {
        id: mockFileDialog
        property bool wasOpened: false
        function open() {
            wasOpened = true;
        }
    }

    property alias appSettings: mockSettings
    property alias fileDialog: mockFileDialog

    EmptyEditorState {
        id: emptyState
        anchors.fill: parent
    }

    TestCase {
        name: "EmptyEditorStateTests"
        when: windowShown

        function init() {
            mockSettings.systemThemeIsDark = false
            mockFileDialog.wasOpened = false
        }

        // QML test helper to find a child by type string
        function findChildByType(parent, typeString) {
            if (parent.toString().indexOf(typeString) !== -1) return parent;
            for (var i = 0; i < parent.children.length; ++i) {
                var found = findChildByType(parent.children[i], typeString)
                if (found) return found
            }
            return null
        }

        // QML test helper to find a child by a specific property
        function findChildByProperty(parent, prop, val) {
            if (parent[prop] === val) return parent;
            for (var i = 0; i < parent.children.length; ++i) {
                var found = findChildByProperty(parent.children[i], prop, val)
                if (found) return found
            }
            return null
        }

        function test_theme_change() {
            compare(emptyState.isDark, false)
            compare(emptyState.color.toString(), "#e8e8e8")

            mockSettings.systemThemeIsDark = true
            compare(emptyState.isDark, true)
            compare(emptyState.color.toString(), "#1a1a1a")
        }

        function test_open_folder() {
            var openFolderCard = findChildByProperty(emptyState, "title", "OPEN FOLDER")
            verify(openFolderCard !== null, "OPEN FOLDER card should exist")

            verify(!mockFileDialog.wasOpened)

            // EmptyStateCard is just an Item with a MouseArea. We need to click the mouse area.
            // Or just trigger clicked() signal directly if exposed, but we can try to click the center of the item.
            var x = openFolderCard.x + openFolderCard.width / 2
            var y = openFolderCard.y + openFolderCard.height / 2

            mouseClick(openFolderCard, openFolderCard.width / 2, openFolderCard.height / 2)

            verify(mockFileDialog.wasOpened, "fileDialog.open() should have been called")
        }
    }
}
