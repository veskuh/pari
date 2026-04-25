import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"
import "../utils/FileUtils.js" as FileUtils

ColumnLayout {
    id: root
    property alias text: codeEditor.text
    property alias selection: codeEditor.selectedText
    property alias textDocument: codeEditor.textDocument
    property int cursorPosition: 0
    property real scrollY: 0
    property bool dirty: false
    property bool isActivePane: false
    property string filePath: ""

    signal textChangedByUser()

    // Theme helper - uses global appSettings or one from parent scope in tests
    readonly property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null) ? appSettings.systemThemeIsDark : false

    // Dependency injection
    property var injectedLspClient: null

    SearchManager {
        id: searchManager
        editor: codeEditor
        pane: root
        overlay: findOverlay
        positionCallback: (pos) => root.goToPosition(pos)
    }

    EditorLogic {
        id: editorLogic
        editor: codeEditor
        filePath: root.filePath
    }

    Component.onCompleted: {
        updateLspClient();
    }

    onInjectedLspClientChanged: updateLspClient()

    function updateLspClient() {
        if (root.injectedLspClient !== null) {
            editorLogic.lspClient = root.injectedLspClient;
        } else if (typeof lspClient !== 'undefined') {
            editorLogic.lspClient = lspClient;
        } else {
            editorLogic.lspClient = null;
        }
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
        if (filePath) {
            if (filePath.endsWith(".qml")) {
                if (typeof toolManager !== 'undefined') toolManager.indentQmlFile(filePath, codeEditor.text);
            } else if (FileUtils.isCppFile(filePath)) {
                if (typeof lspClient !== 'undefined') lspClient.format(filePath, codeEditor.text);
            }
        }
    }

    function goToPosition(position) {
        var lineRect = codeEditor.positionToRectangle(position);
        var flickableHeight = codeEditorFlickable.height;
        var contentY = lineRect.y - (flickableHeight / 2) + (lineRect.height / 2);
        codeEditorFlickable.contentY = Math.max(0, Math.min(contentY, codeEditorFlickable.contentHeight - flickableHeight));
    }

    function goToLine(lineNumber) {
        console.log("DEBUG-EDITOR: goToLine called for line:", lineNumber);
        var line = Math.max(0, lineNumber - 1);
        var text = codeEditor.text;
        var lines = text.split('\n');
        if (line >= lines.length) {
            return;
        }
        var position = 0;
        for (var i = 0; i < line; i++) {
            position += lines[i].length + 1; // +1 for the newline character
        }

        codeEditor.cursorPosition = position;
        codeEditor.forceActiveFocus();
        goToPosition(position)
    }

    function refreshLineNumbers() {
        lineNumberGutter.refresh(codeEditor);
    }

    FindOverlay {
        id: findOverlay
        z: 10
        width: parent.width
        onCloseOverlay: close()
    }

    PariPaperWell {
        Layout.fillHeight: true
        isDirtyWell: root.dirty
        
        Behavior on color { ColorAnimation { duration: 300 } }

        ScrollView {
            id: codeEditorScrollView
            anchors.fill: parent
            clip: true

            Flickable {
                id: codeEditorFlickable
                clip: true
                contentHeight: Math.max(codeEditor.implicitHeight + 100, codeEditorScrollView.height)

                LineNumberGutter {
                    id: lineNumberGutter
                    objectName: "lineNumberGutter"
                    height: parent.contentHeight
                    isDark: root.isDark
                    editorFont: codeEditor.font
                    currentLineIndex: codeEditor.currentLineIndex
                    searchManager: searchManager
                    z: 1
                }

                TextArea {
                    id: codeEditor
                    objectName: "codeEditor"
                    x: lineNumberGutter.width + 5
                    width: codeEditorScrollView.width - (lineNumberGutter.width + 15)
                    height: implicitHeight
                    placeholderText: qsTr("✏️ Open a file or start typing...")
                    wrapMode: Text.WordWrap
                    font.family: (typeof appSettings !== 'undefined' && appSettings && appSettings.fontFamily) ? appSettings.fontFamily : "Menlo"
                    font.pointSize: (typeof appSettings !== 'undefined' && appSettings && appSettings.fontSize) ? appSettings.fontSize : 12
                    tabStopDistance: (typeof appSettings !== 'undefined' && appSettings) ? appSettings.indentSize * textMetrics.advanceWidth : 4 * textMetrics.advanceWidth
                    color: isDark ? "#d0d0d0" : "#1a1c1c"
                    selectionColor: isDark ? "#00458d" : "#0051a6"
                    selectedTextColor: "#ffffff"
                    topPadding: 10
                    bottomPadding: 50
                    leftPadding: 10
                    rightPadding: 10
                    background: null

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Tab) {
                            event.accepted = true;
                            if (typeof appSettings !== 'undefined' && appSettings.indentWithSpaces) {
                                var spaces = "";
                                for (var i = 0; i < appSettings.indentSize; i++) {
                                    spaces += " ";
                                }
                                codeEditor.insert(codeEditor.cursorPosition, spaces);
                            } else {
                                codeEditor.insert(codeEditor.cursorPosition, "\t");
                            }
                        }
                    }

                    property int previousLength: 0
                    
                    property int currentLineIndex: {
                        var textToCursor = text.substring(0, cursorPosition);
                        return textToCursor.split('\n').length - 1;
                    }

                    onTextChanged: {
                        if (codeEditor.activeFocus && codeEditor.length !== previousLength) {
                            root.textChangedByUser();
                        }
                        
                        if (typeof aiOutputPane !== 'undefined' && aiOutputPane) {
                            aiOutputPane.updateDiff(codeEditor.text);
                        }
                        
                        editorLogic.handleTextChanged();
                        
                        previousLength = codeEditor.length;
                        refreshLineNumbers();
                    }

                    onContentHeightChanged: {
                        refreshLineNumbers();
                    }

                    onCursorRectangleChanged: {
                        if (!codeEditor.activeFocus) return;
                        
                        var cursorY = cursorRectangle.y;
                        var cursorHeight = cursorRectangle.height;
                        var viewY = codeEditorFlickable.contentY;
                        var viewHeight = codeEditorFlickable.height;

                        if (cursorY < viewY) {
                            // Scroll up to show cursor
                            codeEditorFlickable.contentY = cursorY - topPadding;
                        } else if (cursorY + cursorHeight > viewY + viewHeight) {
                            // Scroll down to show cursor
                            codeEditorFlickable.contentY = cursorY + cursorHeight - viewHeight + bottomPadding;
                        }
                    }
                    
                    Component.onCompleted: {
                        refreshLineNumbers();
                    }
                }
            }
        }
    }

    TextMetrics {
        id: textMetrics
        font: codeEditor.font
    }

    Connections {
        target: root.injectedLspClient || (typeof lspClient !== 'undefined' ? lspClient : null)

        function onFormattingResult(result) {
            codeEditor.text = result;
            restoreCursorPosition();
            restoreScrollPosition();
            refreshLineNumbers();
        }

        function onCompletionItems(items) {
            if (isActivePane) {
                completionPopup.showCompletions(items);
            }
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
