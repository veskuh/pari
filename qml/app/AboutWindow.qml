import Kaakao
import Kaakao
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../common"

ApplicationWindow {
    id: aboutWindow
    title: qsTr("About Pari")
    width: 420
    height: 420
    modality: Qt.ApplicationModal
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.CustomizeWindowHint

    // Use pariTheme if available (global in app), otherwise fallback (for tests)
    readonly property var _theme: (typeof pariTheme !== 'undefined') ? pariTheme : fallbackTheme
    PariTheme { id: fallbackTheme }

    background: Rectangle {
        color: _theme.windowBg
        radius: 8
        border.color: _theme.sidebarBorder
        border.width: 1
    }

    // Entrance Animation
    Component.onCompleted: {
        showAnim.start()
    }

    ParallelAnimation {
        id: showAnim
        NumberAnimation { target: aboutWindow.contentItem; property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { target: aboutWindow.contentItem; property: "scale"; from: 0.95; to: 1; duration: 300; easing.type: Easing.OutBack }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. HERO HEADER (Metallic)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: _theme.isDark ? "#454545" : "#f8f9fa" }
                GradientStop { position: 1.0; color: _theme.isDark ? "#2d2d2d" : "#e9ecef" }
            }

            // Bottom "Etched" line
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: _theme.isDark ? "#1a1a1a" : "#dee2e6"
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 12

                Item {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    Layout.alignment: Qt.AlignHCenter
                    
                    Image {
                        id: logo
                        source: "qrc:/assets/pari.png"
                        anchors.fill: parent
                        smooth: true
                        layer.enabled: true
                        layer.effect: DropShadow {

                            color: "black"
                            opacity: 0.3
                            radius: 0.5
                            verticalOffset: 2
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8
                    KaakaoLabel {
                        text: "PARI"
                        font.bold: true
                        font.pixelSize: 20
                        font.letterSpacing: 2
                        color: _theme.textColor
                    }
                    Rectangle {
                        Layout.preferredWidth: versionLabel.implicitWidth + 12
                        Layout.preferredHeight: 16
                        radius: 8
                        color: _theme.accentColor
                        KaakaoLabel {
                            id: versionLabel
                            anchors.centerIn: parent
                            text: (typeof appSettings !== 'undefined') ? appSettings.version : "v1.0"
                            font.bold: true
                            font.pixelSize: 9
                            color: "white"
                        }
                    }
                }
            }
        }

        // 2. CONTENT AREA
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 24
            spacing: 16

            KaakaoLabel {
                text: qsTr("Your Local AI Coding Companion")
                font.bold: true
                font.pixelSize: 14
                color: _theme.accentColor
                Layout.alignment: Qt.AlignHCenter
            }

            KaakaoLabel {
                text: qsTr("Pari is a technical editor designed to bring the power of Large Language Models directly to your local development environment via Ollama.")
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: _theme.textColor
                font.pixelSize: 12
                lineHeight: 1.2
                opacity: 0.9
            }

            // Technical Dossier
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: dossierGrid.implicitHeight + 20
                color: _theme.isDark ? "#1a1a1a" : "#f1f3f5"
                radius: 4
                border.color: _theme.sidebarBorder
                border.width: 1

                GridLayout {
                    id: dossierGrid
                    anchors.centerIn: parent
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 8

                    KaakaoLabel {
                        text: qsTr("AUTHOR")
                        font.bold: true
                        font.pixelSize: 10
                        color: _theme.textColorMuted
                    }
                    KaakaoLabel {
                        text: "vesku.h@gmail.com"
                        color: _theme.textColor
                        font.pixelSize: 11
                    }

                    KaakaoLabel {
                        text: qsTr("ENGINE")
                        font.bold: true
                        font.pixelSize: 10
                        color: _theme.textColorMuted
                    }
                    KaakaoLabel {
                        text: "Qt " + "6.9.3" // Could be dynamic but hardcoded for now to match current env
                        color: _theme.textColor
                        font.pixelSize: 11
                    }

                    KaakaoLabel {
                        text: qsTr("LICENSE")
                        font.bold: true
                        font.pixelSize: 10
                        color: _theme.textColorMuted
                    }
                    KaakaoLabel {
                        text: "BSD-3-Clause"
                        color: _theme.textColor
                        font.pixelSize: 11
                    }

                    KaakaoLabel {
                        text: qsTr("BUILD ID")
                        font.bold: true
                        font.pixelSize: 10
                        color: _theme.textColorMuted
                    }
                    KaakaoLabel {
                        text: (typeof appSettings !== 'undefined') ? appSettings.buildId : "unknown"
                        color: _theme.textColor
                        font.pixelSize: 11
                    }
                }
            }

            Item { Layout.fillHeight: true }

            PariButton {
                text: qsTr("Close")
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 100
                Layout.bottomMargin: 12
                onClicked: aboutWindow.close()
            }
        }
    }
}
