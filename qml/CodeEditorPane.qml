import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import net.veskuh.pari 1.0

ColumnLayout {
    property alias text: codeEditor.text
    property alias textDocument: codeEditor.textDocument
    property int cursorPosition: 0

    TextDocumentSearcher {
        id: textDocumentSearcher
    }

    function saveCursorPosition() {
        cursorPosition = codeEditor.cursorPosition;
    }

    function restoreCursorPosition() {
        codeEditor.cursorPosition = cursorPosition;
    }

    function find() {
        findOverlay.open();
    }

    function isCppFile(filePath) {
        return filePath.endsWith(".cpp") || filePath.endsWith(".h") || filePath.endsWith(".cxx") || filePath.endsWith(".hpp") || filePath.endsWith(".cc") || filePath.endsWith(".hh")
    }

    function showBuildPanel() {
        flickable.contentY = 0;
        outputArea.text = "";
        outputPanel.visible = true;
    }

    Label {
        text: qsTr("Code Editor")
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 5
        Layout.bottomMargin: 5
    }

    FindOverlay {
        id: findOverlay
        width: parent.width
        color: appWindow.palette.window
        borderColor: appWindow.palette.windowText
        textColor: appWindow.palette.text
        textBackgroundColor: appWindow.palette.base
        onFindNext: {
            var newPos = textDocumentSearcher.find(codeEditor.textDocument, findOverlay.searchText, codeEditor.cursorPosition, 0);
            if (newPos !== -1) {
                codeEditor.cursorPosition = newPos;
                codeEditor.select(newPos - searchText.length, newPos);
            }
            var occurrences = codeEditor.text.split(findOverlay.searchText).length - 1;
            findOverlay.updateResults(occurrences);
        }

        onFindPrevious: {
            var oldPos = codeEditor.cursorPosition;
            var newPos = textDocumentSearcher.find(codeEditor.textDocument, findOverlay.searchText, codeEditor.cursorPosition, 1);
            if (codeEditor.cursorPosition === newPos) {
                newPos = textDocumentSearcher.find(codeEditor.textDocument, findOverlay.searchText, codeEditor.cursorPosition - findOverlay.searchText.length, 1);
            }

            if (newPos !== -1) {
                codeEditor.cursorPosition = newPos;
                codeEditor.select(newPos - searchText.length, newPos);
            }
            var occurrences = codeEditor.text.split(findOverlay.searchText).length - 1;
            findOverlay.updateResults(occurrences);
        }
        onCloseOverlay: close()
    }

    // ScrollView is necessary for when content exceeds the visible area.
    ScrollView {
        id: codeEditorScrollView
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true // Ensures content doesn't draw outside the ScrollView

        TextArea {
            id: codeEditor
            placeholderText: "Open a file or start typing..."
            wrapMode: Text.WordWrap
            font.family: appSettings.fontFamily
            font.pointSize: appSettings.fontSize
            tabStopDistance: 4 * textMetrics.advanceWidth
            onTextChanged: {
                aiOutputPane.updateDiff(codeEditor.text)
                if (fileSystem.currentFilePath && isCppFile(fileSystem.currentFilePath)) {
                    lspClient.documentChanged(fileSystem.currentFilePath, codeEditor.text)
                    var text = codeEditor.getText(0, codeEditor.cursorPosition)
                    if (text.endsWith(".") || text.endsWith("->")) {
                        var textToCursor = codeEditor.getText(0, codeEditor.cursorPosition)
                        var lines = textToCursor.split(/\r?\n/)
                        var line = lines.length - 1
                        var character = lines[lines.length - 1].length
                        console.log("Requesting completion at", line, character)
                        lspClient.requestCompletion(fileSystem.currentFilePath, line, character)
                    }
                }
            }
            property int savedCursorPosition: 0

            TextMetrics {
                id: textMetrics
                font: codeEditor.font
            }
        }
    }

    Rectangle {
        id: outputPanel
        Layout.fillWidth: true
        Layout.preferredHeight: 200
        visible: false
        color: appWindow.palette.window
        border.color: appWindow.palette.windowText

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5

            RowLayout {
                Label {
                    text: "Build Output"
                    font.bold: true
                }
                Button {
                    text: "Close"
                    onClicked: outputPanel.visible = false
                    Layout.alignment: Qt.AlignRight
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Flickable {
                    id: flickable
                    clip: true
                    width: parent.width
                    TextArea {
                        id: outputArea
                        readOnly: true
                        width: parent.width
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                        onTextChanged: {
                            if (contentHeight > flickable.height) {
                                flickable.contentY = contentHeight - flickable.height;
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: buildManager
        function onOutputReady(output) {
            outputArea.text += output;
        }
        function onErrorReady(error) {
            outputArea.text += error;
        }
        function onFinished() {
            outputArea.text += "Ready.";
            console.log("Ready");
        }
    }

    Connections {
        target: lspClient
        function onCompletionItems(items) {
            completionModel.clear()
            for (var i = 0; i < items.length; ++i) {
                completionModel.append({ "text": items[i] })
            }
            completionPopup.open()
        }
    }

    ListModel {
        id: completionModel
    }

    Popup {
        id: completionPopup
        width: 200
        height: 300
        y: codeEditor.cursorRectangle.y + codeEditor.cursorRectangle.height
        x: codeEditor.cursorRectangle.x

        ListView {
            anchors.fill: parent
            model: completionModel
            delegate: ItemDelegate {
                text: model.text
                width: parent.width
                onClicked: {
                    var cursorPos = codeEditor.cursorPosition
                    var text = codeEditor.text
                    var textToInsert = model.text
                    codeEditor.text = text.substring(0, cursorPos) + textToInsert + text.substring(cursorPos)
                    completionPopup.close()
                }
            }
        }
    }
}
