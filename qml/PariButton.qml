import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

AbstractButton {
    id: control
    
    implicitWidth: Math.max(80, contentItem.implicitWidth + 24)
    implicitHeight: 28
    
    property bool highlighted: false
    
    // Use pariTheme if available, otherwise fallback to appSettings (for tests)
    readonly property bool _isDark: (typeof pariTheme !== 'undefined') ? pariTheme.isDark : ((typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false)

    contentItem: Label {
        text: control.text
        font.pixelSize: (typeof pariTheme !== 'undefined') ? pariTheme.fontSizeLarge : 13
        color: {
            if (control.highlighted) return (typeof pariTheme !== 'undefined') ? pariTheme.textColorInverse : "#ffffff";
            return _isDark ? (typeof pariTheme !== 'undefined' ? pariTheme.textColorInverse : "#ffffff") : (typeof pariTheme !== 'undefined' ? pariTheme.textColor : "#000000");
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: control.enabled ? 1.0 : 0.5
    }

    background: Rectangle {
        radius: (typeof pariTheme !== 'undefined') ? pariTheme.borderRadius : 4
        border.width: 1
        border.color: {
            if (control.highlighted) {
                return _isDark ? (typeof pariTheme !== 'undefined' ? pariTheme.accentColor : "#0d4d92") : (typeof pariTheme !== 'undefined' ? pariTheme.accentColor : "#2a8bf2");
            }
            return (typeof pariTheme !== 'undefined') ? pariTheme.sidebarBorder : (_isDark ? "#111111" : "#9b9b9b");
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
                        return (typeof pariTheme !== 'undefined') ? (_isDark ? pariTheme.btnDarkPrimaryTop : pariTheme.btnLightPrimaryTop) : (_isDark ? "#1a6ac3" : "#3b99fc");
                    }
                    if (control.hovered) return _isDark ? "#4a4a4a" : "#fdfdfd";
                    return (typeof pariTheme !== 'undefined') ? (_isDark ? pariTheme.btnDarkTop : pariTheme.btnLightTop) : (_isDark ? "#3c3c3c" : "#f0f0f0");
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
                        return (typeof pariTheme !== 'undefined') ? (_isDark ? pariTheme.btnDarkPrimaryBottom : pariTheme.btnLightPrimaryBottom) : (_isDark ? "#0d4d92" : "#0078d7");
                    }
                    if (control.hovered) return _isDark ? "#2a2a2a" : "#d0d0d0";
                    return (typeof pariTheme !== 'undefined') ? (_isDark ? pariTheme.btnDarkBottom : pariTheme.btnLightBottom) : (_isDark ? "#252525" : "#cccccc");
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
