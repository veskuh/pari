import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kaakao 1.0

KaakaoStatusBar {
    id: root

    property alias text: statusLabel.text
    property string modelName: ""
    property string branchName: ""

    readonly property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false

    // Recessed LCD-style indicator for Branch
    Rectangle {
        Layout.preferredHeight: 18
        Layout.preferredWidth: branchLabel.implicitWidth + 12
        visible: root.branchName !== ""
        radius: Theme.radiusSmall
        color: Theme.contentBackground
        border.color: Theme.buttonBorder

        Label {
            id: branchLabel
            text: "🌿 " + root.branchName
            anchors.centerIn: parent
            font.family: Theme.defaultFont.family
            font.pixelSize: 10
            color: Theme.primaryAccent
        }
    }

    // Recessed LCD-style indicator for Model
    Rectangle {
        Layout.preferredHeight: 18
        Layout.preferredWidth: modelLabel.implicitWidth + 12
        visible: root.modelName !== ""
        radius: Theme.radiusSmall
        color: Theme.contentBackground
        border.color: Theme.buttonBorder

        Label {
            id: modelLabel
            text: "💡 " + root.modelName
            anchors.centerIn: parent
            font.family: Theme.defaultFont.family
            font.pixelSize: 10
            color: Theme.secondaryText
        }
    }

    Item { Layout.fillWidth: true }

    // Recessed LCD-style indicator for Status Message
    Rectangle {
        Layout.preferredHeight: 18
        Layout.preferredWidth: statusLabel.implicitWidth + 16
        radius: Theme.radiusSmall
        color: Theme.contentBackground
        border.color: Theme.buttonBorder

        Label {
            id: statusLabel
            anchors.centerIn: parent
            font.family: Theme.defaultFont.family
            font.pixelSize: 10
            color: Theme.primaryText
            text: qsTr("Ready")
        }
    }
}
