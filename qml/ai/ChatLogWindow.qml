import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

Window {
    id: chatLogWindow
    width: 800
    height: 600
    title: qsTr("Chat Log")
    visible: false
    
    // Use pariTheme if available (global in app), otherwise fallback
    readonly property var _pariTheme: (typeof pariTheme !== 'undefined') ? pariTheme : null
    color: _pariTheme ? _pariTheme.windowBg : "#f0f0f0"

    property var chatLlm: null

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: _pariTheme ? _pariTheme.marginStandard : 10
        spacing: _pariTheme ? _pariTheme.marginStandard : 10

        Label {
            text: qsTr("Chat Session Log")
            font.bold: true
            font.pixelSize: _pariTheme ? _pariTheme.fontSizeLarge : 14
            Layout.alignment: Qt.AlignHCenter
            color: _pariTheme ? _pariTheme.textColor : "black"
        }

        ListView {
            id: chatLogView
            objectName: "chatLogView"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: chatLlm ? chatLlm.chatLog : []
            spacing: _pariTheme ? _pariTheme.paddingSmall : 5

            delegate: Rectangle {
                width: chatLogView.width - 20
                height: logText.implicitHeight + (_pariTheme ? _pariTheme.paddingLarge : 10)
                color: {
                    if (modelData.includes("USER:")) return _pariTheme ? (_pariTheme.isDark ? "#2d2d2d" : "#e0e0e0") : "#e0e0e0";
                    if (modelData.includes("ERROR:")) return _pariTheme ? (_pariTheme.isDark ? "#442222" : "#ffebee") : "#ffebee";
                    return _pariTheme ? _pariTheme.editorBg : "#ffffff";
                }
                radius: _pariTheme ? _pariTheme.borderRadius : 4
                border.color: _pariTheme ? _pariTheme.sidebarBorder : "gray"
                border.width: 1

                Text {
                    id: logText
                    anchors.fill: parent
                    anchors.margins: _pariTheme ? _pariTheme.paddingMedium : 5
                    text: modelData
                    wrapMode: Text.WordWrap
                    color: modelData.includes("ERROR:") ? "red" : (_pariTheme ? _pariTheme.textColor : "black")
                    font.family: _pariTheme ? _pariTheme.monoFont : "Menlo"
                    font.pixelSize: _pariTheme ? _pariTheme.fontSize : 12
                }
            }

            ScrollBar.vertical: ScrollBar {
                active: true
            }

            onCountChanged: {
                chatLogView.positionViewAtEnd()
            }
        }

        PariButton {
            text: qsTr("Close")
            Layout.alignment: Qt.AlignRight
            highlighted: true
            onClicked: chatLogWindow.close()
        }
    }
}
