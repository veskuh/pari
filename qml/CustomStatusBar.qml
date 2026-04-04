import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    implicitHeight: 24
    width: parent.width
    
    property alias text: statusLabel.text
    property alias modelName: modelLabel.text
    property alias branchName: branchLabel.text
    
    readonly property bool isDark: appSettings.systemThemeIsDark
    
    gradient: Gradient {
        GradientStop { 
            position: 0.0
            color: root.isDark ? "#3c3c3c" : "#e2e2e2" 
        }
        GradientStop { 
            position: 1.0
            color: root.isDark ? "#2d2d2d" : "#d0d0d0" 
        }
    }
    
    // Top highlight line to separate from the content area
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: root.isDark ? "#505050" : "#ffffff"
        z: 2
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 12
        
        // Recessed LCD-style indicator for Branch
        Rectangle {
            Layout.preferredHeight: 18
            Layout.preferredWidth: branchLabel.implicitWidth + 12
            visible: branchLabel.text !== ""
            radius: 2
            color: root.isDark ? "#1a1a1a" : "#fdfdfd"
            border.color: root.isDark ? "#121212" : "#bcbcbc"
            
            Label {
                id: branchLabel
                anchors.centerIn: parent
                font.family: "Menlo"
                font.pixelSize: 10
                color: root.isDark ? "#4aa9ff" : "#0051a6"
            }
            
            // Inset shadow for LCD effect
            Rectangle {
                anchors.fill: parent
                radius: 2
                color: "black"
                opacity: 0.05
            }
        }

        // Recessed LCD-style indicator for Model
        Rectangle {
            Layout.preferredHeight: 18
            Layout.preferredWidth: modelLabel.implicitWidth + 12
            visible: modelLabel.text !== ""
            radius: 2
            color: root.isDark ? "#1a1a1a" : "#fdfdfd"
            border.color: root.isDark ? "#121212" : "#bcbcbc"
            
            Label {
                id: modelLabel
                anchors.centerIn: parent
                font.family: "Menlo"
                font.pixelSize: 10
                color: root.isDark ? "#b0b0b0" : "#646464"
            }

            // Inset shadow for LCD effect
            Rectangle {
                anchors.fill: parent
                radius: 2
                color: "black"
                opacity: 0.05
            }
        }

        Item { Layout.fillWidth: true }

        // Recessed LCD-style indicator for Status Message
        Rectangle {
            Layout.preferredHeight: 18
            Layout.preferredWidth: statusLabel.implicitWidth + 16
            radius: 2
            color: root.isDark ? "#1a1a1a" : "#fdfdfd"
            border.color: root.isDark ? "#121212" : "#bcbcbc"
            
            Label {
                id: statusLabel
                anchors.centerIn: parent
                font.family: "Menlo"
                font.pixelSize: 10
                color: root.isDark ? "#b0b0b0" : "#444444"
                text: qsTr("Ready")
            }

            // Inset shadow for LCD effect
            Rectangle {
                anchors.fill: parent
                radius: 2
                color: "black"
                opacity: 0.05
            }
        }
    }
}
