import Kaakao
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

AbstractButton {
    id: control
    
    property string title: ""
    property string description: ""
    property string cardIcon: ""
    
    implicitWidth: 160
    implicitHeight: 110
    
    readonly property bool isDark: appSettings.systemThemeIsDark

    background: Rectangle {
        radius: 4
        color: isDark ? (control.pressed ? "#2a2a2a" : "#222222") : (control.pressed ? "#f0f0f0" : "#ffffff")
        
        border.color: isDark ? "#333333" : "#d0d0d0"
        border.width: 1
        
        // Subtle gradient for the paper look
        gradient: Gradient {
            GradientStop { position: 0.0; color: isDark ? "#2d2d2d" : "#ffffff" }
            GradientStop { position: 1.0; color: isDark ? "#222222" : "#fdfdfd" }
        }
    }

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - 20
            spacing: 8
            
            Text {
                text: control.cardIcon
                font.pixelSize: 28
                Layout.alignment: Qt.AlignHCenter
            }
            
            KaakaoLabel {
                text: control.title
                font.family: "Public Sans"
                font.pixelSize: 11
                font.bold: true
                color: isDark ? "#d0d0d0" : "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            KaakaoLabel {
                text: control.description
                font.family: "Public Sans"
                font.pixelSize: 9
                color: isDark ? "#888888" : "#666666"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
