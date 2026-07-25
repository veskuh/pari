# Design System Document: The Developer's Atelier (Pari)

## 1. Overview & Creative North Star: "The Precision Bench"
This design system rejects the sterile flatness of modern IDEs in favor of a "Developer's Atelier"—a workspace that feels like a physical, high-end machine housing pristine paper documents.

**Creative North Star: The Master Watchmaker's Bench.**
The interface achieves this by adopting the classic macOS Yosemite–Catalina aesthetic via the [Kaakao](https://github.com/veskuh/Kaakao) component toolkit, contrasting "Machine" elements (brushed metal gradients, recessed wells, and metallic highlights) against "Paper" content areas (the code editor). We use deep inset shadows for the editor area (`PariPaperWell`), making the code feel like it is "seated" into a physical tray. Every interactive element provides physically-accurate tactile feedback.

---

## 2. Architecture: Kaakao-Based Atelier

The UI is built on the Kaakao component library (`Kaakao` QML module), using Kaakao's controls for standard UI primitives and application chrome while reserving custom components for Pari-specific workspace requirements.

### Core Data Engines (C++)
*   **`ProjectSearchModel`**: A background-threaded engine for project-wide search and global replacement, utilizing `QtConcurrent` for non-blocking file scanning.
*   **`GitDiffModel`**: A structured diff parser that transforms raw Git output into distinct objects (File Headers, Hunks, and interactive Code Lines).
*   **`DocumentManager`**: The central orchestrator for file buffers, ensuring UI synchronization across tabs and investigative views.

### QML Directory Structure & Control Hierarchy
*   **`Kaakao` Module Integration**:
    *   **App Chrome & Layout:** `KaakaoWindow`, `KaakaoToolBar`, `KaakaoStatusBar`, `KaakaoSplitView`, `KaakaoMenu`, `KaakaoMenuItem`, `KaakaoMenuSeparator`.
    *   **Navigation & Tabs:** `KaakaoTabBar`, `KaakaoTabButton`, `KaakaoSegmentedControl`.
    *   **Controls:** `KaakaoButton`, `KaakaoToolButton`, `KaakaoTextField`, `KaakaoSearchField`, `KaakaoCheckBox`, `KaakaoComboBox`, `KaakaoProgressBar`, `KaakaoBusyIndicator`, `KaakaoDialog`, `KaakaoLabel`, `KaakaoToolTip`, `KaakaoTextArea`.
*   **Pari Custom Controls (`common/`, `app/`):**
    *   **`PariTheme`**: Theme facade mapping pari constants to Kaakao's `Theme` singleton (`Theme.isDarkMode`, `Theme.contentBackground`, `Theme.textFieldBorder`, `Theme.primaryAccent`, etc.).
    *   **`PariPaperWell`**: Atelier recessed container; colors and inner shadow sourced directly from `Theme.contentBackground` and `Theme.textFieldInnerShadow`.
    *   **`ColorButton`**: Custom color swatch button rebuilt on top of `KaakaoButton`.
*   **Composite Views (`editor/`, `sidebar/`, `git/`, `ai/`):**
    *   `CodeEditorPane`, `LineNumberGutter`, `FindOverlay`, `GitDiffView`, `GlobalSearchPane`, `BuildOutputPanel`.

### Core Layout Orchestration
*   **`PariAppWindow`**: Built on `KaakaoWindow` and `KaakaoSplitView` for responsive, resizable workspace partitioning.
*   **`AppLogic`**: Manages backend connections, file loading, and global state transitions.
*   **`PariActions`**: Centralized action definitions for shortcuts, menus, and toolbars.
*   **`PariMenuBar` / `PariToolBar`**: Application header and command interfaces using Kaakao menu and toolbar components.

---

## 3. Visual Language: Machine & Surface

### Kaakao Design Base
Pari leverages Kaakao for macOS Yosemite–Catalina visual styling across controls:
*   **Metallic Surface**: Window headers, status bars, and segmented controls feature multi-stop vertical gradients simulating brushed aluminium/steel.
*   **Segmented Controls & Tab Strips**: Sidebar tabs use `KaakaoSegmentedControl` with animated selection indicators; document tabs use raised `KaakaoTabBar` / `KaakaoTabButton` components merging into the content area.
*   **Sunken Wells**: Text fields and code wells utilize Kaakao's 1px border and top inner shadow for tactile depth.

### Surviving Custom UI Primitives
*   **`PariPaperWell`**: A recessed container for code and output panes, with theme-derived background colors (`Theme.contentBackground`) and inner shadow (`Theme.textFieldInnerShadow`).
*   **`ColorButton`**: Built on `KaakaoButton`, providing color swatch selection for syntax and theme settings.

---

## 4. Colors & Surface Logic

### Theme Facade (`PariTheme`)
All Pari controls source styling from `PariTheme` or directly from Kaakao's `Theme` singleton:
*   **Theme Mode:** `PariTheme` binds Kaakao's `Theme.themeMode` to `appSettings.systemThemeIsDark` (`Theme.Dark` / `Theme.Light`).
*   **Paper Background:** `Theme.contentBackground` (`#ffffff` Light / `#252525` Dark).
*   **Dirty State:** `editorBgDirty` (`#fffdf0` Cream / `#1e2538` Navy) signals unsaved changes.
*   **Text & Accents:** `Theme.primaryText`, `Theme.secondaryText`, `Theme.primaryAccent`.

---

## 5. Engineering Standards

*   **Kaakao Control Standard**: Stock Qt Quick controls (`Button`, `TextField`, `CheckBox`, `ComboBox`, `Dialog`, `Label`, `MenuBar`, `SplitView`) are replaced with Kaakao equivalents.
*   **Declarative Logic**: Prefer QML bindings and property-driven state over manual assignments.
*   **Zero-Warning Policy**: Controls follow standard QML styling conventions without override warnings.
*   **Testability**: UI components are verified via `tst_*.qml` using mocks for global context.
