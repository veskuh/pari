import Kaakao
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import "../app"

AbstractButton {
    id: control
    
    implicitWidth: Math.max(80, contentItem.implicitWidth + 24)
    implicitHeight: 28
    
    property bool highlighted: false
    
    // Use pariTheme if available, otherwise fallback to a local PariTheme instance (for tests)
    readonly property var _theme: (typeof pariTheme !== 'undefined') ? pariTheme : fallbackTheme
    PariTheme { id: fallbackTheme }

    readonly property bool _isDark: _theme.isDark

    contentItem: KaakaoLabel {
        text: control.text
        font.pixelSize: _theme.fontButton
        color: {
            if (control.highlighted) return _theme.textColorInverse;
            return _isDark ? _theme.textColorInverse : _theme.textColor;
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: control.enabled ? 1.0 : 0.5
    }

    background: Rectangle {
        radius: _theme.borderRadius
        border.width: 1
        border.color: {
            if (control.highlighted) {
                return _theme.accentColor;
            }
            return _theme.sidebarBorder;
        }
        
        gradient: Gradient {
            GradientStop { 
                position: 0.0
                color: {
                    if (control.pressed) {
                        if (control.highlighted) return _isDark ? "#0a3d75" : "#2176d4";
                        return _isDark ? "#1a1a1a" : "#c0c0c0";
                    }
                    if (control.highlighted) {
                        return _isDark ? _theme.btnDarkPrimaryTop : _theme.btnLightPrimaryTop;
                    }
                    if (control.hovered) return _isDark ? "#4a4a4a" : "#fdfdfd";
                    return _isDark ? _theme.btnDarkTop : _theme.btnLightTop;
                }
            }
            GradientStop { 
                position: 1.0
                color: {
                    if (control.pressed) {
                        if (control.highlighted) return _isDark ? "#052b5e" : "#1a6ac3";
                        return _isDark ? "#000000" : "#a0a0a0";
                    }
                    if (control.highlighted) {
                        return _isDark ? _theme.btnDarkPrimaryBottom : _theme.btnLightPrimaryBottom;
                    }
                    if (control.hovered) return _isDark ? "#2a2a2a" : "#d0d0d0";
                    return _isDark ? _theme.btnDarkBottom : _theme.btnLightBottom;
                }
            }
        }

        // Inner highlight for glass effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.width: 1
            border.color: "#ffffff"
            opacity: {
                if (control.highlighted) return _isDark ? 0.05 : 0.3;
                return _isDark ? 0.1 : 0.4;
            }
            visible: !control.pressed
        }
    }
}
