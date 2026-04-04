import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    implicitHeight: 64
    width: parent.width
    
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#ffffff" }
        GradientStop { position: 1.0; color: "#e8e8e8" }
    }
    
    // Top highlight line
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: "#ffffff"
        z: 2
    }
    
    // Bottom border for depth
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#bcbcbc"
        z: 2
    }
    
    // Allow direct children for explicit positioning (like the TabBar)
}
