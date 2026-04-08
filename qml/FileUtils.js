.pragma library

function isCppFile(filePath) {
    if (!filePath) return false;
    return filePath.endsWith(".cpp") || filePath.endsWith(".h") || filePath.endsWith(".cxx") || filePath.endsWith(".hpp") || filePath.endsWith(".cc") || filePath.endsWith(".hh");
}
