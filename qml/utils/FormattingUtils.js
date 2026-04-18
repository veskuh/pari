.pragma library

function formatOutput(text, fileSystem) {
    if (!text) return "";
    var lines = text.split('\n');
    var formattedText = "";
    var pathRegex = /([\w/.-]+)(?::(\d+))?(?::(\d+))?/g;

    for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        var result = "";
        var lastIndex = 0;
        var match;
        pathRegex.lastIndex = 0; // Reset regex state
        while ((match = pathRegex.exec(line)) !== null) {
            if (fileSystem.fileExistsInProject(match[1])) {
                var filePath = match[1];
                var lineNumber = match[2] ? match[2] : -1;
                var link = filePath + ":" + lineNumber;
                result += line.substring(lastIndex, match.index);
                result += `[${match[0]}](${link})`;
                lastIndex = match.index + match[0].length;
            }
        }
        if (lastIndex === 0) {
            result = line;
        } else {
            result += line.substring(lastIndex);
        }
        formattedText += result;
        if (i < lines.length - 1) {
            formattedText += '\n';
        }
    }
    return formattedText;
}
