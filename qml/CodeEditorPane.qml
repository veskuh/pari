import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import net.veskuh.pari 1.0

ColumnLayout {
    property alias text: codeEditor.text
    property alias selection: codeEditor.selectedText
    property alias textDocument: codeEditor.textDocument
    property int cursorPosition: 0
    property real scrollY: 0
    property bool dirty: false

    TextDocumentSearcher {
        id: textDocumentSearcher
    }

    function saveCursorPosition() {
        cursorPosition = codeEditor.cursorPosition;
    }

    function restoreCursorPosition() {
        codeEditor.cursorPosition = cursorPosition;
    }

    function saveScrollPosition() {
        scrollY = codeEditorFlickable.contentY;
    }

    function restoreScrollPosition() {
        codeEditorFlickable.contentY = scrollY;
    }

    function find() {
        findOverlay.open();
    }

    function format() {
        saveScrollPosition();
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

    signal showBuildPanelRequested()

    function showBuildPanel() {
        showBuildPanelRequested();
    }

    Label {
        text: titleBase + editedAppendix
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 5
        Layout.bottomMargin: 5
        property string titleBase: fileSystem.currentFilePath ? fileSystem.currentFilePath : qsTr("📝 Code Editor")
        property string editedAppendix: dirty ? " - ✏️ Edited" : ""
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

        Flickable {
            id: codeEditorFlickable
            clip: true
            contentHeight: codeEditor.contentHeight
            TextArea {
                id: codeEditor
                width: codeEditorFlickable.width
                height: contentHeight
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
                    if (codeEditor.activeFocus && codeEditor.length !== previousLength) {
                        // Not just a formatting change
                        dirty = true;
                    }

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
    }



    Connections {
        target: lspClient

        function onFormattingResult(result) {
            codeEditor.text = result;
            restoreCursorPosition();
            restoreScrollPosition();
        }
    }

    CompletionPopup {
        id: completionPopup
        width: 200
        height: 300
        y: codeEditor.cursorRectangle.y + codeEditor.cursorRectangle.height
        x: codeEditor.cursorRectangle.x
    }
}
