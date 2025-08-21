import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: buildConfigurationDialog
    title: "Configure Build"
    modal: true
    width: 400
    height: 250

    property string buildCommand: ""
    property string runCommand: ""
    property string cleanCommand: ""

    signal saveConfiguration(string buildCommand, string runCommand, string cleanCommand)

    contentItem: ColumnLayout {
        spacing: 10
        anchors.fill: parent

        TextField {
            id: buildCommandField
            placeholderText: "Build Command"
            text: buildConfigurationDialog.buildCommand
            Layout.fillWidth: true
        }

        TextField {
            id: runCommandField
            placeholderText: "Run Command"
            text: buildConfigurationDialog.runCommand
            Layout.fillWidth: true
        }

        TextField {
            id: cleanCommandField
            placeholderText: "Clean Command"
            text: buildConfigurationDialog.cleanCommand
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                text: "Save"
                onClicked: {
                    buildConfigurationDialog.saveConfiguration(buildCommandField.text, runCommandField.text, cleanCommandField.text)
                    buildConfigurationDialog.close()
                }
            }
            Button {
                text: "Cancel"
                onClicked: buildConfigurationDialog.close()
            }
        }
    }
}
