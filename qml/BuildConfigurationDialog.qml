import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts

Dialog {
    id: buildConfigurationWindow
    title: qsTr("Configure Build")
    modal: true
    width: 450
    height: 280
    
    // Theme helper
    readonly property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false

    property string buildCommand: ""
    property string runCommand: ""
    property string cleanCommand: ""

    signal saveConfiguration(string buildCommand, string runCommand, string cleanCommand)

    background: Rectangle {
        color: isDark ? "#2d2d2d" : "#f5f5f5"
        radius: 4
        border.color: isDark ? "#444444" : "#cccccc"
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 10
        
        GridLayout {
            columns: 2
            rowSpacing: 10
            columnSpacing: 10
            Layout.fillWidth: true

            Label {
                text: qsTr("Build:")
                font.bold: true
                color: isDark ? "#e0e0e0" : "#333333"
            }
            TextField {
                id: buildCommandField
                placeholderText: qsTr("cmake --build build")
                text: buildConfigurationWindow.buildCommand
                Layout.fillWidth: true
                selectByMouse: true
                color: isDark ? "#ffffff" : "#000000"
            }

            Label {
                text: qsTr("Run:")
                font.bold: true
                color: isDark ? "#e0e0e0" : "#333333"
            }
            TextField {
                id: runCommandField
                placeholderText: qsTr("./build/app")
                text: buildConfigurationWindow.runCommand
                Layout.fillWidth: true
                selectByMouse: true
                color: isDark ? "#ffffff" : "#000000"
            }

            Label {
                text: qsTr("Clean:")
                font.bold: true
                color: isDark ? "#e0e0e0" : "#333333"
            }
            TextField {
                id: cleanCommandField
                placeholderText: qsTr("rm -rf build")
                text: buildConfigurationWindow.cleanCommand
                Layout.fillWidth: true
                selectByMouse: true
                color: isDark ? "#ffffff" : "#000000"
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    footer: DialogButtonBox {
        alignment: Qt.AlignRight
        background: Rectangle {
            color: "transparent"
        }
        
        PariButton {
            objectName: "saveButton"
            text: qsTr("Save")
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            highlighted: true
        }
        PariButton {
            objectName: "cancelButton"
            text: qsTr("Cancel")
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }

    onAccepted: {
        saveConfiguration(buildCommandField.text, runCommandField.text, cleanCommandField.text)
    }
}
