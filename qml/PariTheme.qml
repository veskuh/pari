import QtQuick

QtObject {
    id: root
    
    readonly property bool isDark: (typeof appSettings !== 'undefined' && appSettings !== null && appSettings.systemThemeIsDark !== undefined) ? appSettings.systemThemeIsDark : false

    // --- Colors: Surfaces ---
    readonly property color sidebarBg: isDark ? "#252525" : "#D6DDE5"
    readonly property color sidebarBorder: isDark ? "#333333" : "#A6ABB2"
    readonly property color editorBg: isDark ? "#1a1a1a" : "#ffffff"
    readonly property color editorBgDirty: isDark ? "#1e2538" : "#fffdf0"
    readonly property color editorBorder: isDark ? "#121212" : "#bcbcbc"
    readonly property color windowBg: isDark ? "#1e1e1e" : "#f0f0f0"
    
    // --- Colors: Text ---
    readonly property color textColor: isDark ? "#d0d0d0" : "#1a1c1c"
    readonly property color textColorMuted: isDark ? "#888888" : "#666666"
    readonly property color textColorDim: isDark ? "#aaaaaa" : "#555555"
    readonly property color textColorInverse: "#ffffff"
    readonly property color accentColor: isDark ? "#4a9eff" : "#0078d7"

    // --- Colors: Buttons (Light Theme) ---
    readonly property color btnLightTop: "#f0f0f0"
    readonly property color btnLightBottom: "#cccccc"
    readonly property color btnLightBorder: "#9b9b9b"
    readonly property color btnLightPrimaryTop: "#3b99fc"
    readonly property color btnLightPrimaryBottom: "#0078d7"
    
    // --- Colors: Buttons (Dark Theme) ---
    readonly property color btnDarkTop: "#3c3c3c"
    readonly property color btnDarkBottom: "#252525"
    readonly property color btnDarkBorder: "#111111"
    readonly property color btnDarkPrimaryTop: "#1a6ac3"
    readonly property color btnDarkPrimaryBottom: "#0d4d92"

    // --- Metrics: Paddings & Margins ---
    readonly property real paddingSmall: 4
    readonly property real paddingMedium: 8
    readonly property real paddingLarge: 12
    readonly property real marginStandard: 10
    readonly property real borderRadius: 4
    
    // --- Fonts ---
    readonly property string monoFont: (typeof appSettings !== 'undefined' && appSettings && appSettings.fontFamily) ? appSettings.fontFamily : (Qt.platform.os === 'osx' ? "Menlo" : "monospace")
    readonly property int fontSize: (typeof appSettings !== 'undefined' && appSettings && appSettings.fontSize) ? appSettings.fontSize : 12
    
    // Classic macOS hierarchy: 11pt for toolbar/small, 13pt for standard buttons
    readonly property int fontToolbar: 11
    readonly property int fontButton: 13
    readonly property int fontSizeSmall: fontSize - 1
    readonly property int fontSizeLarge: fontSize + 2
}
