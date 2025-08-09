import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: aboutWindow
    title: "About Pari"
    width: 400
    height: 300
    modality: Qt.ApplicationModal

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.margins: 10

        Image {
            source: "qrc:/assets/pari.png"
            sourceSize.width: 64
            sourceSize.height: 64
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "Pari - Your Local AI Coding Companion"
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "Pari is a desktop application designed to be your local AI-powered coding partner. It leverages the power of local Large Language Models (LLMs) through Ollama to assist you with various coding tasks, right on your machine."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
        }

        GridLayout {
            columns: 2
            columnSpacing: 10

            Label { text: "Author:" }
            Label { text: "vesku.h@gmail.com with help of Gemini CLI and Jules" }

            Label { text: "License:" }
            Label { text: "BSD-3-Clause" }
        }

        Button {
            text: "Close"
            Layout.alignment: Qt.AlignRight
            onClicked: aboutWindow.close()
        }
    }
}
