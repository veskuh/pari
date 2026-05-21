import Kaakao
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../app"

AbstractButton {
    id: control
    
    property alias iconSource: iconImage.source
    property bool isPrimary: false
    property bool highlighted: false
    
    text: action ? action.text : ""
    iconSource: action ? action.iconSource : ""
    
    readonly property var _theme: (typeof pariTheme !== 'undefined') ? pariTheme : fallbackTheme
    PariTheme { id: fallbackTheme }

    readonly property bool isDark: _theme.isDark
    
    implicitWidth: 56
    implicitHeight: 56
    
    padding: 0
    hoverEnabled: true

    contentItem: Item {}

    background: Rectangle {
        implicitWidth: 56
        implicitHeight: 56
        radius: 4
        
        // --- 1. HOVER GLOW ---
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: 6
            visible: control.hovered && !control.pressed
            color: "transparent"
            border.color: control.isDark ? "#404a9eff" : "#200078d7"
            border.width: 2
            opacity: 0.5
        }

        // --- 2. BASE SURFACE ---
        gradient: Gradient {
            GradientStop { 
                position: 0.0
                color: {
                    if (control.pressed || control.checked) {
                        if (control.isPrimary) return "#00458d";
                        return control.isDark ? "#1a1a1a" : "#c0c0c0";
                    }
                    if (control.isPrimary) return "#0069d3";
                    return control.isDark ? "#4a4a4a" : "#fdfdfd";
                }
            }
            GradientStop { 
                position: 1.0
                color: {
                    if (control.pressed || control.checked) {
                        if (control.isPrimary) return "#0051a6";
                        return control.isDark ? "#121212" : "#d0d0d0";
                    }
                    if (control.isPrimary) return "#0051a6";
                    return control.isDark ? "#383838" : "#e8e8e8";
                }
            }
        }
        
        border.color: {
            if (control.isPrimary) return "#003a78";
            if (control.checked) return control.isDark ? "#4aa9ff" : "#0051a6";
            return control.isDark ? "#111111" : "#9b9b9b";
        }
        border.width: 1
        
        // --- 3. THE ACTUAL CONTENT (Reverted to Vertical) ---
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 1
            
            Image {
                id: iconImage
                Layout.alignment: Qt.AlignHCenter
                sourceSize.width: 28
                sourceSize.height: 28
                fillMode: Image.PreserveAspectFit
                opacity: control.enabled ? 1.0 : 0.4
            }
            
            KaakaoLabel {
                Layout.alignment: Qt.AlignHCenter
                text: control.text
                font.pixelSize: _theme.fontToolbar
                color: {
                    if (control.isPrimary) return "#ffffff";
                    if (control.checked) return control.isDark ? "#4aa9ff" : "#0051a6";
                    return control.isDark ? "#b0b0b0" : "#646464";
                }
                opacity: control.enabled ? 1.0 : 0.5
            }
        }

        // --- 4. DEPTH LAYERS (Micro-bevels) ---
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1
            color: "#ffffff"
            opacity: control.isDark ? 0.15 : 0.9
            visible: !control.pressed && !control.checked
            radius: 3
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1
            color: "black"
            opacity: control.isDark ? 0.4 : 0.15
            visible: !control.pressed && !control.checked
            radius: 3
        }
        
        // --- 5. CURVATURE (Inset) ---
        Rectangle {
            anchors.fill: parent
            radius: 4
            visible: control.pressed || control.checked
            color: "transparent"
            border.color: "black"
            border.width: 1
            opacity: control.isDark ? 0.3 : 0.15
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#40000000" }
                GradientStop { position: 0.2; color: "transparent" }
                GradientStop { position: 0.8; color: "transparent" }
                GradientStop { position: 1.0; color: "#20000000" }
            }
        }
    }
}
