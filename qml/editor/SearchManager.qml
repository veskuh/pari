import QtQuick

Item {
    id: searchManager
    
    property var editor: null
    property var pane: null
    property var overlay: null

    // Callback for positioning the view (optional)
    property var positionCallback: null

    property bool filterActive: overlay ? overlay.filterActive : false
    property string originalText: ""
    property var filteredLineNumbers: []
    
    // THE SESSION ANCHOR: Stays stable during typing refinements
    property int sessionStartPosition: 0

    function applyFilter() {
        if (!editor || !overlay) return;
        
        if (filterActive) {
            if (originalText === "") {
                originalText = editor.text;
            }
            
            var pattern = overlay.searchText;
            if (pattern === "") {
                filteredLineNumbers = [];
                if (editor.text !== originalText) {
                    editor.text = originalText;
                }
                editor.readOnly = false;
            } else {
                var lines = originalText.split('\n');
                var result = [];
                var lineNums = [];
                var matchCase = overlay.matchCase;
                
                var searchPattern = matchCase ? pattern : pattern.toLowerCase();

                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i];
                    var textToMatch = matchCase ? line : line.toLowerCase();
                    if (textToMatch.indexOf(searchPattern) !== -1) {
                        result.push(line);
                        lineNums.push(i + 1);
                    }
                }
                
                filteredLineNumbers = lineNums;
                var filteredText = result.join('\n');
                if (editor.text !== filteredText) {
                    editor.text = filteredText;
                }
                editor.readOnly = true;
            }
        } else {
            if (originalText !== "") {
                var restoreText = originalText;
                originalText = "";
                filteredLineNumbers = [];
                editor.text = restoreText;
            }
            editor.readOnly = false;
        }
        
        if (pane && typeof pane.refreshLineNumbers === 'function') {
            pane.refreshLineNumbers();
        }
        updateResults();
    }

    onFilterActiveChanged: applyFilter()
    
    Connections {
        target: overlay || null
        ignoreUnknownSignals: true
        function onSearchTextChanged() {
            if (searchManager.filterActive) {
                searchManager.applyFilter();
            } else {
                searchManager.findNext(true);
                searchManager.updateResults();
            }
        }
        function onMatchCaseChanged() {
            if (searchManager.filterActive) {
                searchManager.applyFilter();
            } else {
                searchManager.findNext(true);
                searchManager.updateResults();
            }
        }
        function onClosed() {
            if (overlay) overlay.filterActive = false;
            searchManager.applyFilter();
            searchManager.sessionStartPosition = 0;
            if (editor) editor.deselect();
        }
        function onFindNext(isIncremental) {
            searchManager.findNext(isIncremental);
        }
        function onFindPrevious() {
            searchManager.findPrevious();
        }
        function onReplaceNext() {
            searchManager.replaceNext();
        }
        function onReplaceAll() {
            searchManager.replaceAll();
        }
    }

    function findNext(isIncremental) {
        if (!editor || !overlay) return;
        if (filterActive) return;
        
        var searchText = overlay.searchText;
        if (searchText === "") {
            sessionStartPosition = 0;
            if (editor) editor.deselect();
            return;
        }
        
        if (typeof textDocumentSearcher === 'undefined') return;

        var startPos = isIncremental ? sessionStartPosition : editor.cursorPosition;
        var options = overlay.matchCase ? 2 : 0; 
        
        var pos = textDocumentSearcher.find(editor.textDocument, searchText, startPos, options);
        
        if (pos !== -1) {
            var start = pos - searchText.length;
            var end = pos;
            editor.cursorPosition = end;
            editor.select(start, end);
            if (positionCallback) positionCallback(pos);
            
            if (!isIncremental) {
                sessionStartPosition = start;
            }
        }
    }

    function findPrevious() {
        if (!editor || !overlay) return;
        if (filterActive) return;
        
        var searchText = overlay.searchText;
        if (searchText === "") return;
        
        if (typeof textDocumentSearcher === 'undefined') return;

        var startPos = editor.selectionStart;
        var options = (overlay.matchCase ? 2 : 0) | 1; 
        
        var pos = textDocumentSearcher.find(editor.textDocument, searchText, startPos, options);
        
        if (pos !== -1) {
            var start = pos - searchText.length;
            var end = pos;
            editor.cursorPosition = end;
            editor.select(start, end);
            if (positionCallback) positionCallback(start);
            
            sessionStartPosition = start;
        }
    }

    function replaceNext() {
        if (!editor || !overlay || filterActive) return;
        var searchText = overlay.searchText;
        var replaceText = overlay.replaceText;
        if (searchText === "") return;

        if (editor.selectionStart !== editor.selectionEnd) {
            var selectedText = editor.text.substring(editor.selectionStart, editor.selectionEnd);
            var match = overlay.matchCase ? (selectedText === searchText) : (selectedText.toLowerCase() === searchText.toLowerCase());
            
            if (match) {
                var start = editor.selectionStart;
                editor.remove(editor.selectionStart, editor.selectionEnd);
                editor.insert(start, replaceText);
                
                if (pane && typeof pane.textChangedByUser === 'function') {
                    pane.textChangedByUser();
                }
            }
        }
        findNext(false);
    }

    function replaceAll() {
        if (!editor || !overlay || filterActive) return;
        var searchText = overlay.searchText;
        var replaceText = overlay.replaceText;
        if (searchText === "") return;

        var content = editor.text;
        var newContent;
        if (overlay.matchCase) {
            newContent = content.split(searchText).join(replaceText);
        } else {
            var escapedSearch = searchText.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            var re = new RegExp(escapedSearch, "gi");
            newContent = content.replace(re, replaceText);
        }

        if (content !== newContent) {
            editor.text = newContent;
            if (originalText !== "") {
                originalText = newContent;
            }
            
            if (pane && typeof pane.textChangedByUser === 'function') {
                pane.textChangedByUser();
            }
        }
        updateResults();
    }

    function updateResults() {
        if (!editor || !overlay) return;
        var searchText = overlay.searchText;
        if (searchText === "") {
            overlay.updateResults(0);
            return;
        }
        
        if (filterActive) {
            overlay.updateResults(filteredLineNumbers.length);
        } else {
            var count = 0;
            var pos = 0;
            var text = editor.text;
            var searchPattern = overlay.matchCase ? searchText : searchText.toLowerCase();
            var textToSearch = overlay.matchCase ? text : text.toLowerCase();
            
            while ((pos = textToSearch.indexOf(searchPattern, pos)) !== -1) {
                count++;
                pos += searchPattern.length;
            }
            overlay.updateResults(count);
        }
    }
}
