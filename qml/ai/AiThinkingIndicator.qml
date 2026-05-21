import Kaakao
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: thinkingIndicator
    anchors.fill: parent
    anchors.margins: 10
    radius: 4
    z: 10
    
    property bool isDark: false
    property string thinkingText: ""

    color: isDark ? "#2a1a00" : "#fff9e6" // Warm LCD amber base
    border.color: isDark ? "#ffaa00" : "#ffcc00"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        
        RowLayout {
            spacing: 8
            Rectangle {
                width: 8; height: 8; radius: 4
                color: "#ffaa00"
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.3; duration: 800 }
                    NumberAnimation { from: 0.3; to: 1.0; duration: 800 }
                }
            }
            KaakaoLabel {
                text: qsTr("AI IS THINKING...")
                font.family: "Menlo"
                font.pixelSize: 12
                font.bold: true
                color: isDark ? "#ffaa00" : "#805500"
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            Flickable {
                id: thinkingFlickable
                anchors.fill: parent
                contentHeight: thinkingOutput.height
                clip: true
                
                Text {
                    id: thinkingOutput
                    width: thinkingFlickable.width
                    text: thinkingIndicator.thinkingText
                    color: isDark ? "#ffaa00" : "#805500"
                    wrapMode: Text.WordWrap
                    font.family: "Menlo"
                    font.pixelSize: 11
                    
                    onTextChanged: {
                        if (contentHeight > thinkingFlickable.height) {
                            thinkingFlickable.contentY = contentHeight - thinkingFlickable.height;
                        }
                    }
                }
            }
        }
    }
    
    // Subtle scanline effect for LCD
    Rectangle {
        anchors.fill: parent
        opacity: 0.05
        gradient: Gradient {
            GradientStop { position: 0.0; color: "black" }
            GradientStop { position: 0.5; color: "transparent" }
            GradientStop { position: 1.0; color: "black" }
        }
    }
}
