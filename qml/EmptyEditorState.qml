import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: appSettings.systemThemeIsDark ? "#1a1a1a" : "#e8e8e8"
    
    readonly property bool isDark: appSettings.systemThemeIsDark

    // Inner shadow to simulate the "Tray" depth
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        color: "transparent"
        border.color: "black"
        opacity: isDark ? 0.3 : 0.1
        radius: 2
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 30
        
        // Engraved Logo Metaphor
        Item {
            Layout.alignment: Qt.AlignHCenter
            width: 200; height: 100
            
            Label {
                text: "PARI"
                font.family: "Public Sans"
                font.pixelSize: 64
                font.bold: true
                anchors.centerIn: parent
                color: isDark ? "#121212" : "#d0d0d0"
            }
        }

        // Instructional "Technical Annotations"
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            
            Label {
                text: "← SELECT SOURCE FROM WORKSPACE"
                font.family: "Menlo"
                font.pixelSize: 11
                color: isDark ? "#444444" : "#a0a0a0"
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                text: "⌘+O TO RETRIEVE DOCUMENT"
                font.family: "Menlo"
                font.pixelSize: 11
                color: isDark ? "#444444" : "#a0a0a0"
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // Spacer between annotations and cards
        Item { Layout.preferredHeight: 30 }

        // Action Cards (Paper scraps in the tray)
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20
            
            /* Commented out as logic is not implemented yet
            EmptyStateCard {
                title: "NEW FILE"
                description: "Create blank document"
                cardIcon: "✏️"
                onClicked: {
                    // Logic can be added here
                }
            }
            */
            
            EmptyStateCard {
                title: "OPEN FOLDER"
                description: "Select project root"
                cardIcon: "📁"
                onClicked: {
                    fileDialog.open();
                }
            }
        }
    }
}
