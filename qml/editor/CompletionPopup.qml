import QtQuick
import QtQuick.Controls

Popup {
    id: completionPopup

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    focus: true
    modal: true

    property string typedCharacters: ""

    onVisibleChanged: {
        typedCharacters = "";
    }

    function showCompletions(items) {
        completionModel.clear();
        for (var i = 0; i < items.length; ++i) {
            completionModel.append({
                "text": items[i]
            });
        }

        if (items.length > 0) {
            completionListView.currentIndex = 0;
            completionPopup.open();
            filteredDisplayModel.updateFilter(); // Call updateFilter explicitly when popup opens
            completionListView.forceActiveFocus();
        }
    }

    ListModel {
        id: completionModel
    }

    ListView {
        id: completionListView
        anchors.fill: parent
        model: ListModel { // This will be the filtered model
            id: filteredDisplayModel // Renamed to avoid confusion with original completionModel

            // Function to update the filtered model based on completionModel and typedCharacters
            function updateFilter() {
                filteredDisplayModel.clear();
                var sourceItems = completionModel; // Reference the original completionModel
                for (var i = 0; i < sourceItems.count; ++i) {
                    var itemText = sourceItems.get(i).text.trim().toLowerCase();

                    if (itemText.startsWith(completionPopup.typedCharacters.toLowerCase())) {
                        filteredDisplayModel.append({
                            "text": sourceItems.get(i).text.trim()
                        });
                    }
                }
                // Sort the filtered items (alphabetical order)
                filteredDisplayModel.sort(Qt.CaseInsensitive);
            }
        }

        // Connect to typedCharactersChanged to re-filter
        Connections {
            target: completionPopup
            function onTypedCharactersChanged() {
                filteredDisplayModel.updateFilter();
                if (filteredDisplayModel.count > 0) {
                    completionListView.currentIndex = 0;
                }
            }
        }
        delegate: ItemDelegate {
            width: completionPopup.width - 10
            highlighted: ListView.isCurrentItem

            property string base: model && model.text ? model.text.trim() : ""
            text: '<b>' + completionPopup.typedCharacters + '</b>' + base.substring(completionPopup.typedCharacters.length)

            onClicked: {
                var textToInsert = model.text.trim();
                if (textToInsert.endsWith(" const")) {
                    textToInsert = textToInsert.slice(0, -6);
                }
                var cursorPos = codeEditor.cursorPosition;

                codeEditor.text = codeEditor.text.substring(0, cursorPos) + textToInsert + codeEditor.text.substring(cursorPos);
                codeEditor.cursorPosition = cursorPos + textToInsert.length;
                completionPopup.close();
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Up) {
                completionListView.currentIndex = Math.max(0, completionListView.currentIndex - 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                completionListView.currentIndex = Math.min(filteredDisplayModel.count - 1, completionListView.currentIndex + 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Tab) {
                var item = filteredDisplayModel.get(completionListView.currentIndex);
                var cursorPos = codeEditor.cursorPosition;
                var text = codeEditor.text;
                var textToInsert = item.text.trim();
                if (textToInsert.endsWith(" const")) {
                    textToInsert = textToInsert.slice(0, -6);
                }
                codeEditor.text = text.substring(0, cursorPos) + textToInsert + text.substring(cursorPos);
                codeEditor.cursorPosition = cursorPos + textToInsert.length;
                completionPopup.close();
                event.accepted = true;
            } else if (event.key === Qt.Key_Backspace) {
                if (completionPopup.typedCharacters.length > 0) {
                    completionPopup.typedCharacters = completionPopup.typedCharacters.slice(0, -1);
                }
                event.accepted = true;
            } else if (event.text.length > 0 && event.text.match(/^[a-zA-Z0-9_]$/)) {
                // Only accept alphanumeric and underscore
                completionPopup.typedCharacters += event.text;
                event.accepted = true;
            } else {
                event.accepted = false; // Do not accept other keys, let them propagate
            }
        }
    }
}
