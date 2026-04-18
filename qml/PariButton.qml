import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

AbstractButton {
    id: control
    
    implicitWidth: Math.max(80, contentItem.implicitWidth + 24)
    implicitHeight: 28
    
    property bool highlighted: false
    
    readonly property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false

    contentItem: Label {
        text: control.text
        font.pixelSize: 13
        color: {
            if (control.highlighted) return "#ffffff";
            return control.isDark ? "#ffffff" : "#000000";
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: control.enabled ? 1.0 : 0.5
    }

    background: Rectangle {
        radius: 4 // More modern, subtle rounding
        border.width: 1
        border.color: {
            if (control.highlighted) {
                return control.isDark ? "#0d4d92" : "#2a8bf2";
            }
            return control.isDark ? "#111111" : "#9b9b9b";
        }
        
        gradient: Gradient {
            // Main body gradient
            GradientStop { 
                position: 0.0
                color: {
                    if (control.pressed) {
                        if (control.highlighted) return control.isDark ? "#0a3d75" : "#2176d4";
                        return control.isDark ? "#1a1a1a" : "#c0c0c0";
                    }
                    if (control.highlighted) return control.isDark ? "#1a6ac3" : "#3b99fc";
                    if (control.hovered) return control.isDark ? "#4a4a4a" : "#fdfdfd";
                    return control.isDark ? "#3c3c3c" : "#f0f0f0";
                }
            }
            GradientStop { 
                position: 1.0
                color: {
                    if (control.pressed) {
                        if (control.highlighted) return control.isDark ? "#052b5e" : "#1a6ac3";
                        return control.isDark ? "#000000" : "#a0a0a0";
                    }
                    if (control.highlighted) return control.isDark ? "#0d4d92" : "#0078d7";
                    if (control.hovered) return control.isDark ? "#2a2a2a" : "#d0d0d0";
                    return control.isDark ? "#252525" : "#cccccc";
                }
            }
        }

        // Inner highlight for glass effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 3
            color: "transparent"
            border.width: 1
            border.color: "#ffffff"
            opacity: {
                if (control.highlighted) return control.isDark ? 0.05 : 0.3;
                return control.isDark ? 0.1 : 0.4;
            }
            visible: !control.pressed
        }
    }
}
