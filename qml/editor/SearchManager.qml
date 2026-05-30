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
                var useRegex = overlay.useRegex;
                
                var regex = null;
                if (useRegex) {
                    try {
                        regex = new RegExp(pattern, matchCase ? "" : "i");
                    } catch (e) {
                        filteredLineNumbers = [];
                        if (editor.text !== "") {
                            editor.text = "";
                        }
                        updateResults();
                        return;
                    }
                }
                
                var searchPattern = matchCase ? pattern : pattern.toLowerCase();

                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i];
                    if (useRegex) {
                        if (regex && regex.test(line)) {
                            result.push(line);
                            lineNums.push(i + 1);
                        }
                    } else {
                        var textToMatch = matchCase ? line : line.toLowerCase();
                        if (textToMatch.indexOf(searchPattern) !== -1) {
                            result.push(line);
                            lineNums.push(i + 1);
                        }
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
        function onUseRegexChanged() {
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

    Connections {
        target: editor
        ignoreUnknownSignals: true
        function onSelectionStartChanged() {
            searchManager.updateResults();
        }
        function onSelectionEndChanged() {
            searchManager.updateResults();
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
        var useRegex = overlay.useRegex;
        
        var result = textDocumentSearcher.find(editor.textDocument, searchText, startPos, options, useRegex);
        var pos = result.position;
        
        if (pos !== -1) {
            var start = result.start;
            var end = result.end;
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
        var useRegex = overlay.useRegex;
        
        var result = textDocumentSearcher.find(editor.textDocument, searchText, startPos, options, useRegex);
        var pos = result.position;
        
        if (pos !== -1) {
            var start = result.start;
            var end = result.end;
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
            var match = false;
            if (overlay.useRegex) {
                try {
                    var re = new RegExp("^" + searchText + "$", overlay.matchCase ? "" : "i");
                    match = re.test(selectedText);
                } catch (e) {
                    match = false;
                }
            } else {
                match = overlay.matchCase ? (selectedText === searchText) : (selectedText.toLowerCase() === searchText.toLowerCase());
            }
            
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
        if (overlay.useRegex) {
            try {
                var re = new RegExp(searchText, overlay.matchCase ? "g" : "gi");
                newContent = content.replace(re, replaceText);
            } catch (e) {
                return;
            }
        } else {
            if (overlay.matchCase) {
                newContent = content.split(searchText).join(replaceText);
            } else {
                var escapedSearch = searchText.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                var re = new RegExp(escapedSearch, "gi");
                newContent = content.replace(re, replaceText);
            }
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
            overlay.currentMatchIndex = -1;
            overlay.totalMatches = 0;
            overlay.updateResults(0);
            return;
        }
        
        if (filterActive) {
            overlay.currentMatchIndex = -1;
            overlay.totalMatches = filteredLineNumbers.length;
            overlay.updateResults(filteredLineNumbers.length);
        } else {
            var text = editor.text;
            var ranges = [];
            
            if (overlay.useRegex) {
                try {
                    var re = new RegExp(searchText, overlay.matchCase ? "g" : "gi");
                    var match;
                    while ((match = re.exec(text)) !== null) {
                        ranges.push({ start: match.index, end: re.lastIndex });
                        if (re.lastIndex === match.index) {
                            re.lastIndex++; // Prevent infinite loop on empty match
                        }
                    }
                } catch (e) {
                    ranges = [];
                }
            } else {
                var pos = 0;
                var searchPattern = overlay.matchCase ? searchText : searchText.toLowerCase();
                var textToSearch = overlay.matchCase ? text : text.toLowerCase();
                
                while ((pos = textToSearch.indexOf(searchPattern, pos)) !== -1) {
                    ranges.push({ start: pos, end: pos + searchPattern.length });
                    pos += searchPattern.length;
                }
            }
            
            // Find current match index
            var currentIdx = -1;
            var selStart = editor.selectionStart;
            var selEnd = editor.selectionEnd;
            for (var i = 0; i < ranges.length; i++) {
                if (ranges[i].start === selStart && ranges[i].end === selEnd) {
                    currentIdx = i;
                    break;
                }
            }
            
            overlay.currentMatchIndex = currentIdx;
            overlay.totalMatches = ranges.length;
            
            if (currentIdx !== -1) {
                overlay.updateResults((currentIdx + 1) + " of " + ranges.length);
            } else {
                overlay.updateResults(ranges.length);
            }
        }
    }
}
