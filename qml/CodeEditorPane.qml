import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import net.veskuh.pari 1.0

ColumnLayout {
    property alias text: codeEditor.text
    property alias selection: codeEditor.selectedText
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

    function format() {
        if (fileSystem.currentFilePath) {
            if (fileSystem.currentFilePath.endsWith(".qml")) {
                toolManager.indentQmlFile(fileSystem.currentFilePath, codeEditor.text);
            } else if (isCppFile(fileSystem.currentFilePath)) {
                lspClient.format(fileSystem.currentFilePath, codeEditor.text);
            }
        }
    }

    function isCppFile(filePath) {
        return filePath.endsWith(".cpp") || filePath.endsWith(".h") || filePath.endsWith(".cxx") || filePath.endsWith(".hpp") || filePath.endsWith(".cc") || filePath.endsWith(".hh");
    }

    function showBuildPanel() {
        flickable.contentY = 0;
        outputArea.text = "";
        outputPanel.visible = true;
    }

    Label {
        text: fileSystem.currentFilePath ? fileSystem.currentFilePath : qsTr("📝 Code Editor")
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
            placeholderText: "✏️ Open a file or start typing..."
            wrapMode: Text.WordWrap
            font.family: appSettings.fontFamily
            font.pointSize: appSettings.fontSize
            tabStopDistance: 4 * textMetrics.advanceWidth
            function handleAutoIndent() {
                if (isIndenting || !codeEditor.activeFocus) {
                    return;
                }

                var currentPos = codeEditor.cursorPosition;
                var text = codeEditor.getText(0, currentPos);
                var lines = text.split('\n');
                if (lines.length < 2) {
                    return;
                }

                var line = lines[lines.length - 1];
                if (line !== "") {
                    return;
                }

                var previousLine = lines[lines.length - 2];
                var indentation = previousLine.match(/^\s*/)[0];
                if (previousLine.trim().endsWith('{')) {
                    indentation += "    ";
                }
                if (line.trim().startsWith('}')) {
                    indentation = indentation.substring(0, Math.max(0, indentation.length - 4));
                }
                isIndenting = true;
                codeEditor.insert(currentPos, indentation);
                isIndenting = false;
            }

            onTextChanged: {
                // We are only intrested in new letters being typed
                if (codeEditor.length !== (previousLength + 1)) {
                    previousLength = codeEditor.length;
                    return;
                }
                previousLength = codeEditor.length;

                aiOutputPane.updateDiff(codeEditor.text);
                if (fileSystem.currentFilePath && isCppFile(fileSystem.currentFilePath)) {
                    lspClient.documentChanged(fileSystem.currentFilePath, codeEditor.text);
                    var text = codeEditor.getText(0, codeEditor.cursorPosition);
                    if (text.endsWith(".") || text.endsWith("->")) {
                        var textToCursor = codeEditor.getText(0, codeEditor.cursorPosition);
                        var lines = textToCursor.split(/\r?\n/);
                        var line = lines.length - 1;
                        var character = lines[lines.length - 1].length;
                        console.log("Requesting completion at", line, character);
                        lspClient.requestCompletion(fileSystem.currentFilePath, line, character);
                    }
                }
                handleAutoIndent();
            }
            property int savedCursorPosition: 0
            property int previousLength: 0

            TextMetrics {
                id: textMetrics
                font: codeEditor.font
            }

            property bool isIndenting: false
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
            outputArea.text += "❗" + error;
        }
        function onFinished() {
            outputArea.text += "✅ Ready.";
            console.log("Ready");
        }
    }

    Connections {
        target: lspClient
        function onCompletionItems(items) {
            completionModel.clear();
            for (var i = 0; i < items.length; ++i) {
                completionModel.append({
                    "text": items[i]
                });
            }
            if (items.length > 0) {
                completionListView.currentIndex = 0;
                completionPopup.open();
                completionListView.forceActiveFocus();
            }
        }
        function onFormattingResult(result) {
            codeEditor.text = result;
            restoreCursorPosition();
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
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        focus: true
        modal: true

        ListView {
            id: completionListView
            anchors.fill: parent
            model: completionModel
            delegate: ItemDelegate {
                text: model.text
                width: completionPopup.width
                highlighted: ListView.isCurrentItem

                onClicked: {
                    var cursorPos = codeEditor.cursorPosition;
                    var text = codeEditor.text;
                    var textToInsert = model.text.trim();
                    if (textToInsert.endsWith(" const")) {
                        textToInsert = textToInsert.slice(0, -6);
                    }
                    codeEditor.text = text.substring(0, cursorPos) + textToInsert + text.substring(cursorPos);
                    completionPopup.close();
                    codeEditor.cursorPosition = cursorPos + textToInsert.length;
                }
            }

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Up) {
                    completionListView.currentIndex = Math.max(0, completionListView.currentIndex - 1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down) {
                    completionListView.currentIndex = Math.min(completionModel.count - 1, completionListView.currentIndex + 1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Tab) {
                    var item = completionModel.get(completionListView.currentIndex);
                    var cursorPos = codeEditor.cursorPosition;
                    var text = codeEditor.text;
                    var textToInsert = item.text.trim();
                    if (textToInsert.endsWith(" const")) {
                        textToInsert = textToInsert.slice(0, -6);
                    }
                    codeEditor.text = text.substring(0, cursorPos) + textToInsert + text.substring(cursorPos);
                    completionPopup.close();
                    codeEditor.cursorPosition = cursorPos + textToInsert.length;
                    event.accepted = true;
                }
            }
        }
    }
}
