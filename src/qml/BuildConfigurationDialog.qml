import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: buildConfigurationWindow
    title: "Configure Build"
    width: 600
    height: 300

    property string buildCommand: ""
    property string runCommand: ""
    property string cleanCommand: ""

    signal saveConfiguration(string buildCommand, string runCommand, string cleanCommand)

    Pane {
        padding: 10

        ColumnLayout {
            spacing: 10
            anchors.fill: parent

            Label {
                text: "Build Command:"
                font.bold: true
            }
            TextField {
                id: buildCommandField
                placeholderText: "e.g., make"
                text: buildConfigurationWindow.buildCommand
                Layout.fillWidth: true
            }

            Label {
                text: "Run Command:"
                font.bold: true
            }
            TextField {
                id: runCommandField
                placeholderText: "e.g., ./my_app"
                text: buildConfigurationWindow.runCommand
                Layout.fillWidth: true
            }

            Label {
                text: "Clean Command:"
                font.bold: true
            }
            TextField {
                id: cleanCommandField
                placeholderText: "e.g., make clean"
                text: buildConfigurationWindow.cleanCommand
                Layout.fillWidth: true
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                Button {
                    text: "Save"
                    onClicked: {
                        buildConfigurationWindow.saveConfiguration(buildCommandField.text, runCommandField.text, cleanCommandField.text)
                        buildConfigurationWindow.close()
                    }
                    highlighted: true
                }
                Button {
                    text: "Cancel"
                    onClicked: buildConfigurationWindow.close()
                }
            }
        }
    }
}
