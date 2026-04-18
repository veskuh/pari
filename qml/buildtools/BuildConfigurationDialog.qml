import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs
import "../common"

ApplicationWindow {
    id: buildConfigurationWindow
    title: qsTr("Configure Build")
    width: 450
    height: 280
    
    // Use pariTheme if available (global in app), otherwise fallback
    readonly property var _pariTheme: (typeof pariTheme !== 'undefined') ? pariTheme : null
    color: _pariTheme ? _pariTheme.windowBg : "#f0f0f0"

    property string buildCommand: ""
    property string runCommand: ""
    property string cleanCommand: ""

    signal saveConfiguration(string buildCommand, string runCommand, string cleanCommand)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: _pariTheme ? _pariTheme.marginStandard : 15
        spacing: _pariTheme ? _pariTheme.marginStandard : 10
        
        GridLayout {
            columns: 2
            rowSpacing: 10
            columnSpacing: 10
            Layout.fillWidth: true

            Label {
                text: qsTr("Build:")
                font.bold: true
                color: _pariTheme ? _pariTheme.textColor : "#333333"
            }
            TextField {
                id: buildCommandField
                placeholderText: qsTr("cmake --build build")
                text: buildConfigurationWindow.buildCommand
                Layout.fillWidth: true
                selectByMouse: true
            }

            Label {
                text: qsTr("Run:")
                font.bold: true
                color: _pariTheme ? _pariTheme.textColor : "#333333"
            }
            TextField {
                id: runCommandField
                placeholderText: qsTr("./build/app")
                text: buildConfigurationWindow.runCommand
                Layout.fillWidth: true
                selectByMouse: true
            }

            Label {
                text: qsTr("Clean:")
                font.bold: true
                color: _pariTheme ? _pariTheme.textColor : "#333333"
            }
            TextField {
                id: cleanCommandField
                placeholderText: qsTr("rm -rf build")
                text: buildConfigurationWindow.cleanCommand
                Layout.fillWidth: true
                selectByMouse: true
            }
        }

        Item {
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: _pariTheme ? _pariTheme.paddingMedium : 10
            
            PariButton {
                text: qsTr("Save")
                highlighted: true
                onClicked: {
                    saveConfiguration(buildCommandField.text, runCommandField.text, cleanCommandField.text)
                    buildConfigurationWindow.close()
                }
            }
            PariButton {
                text: qsTr("Cancel")
                onClicked: buildConfigurationWindow.close()
            }
        }
    }
}
