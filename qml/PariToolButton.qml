import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

AbstractButton {
    id: control
    
    property alias iconSource: iconImage.source
    property bool isPrimary: false
    
    implicitWidth: 64
    implicitHeight: 64
    
    contentItem: ColumnLayout {
        spacing: 2
        anchors.centerIn: parent
        
        Image {
            id: iconImage
            Layout.alignment: Qt.AlignHCenter
            sourceSize.width: 32
            sourceSize.height: 32
            fillMode: Image.PreserveAspectFit
            opacity: control.enabled ? 1.0 : 0.5
        }
        
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: control.text
            font.pixelSize: 11
            color: control.isPrimary ? "#ffffff" : (control.checked ? "#0051a6" : "#646464")
            opacity: control.enabled ? 1.0 : 0.5
        }
    }
    
    background: Rectangle {
        implicitWidth: 60
        implicitHeight: 60
        radius: 4
        
        // Base gradient - changes when pressed OR checked
        gradient: Gradient {
            GradientStop { 
                position: 0.0
                color: (control.pressed || control.checked) ? 
                       (control.isPrimary ? "#00458d" : "#d0d0d0") : 
                       (control.isPrimary ? "#0069d3" : "#fdfdfd") 
            }
            GradientStop { 
                position: 1.0
                color: (control.pressed || control.checked) ? 
                       (control.isPrimary ? "#0051a6" : "#e0e0e0") : 
                       (control.isPrimary ? "#0051a6" : "#e8e8e8") 
            }
        }
        
        // Border for depth
        border.color: control.isPrimary ? "#003a78" : (control.checked ? "#0051a6" : "#bcbcbc")
        border.width: 1
        
        // Top highlight - hidden when pressed or checked
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1
            color: "#ffffff"
            opacity: control.isPrimary ? 0.3 : 0.8
            visible: !control.pressed && !control.checked
        }
        
        // Pressed/Checked inset shadow effect
        Rectangle {
            anchors.fill: parent
            radius: 4
            color: "black"
            opacity: 0.1
            visible: control.pressed || control.checked
        }
    }
}
