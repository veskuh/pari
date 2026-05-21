import Kaakao
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../app"

KaakaoButton {
    id: control
    
    property string iconText: ""
    property bool isDark: (typeof pariTheme !== 'undefined') ? pariTheme.isDark : false
    
    implicitWidth: 26
    implicitHeight: 26
    
    hoverEnabled: true
    
    background: Rectangle {
        radius: 4
        
        // Base gradient for El Capitan style depth
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: {
                    if (control.pressed || control.checked) return control.isDark ? "#1a1a1a" : "#b0b0b0"
                    if (control.hovered) return control.isDark ? "#4a4a4a" : "#ffffff"
                    return control.isDark ? "#3a3a3a" : "#f5f5f5"
                }
            }
            GradientStop {
                position: 1.0
                color: {
                    if (control.pressed || control.checked) return control.isDark ? "#050505" : "#909090"
                    if (control.hovered) return control.isDark ? "#303030" : "#e0e0e0"
                    return control.isDark ? "#2a2a2a" : "#d8d8d8"
                }
            }
        }
        
        // Subtle border
        border.color: control.isDark ? "#111111" : "#a0a0a0"
        border.width: 1

        // Top "Light Catcher" Bevel
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1
            radius: 3
            color: "#ffffff"
            opacity: control.isDark ? 0.1 : 0.8
            visible: !control.pressed && !control.checked
        }

        // Bottom "Drop Shadow" (internal)
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1
            radius: 3
            color: "#000000"
            opacity: control.isDark ? 0.3 : 0.1
            visible: !control.pressed && !control.checked
        }
        
        // Pressed / Checked Inset Shadow
        Rectangle {
            anchors.fill: parent
            radius: 4
            visible: control.pressed || control.checked
            color: "transparent"
            border.color: "#000000"
            border.width: 1
            opacity: 0.2
        }
    }
    
    contentItem: Text {
        text: control.text !== "" ? control.text : control.iconText
        font.pixelSize: 12
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: {
            if (control.checked) return control.isDark ? "#4aa9ff" : "#005bb7"
            if (!control.enabled) return control.isDark ? "#555555" : "#aaaaaa"
            return control.isDark ? "#e0e0e0" : "#333333"
        }
        
        // Subtle text shadow for depth in light theme
        style: control.isDark ? Text.Normal : Text.Raised
        styleColor: "#ffffff"
        
        Behavior on color { ColorAnimation { duration: 100 } }
    }
}
