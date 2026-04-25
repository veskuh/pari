# Design System Document: The Developer's Atelier (Pari)

## 1. Overview & Creative North Star: "The Precision Bench"
This design system rejects the sterile flatness of modern IDEs in favor of a "Developer's Atelier"—a workspace that feels like a physical, high-end machine housing pristine paper documents.

**Creative North Star: The Master Watchmaker's Bench.**
The interface achieve this by contrasting "Machine" elements (gradients, recessed wells, and metallic highlights) against "Paper" content areas (the code editor). We use deep inset shadows for the editor area, making the code feel like it is "seated" into a physical tray.

---

## 2. Architecture: The Modular Atelier

The UI is built using a highly modular component architecture to ensure maintainability and consistency. QML components are organized into feature-based subdirectories, each with its own `qmldir` for proper namespacing and resource management.

### QML Directory Structure
*   **`ai/`**: Components for AI interaction (Chat, Thinking indicators, Output panes).
*   **`app/`**: High-level application shell, logic, and global dialogs.
*   **`buildtools/`**: Build configuration and management interfaces.
*   **`common/`**: Reusable UI primitives (Buttons, Wells, Tab bars).
*   **`editor/`**: Core code editor logic and UI overlays.
*   **`filetree/`**: Project navigation and file system interaction.
*   **`git/`**: Git-specific views (Diffs, Logs).
*   **`settings/`**: Application configuration windows.
*   **`utils/`**: Shared JavaScript utility functions.

### Core Layout Orchestration
*   **`PariAppWindow`**: The primary container that orchestrates the overall workspace.
*   **`AppLogic`**: A dedicated component that manages backend connections and global state transitions.
*   **`PariActions`**: Centralized action definitions for shortcuts, menus, and toolbars.
*   **`PariMenuBar` / `PariToolBar`**: Decoupled navigation and command interfaces.

### The "Paper Well" Pattern (`PariPaperWell`)
A reusable container that implements the "recessed" skeuomorphic look. It automatically handles theme-aware background colors, inset shadows, and borders. Used by:
*   `CodeEditorPane`
*   `OutputPane` (AI Output & Diffs)
*   The Build Output panel.

### Custom UI Primitives
*   **`PariButton`**: A skeuomorphic button component that supports raised/depressed states, custom icons, and theme-aware styling.
*   **`PariToolButton`**: A compact version of the button optimized for toolbars.
*   **`PariTabBar`**: A custom tab interface with sliding indicators for document navigation.

---

## 3. Colors & Surface Logic

### Theme-Aware Palette
The system supports full **Light** and **Dark** modes with smooth transitions. All windows, dialogs, and components must utilize the `PariTheme` constants (colors, metrics, and fonts) to ensure visual consistency across the entire application.

*   **Paper Background:** `#ffffff` (Light) / `#1a1a1a` (Dark).
*   **Dirty State (Drafting):** Transitions to `#fffdf0` (Cream) / `#1e2538` (Navy) to signal unsaved changes.
*   **Bezels & Machine:** Neutral greys with metallic gradients.
*   **Global Access:** Components should use the `pariTheme` instance (usually provided by the application shell) or a safe fallback pattern (e.g., `readonly property var _pariTheme: (typeof pariTheme !== 'undefined') ? pariTheme : null`) for testability.

---

## 4. Components & Interactions

### Inkwell Editor (`CodeEditorPane`)
*   **Tactile Feedback:** The background color shifts based on the "Dirty" state.
*   **Line Navigation:** Integrated `LineNumberGutter` with active line highlighting and support for non-sequential mapping.
*   **Search & Filter:** Integrated `FindOverlay` for compact, incremental search and **Grep Mode** (⏳) for isolating lines while preserving original document numbering.
*   **Extended Syntax Support:** High-fidelity highlighting for C++, QML, Markdown, Shell, Swift, and JavaScript.

### Integrated Git & AI Diffs
*   **Git Console (`GitOutputWindow`):** A specialized view for rich-text diffs and commit logs.
*   **AI Sidecar (`OutputPane`):** Displays AI responses alongside suggested changes. Uses `PariReadOnlyTextArea` for consistent rich-text rendering.

### Build & Run
*   **Command Center:** Proportional bottom pane for build output.
*   **Navigable Errors:** File paths in output are automatically linked to the editor.

---

## 5. Development & Testing Standards

*   **Declarative Logic:** Prefer QML bindings and property-driven state over manual assignments.
*   **Testability:** All components should be verifyable via `tst_*.qml` using mocks for global context properties.
*   **Tacile Feedback:** Every interactive element must provide tactile feedback (raised vs. depressed states).
