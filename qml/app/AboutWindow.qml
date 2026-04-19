import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

ApplicationWindow {
    id: aboutWindow
    title: "About Pari"
    width: 400
    height: 320
    modality: Qt.ApplicationModal

    // Use pariTheme if available (global in app), otherwise fallback (for tests)
    readonly property var _pariTheme: (typeof pariTheme !== 'undefined') ? pariTheme : null

    background: Rectangle {
        color: _pariTheme ? _pariTheme.windowBg : "#f0f0f0"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: _pariTheme ? _pariTheme.paddingLarge : 10
        anchors.margins: _pariTheme ? _pariTheme.marginStandard : 15

        Image {
            source: "qrc:/assets/pari.png"
            sourceSize.width: 64
            sourceSize.height: 64
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: _pariTheme ? _pariTheme.paddingMedium : 8
        }

        Label {
            text: "Pari - Your Local AI Coding Companion"
            font.bold: true
            font.pixelSize: _pariTheme ? _pariTheme.fontSizeLarge : 14
            color: _pariTheme ? _pariTheme.textColor : "black"
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "Pari is a desktop application designed to be your local AI-powered coding partner. It leverages the power of local Large Language Models (LLMs) through Ollama to assist you with various coding tasks, right on your machine."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            color: _pariTheme ? _pariTheme.textColor : "black"
            font.pixelSize: _pariTheme ? _pariTheme.fontSize : 12
        }

        Item {
            Layout.fillHeight: true
        }

        GridLayout {
            columns: 2
            columnSpacing: _pariTheme ? _pariTheme.paddingLarge : 10
            rowSpacing: _pariTheme ? _pariTheme.paddingSmall : 4

            Label {
                text: "Author:"
                font.bold: true
                color: _pariTheme ? _pariTheme.textColorDim : "gray"
            }
            Label {
                text: "vesku.h@gmail.com with help of Gemini CLI and Jules"
                color: _pariTheme ? _pariTheme.textColor : "black"
            }

            Label {
                text: "License:"
                font.bold: true
                color: _pariTheme ? _pariTheme.textColorDim : "gray"
            }
            Label {
                text: "BSD-3-Clause"
                color: _pariTheme ? _pariTheme.textColor : "black"
            }
        }

        Item {
            Layout.fillHeight: true
        }

        PariButton {
            objectName: "closeButton"
            text: qsTr("Close")
            Layout.alignment: Qt.AlignHCenter
            onClicked: aboutWindow.close()
        }
    }
}

