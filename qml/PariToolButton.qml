import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

AbstractButton {
    id: control
    
    property alias iconSource: iconImage.source
    property bool isPrimary: false
    
    readonly property bool isDark: appSettings.systemThemeIsDark
    
    implicitWidth: 56
    implicitHeight: 56
    
    contentItem: ColumnLayout {
        spacing: 1
        anchors.centerIn: parent
        
        Image {
            id: iconImage
            Layout.alignment: Qt.AlignHCenter
            sourceSize.width: 28
            sourceSize.height: 28
            fillMode: Image.PreserveAspectFit
            opacity: control.enabled ? 1.0 : 0.5
        }
        
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: control.text
            font.pixelSize: 10
            color: {
                if (control.isPrimary) return "#ffffff";
                if (control.checked) return control.isDark ? "#4aa9ff" : "#0051a6";
                return control.isDark ? "#b0b0b0" : "#646464";
            }
            opacity: control.enabled ? 1.0 : 0.5
        }
    }
    
    background: Rectangle {
        implicitWidth: 56
        implicitHeight: 56
        radius: 4
        
        // Base gradient - changes when pressed OR checked
        gradient: Gradient {
            GradientStop { 
                position: 0.0
                color: {
                    if (control.pressed || control.checked) {
                        if (control.isPrimary) return "#00458d";
                        return control.isDark ? "#252525" : "#d0d0d0";
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
                        return control.isDark ? "#1a1a1a" : "#e0e0e0";
                    }
                    if (control.isPrimary) return "#0051a6";
                    return control.isDark ? "#383838" : "#e8e8e8";
                }
            }
        }
        
        // Border for depth
        border.color: {
            if (control.isPrimary) return "#003a78";
            if (control.checked) return control.isDark ? "#4aa9ff" : "#0051a6";
            return control.isDark ? "#1a1a1a" : "#bcbcbc";
        }
        border.width: 1
        
        // Top highlight - hidden when pressed or checked
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1
            color: "#ffffff"
            opacity: {
                if (control.isPrimary) return 0.3;
                return control.isDark ? 0.1 : 0.8;
            }
            visible: !control.pressed && !control.checked
        }
        
        // Pressed/Checked inset shadow effect
        Rectangle {
            anchors.fill: parent
            radius: 4
            color: "black"
            opacity: control.isDark ? 0.3 : 0.1
            visible: control.pressed || control.checked
        }
    }
}
