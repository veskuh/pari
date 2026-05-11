.pragma library

function escapeHtml(text) {
    if (!text) return "";
    return text.replace(/&/g, "&amp;")
               .replace(/</g, "&lt;")
               .replace(/>/g, "&gt;")
               .replace(/"/g, "&quot;")
               .replace(/'/g, "&#039;");
}

function formatOutput(text, fileSystem) {
    if (!text) return "";
    var lines = text.split('\n');
    var formattedText = "";
    // Regex for file:line or file:line:column
    var pathRegex = /([\w/.-]+\.\w+):(\d+)(?::(\d+))?/g;

    for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        var result = "";
        var lastIndex = 0;
        var match;
        pathRegex.lastIndex = 0; 
        while ((match = pathRegex.exec(line)) !== null) {
            var potentialPath = match[1];
            if (fileSystem.fileExistsInProject(potentialPath)) {
                var lineNumber = match[2];
                var link = potentialPath + ":" + lineNumber;
                result += escapeHtml(line.substring(lastIndex, match.index));
                result += `<a href="${link}">${escapeHtml(match[0])}</a>`;
                lastIndex = match.index + match[0].length;
            }
        }
        if (lastIndex === 0) {
            result = escapeHtml(line);
        } else {
            result += escapeHtml(line.substring(lastIndex));
        }
        formattedText += result;
        if (i < lines.length - 1) {
            formattedText += '<br/>';
        }
    }
    return formattedText;
}
