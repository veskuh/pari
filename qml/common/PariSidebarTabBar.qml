import Kaakao
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../app"

Rectangle {
    id: root
    
    property int currentIndex: 0
    property var model: [] // Array of { text: "Name", icon: "qrc:/..." }
    
    signal tabClicked(int index)

    readonly property var _theme: (typeof pariTheme !== 'undefined') ? pariTheme : fallbackTheme
    PariTheme { id: fallbackTheme }
    readonly property bool isDark: _theme.isDark

    implicitHeight: 34
    
    // Unified Metallic Background (El Capitan Style)
    gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0.0; color: root.isDark ? "#454545" : "#f0f0f0" }
        GradientStop { position: 1.0; color: root.isDark ? "#383838" : "#d8d8d8" }
    }
    
    // Top border to separate from toolbar if needed, or just standard bezel
    Rectangle {
        anchors.top: parent.top
        width: parent.width; height: 1
        color: root.isDark ? "#555555" : "#ffffff"
        opacity: 0.5
    }

    // Bottom "Etched" line
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width; height: 1
        color: root.isDark ? "#1a1a1a" : "#b0b0b0"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.model
            delegate: Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                AbstractButton {
                    id: tabBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    
                    contentItem: Item {
                        implicitWidth: contentRow.width
                        implicitHeight: contentRow.height
                        Row {
                            id: contentRow
                            anchors.centerIn: parent
                            spacing: 6
                            Image {
                                source: modelData.icon
                                sourceSize.width: 14
                                sourceSize.height: 14
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: root.currentIndex === index ? 1.0 : 0.6
                            }
                            KaakaoLabel {
                                text: modelData.text
                                font.pixelSize: 11
                                font.bold: root.currentIndex === index
                                color: root.isDark ? "#e0e0e0" : "#333333"
                                opacity: root.currentIndex === index ? 1.0 : 0.8
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    onClicked: {
                        root.currentIndex = index
                        root.tabClicked(index)
                    }

                    background: Item {
                        // The recessed highlight (Well)
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 6
                            visible: root.currentIndex === index
                            color: root.isDark ? "#1a1a1a" : "#c0c0c0"
                            
                            // Inset shadow for the "Well"
                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                                color: "transparent"
                                border.color: "#000000"
                                border.width: 1
                                opacity: 0.2
                            }
                        }

                        // Single consolidated etched divider between tabs
                        Item {
                            anchors.horizontalCenter: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: 6
                            anchors.bottomMargin: 6
                            width: 2
                            visible: index < root.model.length - 1
                            
                            Rectangle {
                                anchors.left: parent.left
                                width: 1; height: parent.height
                                color: root.isDark ? "#1a1a1a" : "#a0a0a0"
                            }
                            Rectangle {
                                anchors.left: parent.left
                                anchors.leftMargin: 1
                                width: 1; height: parent.height
                                color: root.isDark ? "#444444" : "#ffffff"
                                opacity: 0.5
                            }
                        }
                    }
                } // AbstractButton
            } // Item delegate
        } // Repeater
    } // RowLayout
}
