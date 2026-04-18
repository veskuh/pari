import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    implicitHeight: 64
    width: parent.width
    
    readonly property bool isDark: appSettings.systemThemeIsDark
    
    gradient: Gradient {
        GradientStop { 
            position: 0.0
            color: root.isDark ? "#3c3c3c" : "#ffffff" 
        }
        GradientStop { 
            position: 1.0
            color: root.isDark ? "#2d2d2d" : "#e8e8e8" 
        }
    }
    
    // Top highlight line
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: root.isDark ? "#505050" : "#ffffff"
        z: 2
    }
    
    // Bottom border for depth
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: root.isDark ? "#1a1a1a" : "#bcbcbc"
        z: 2
    }
    
    // Allow direct children for explicit positioning (like the TabBar)
}
