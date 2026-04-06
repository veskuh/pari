import QtQuick

QtObject {
    id: searchManager
    
    property var editor: null
    property var overlay: null

    // Callback for positioning the view (optional)
    property var positionCallback: null

    function findNext() {
        if (!editor || !overlay) return;
        
        var searchText = overlay.searchText;
        if (searchText === "") return;

        var newPos = editor.text.indexOf(searchText, editor.cursorPosition);

        if (newPos !== -1) {
            editor.cursorPosition = newPos + searchText.length;
            editor.select(newPos, newPos + searchText.length);
            if (positionCallback) {
                positionCallback(newPos);
            }
        }
        updateResults();
    }

    function findPrevious() {
        if (!editor || !overlay) return;
        
        var searchText = overlay.searchText;
        if (searchText === "") return;

        var newPos = editor.text.lastIndexOf(searchText, editor.cursorPosition - (searchText.length + 1));

        if (editor.cursorPosition === newPos) {
            newPos = editor.text.lastIndexOf(searchText, editor.cursorPosition - (searchText.length + 1));
        }

        if (newPos !== -1) {
            editor.cursorPosition = newPos + searchText.length;
            editor.select(newPos, newPos + searchText.length);
            if (positionCallback) {
                positionCallback(newPos);
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
        var occurrences = editor.text.split(searchText).length - 1;
        overlay.updateResults(occurrences);
    }
}
