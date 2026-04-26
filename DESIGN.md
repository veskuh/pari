# Design System Document: The Developer's Atelier (Pari)

## 1. Overview & Creative North Star: "The Precision Bench"
This design system rejects the sterile flatness of modern IDEs in favor of a "Developer's Atelier"—a workspace that feels like a physical, high-end machine housing pristine paper documents.

**Creative North Star: The Master Watchmaker's Bench.**
The interface achieve this by contrasting "Machine" elements (brushed metal gradients, recessed wells, and metallic highlights) against "Paper" content areas (the code editor). We use deep inset shadows for the editor area, making the code feel like it is "seated" into a physical tray. Every interactive element is designed to provide physically-accurate tactile feedback.

---

## 2. Architecture: The Modular Atelier

The UI is built using a highly modular component architecture to ensure maintainability and consistency. High-performance logic is handled by specialized C++ models that feed structured data to high-fidelity QML delegates.

### Core Data Engines (C++)
*   **`ProjectSearchModel`**: A background-threaded engine for project-wide search and global replacement, utilizing `QtConcurrent` for non-blocking file scanning.
*   **`GitDiffModel`**: A structured diff parser that transforms raw Git output into distinct objects (File Headers, Hunks, and interactive Code Lines).
*   **`DocumentManager`**: The central orchestrator for file buffers, ensuring UI synchronization across tabs and investigative views.

### QML Directory Structure
*   **`ai/`**: Components for AI interaction and the **`InvestigationPane`** (global search hub).
*   **`app/`**: High-level application shell, logic, and global dialogs.
*   **`buildtools/`**: Build configuration and management interfaces.
*   **`common/`**: Reusable UI primitives (Buttons, Wells, Tab bars).
*   **`editor/`**: Core code editor logic and UI overlays.
*   **`filetree/`**: Project navigation and file system interaction.
*   **`git/`**: Git-specific views, including the structured **`GitDiffView`**.
*   **`settings/`**: Application configuration windows.
*   **`utils/`**: Shared JavaScript utility functions.

### Core Layout Orchestration
*   **`PariAppWindow`**: The primary container that orchestrates the overall workspace.
*   **`AppLogic`**: A dedicated component that manages backend connections and global state transitions.
*   - **`PariActions`**: Centralized action definitions for shortcuts, menus, and toolbars.
*   - **`PariMenuBar` / `PariToolBar`**: Decoupled navigation and command interfaces.

### The "Paper Well" Pattern (`PariPaperWell`)
A reusable container that implements the "recessed" skeuomorphic look. It automatically handles theme-aware background colors, inset shadows, and borders. Used by:
*   `CodeEditorPane`
*   `OutputPane` (AI Output & Diffs)
*   The Build Output panel.

---

## 3. Visual Language: Machine & Surface

### "Machine Bezel" Navigation
Pari uses a specialized horizontal navigation strip at the top of the sidebar and investigative views:
*   **Metallic Surface**: Backgrounds utilize a multi-stop horizontal gradient to simulate brushed aluminium/steel.
*   **Sliding Recessed Well**: Active selections are signaled by a "recessed indicator"—a darker, inner-shadowed "well" that slides behind the active item using `SmoothedAnimation`.
*   **Mechanical Seams**: Etched dividers (a dark 1px line paired with a 1px light highlight) separate machine components from content areas.

### Custom UI Primitives
*   **`PariButton`**: A skeuomorphic button supporting raised/depressed states and custom icons.
*   **`PariToolButton`**: A premium compact button optimized for toolbars.
    *   **Micro-Bevels**: 1px "light-catcher" (top) and 1px "casting-shadow" (bottom) for 3D depth.
    *   **Absolute Centering**: Icons/labels use an internal absolute centering pattern to bypass native style offsets.
    *   **Tactile Feedback**: Soft hover glows, radial-like curvature overlays when pressed, and mechanical scaling (`scale: 0.95`).
*   **`PariTabBar`**: A custom tab interface with sliding indicators for document navigation.

---

## 4. Colors & Surface Logic

### Theme-Aware Palette
The system supports full **Light** and **Dark** modes. All components must utilize the `PariTheme` constants to ensure visual consistency.

*   **Paper Background:** `#ffffff` (Light) / `#1a1a1a` (Dark).
*   **Dirty State (Drafting):** Transitions to `#fffdf0` (Cream) / `#1e2538` (Navy) to signal unsaved changes.
*   **Bezels & Machine:** Neutral greys with metallic gradients.
*   **Global Access:** Components should use the `pariTheme` instance or a safe fallback pattern for testability.

---

## 5. Components & Interactive Hubs

### Inkwell Editor (`CodeEditorPane`)
*   **Tactile Feedback:** The background color shifts based on the "Dirty" state.
*   **Line Navigation:** Integrated `LineNumberGutter` with active line highlighting and non-sequential mapping support.
*   **Search & Filter:** Integrated `FindOverlay` with **Grep Mode** (⏳) for isolating lines while preserving original numbering.
*   **Extended Syntax Support:** High-fidelity highlighting for C++, QML, Markdown, Shell, Swift, and JavaScript.

### Global Investigation (`InvestigationPane`)
*   **Ergonomic Layout**: Maximized horizontal width for search inputs, with collapsible "Replace" rows.
*   **Search Options**: Standard `CheckBox` controls with descriptive labels for Regex and Match Case.

### Atelier Diff Bench (`GitDiffView`)
*   **"Blueprint Card" Headers**: File paths are presented on substantial, metallic title cards.
*   **The Tactile Gutter**: A vertical strip for original/new line numbers and color-coded change indicators.
*   **Workspace Status Awareness**: Integrates untracked files badged as **"NEW"** at the top of the bench.
*   **The Interactive Portal**: Every line is a portal; clicking jumps the editor to the exact line via absolute path resolution.

### Build & Run
*   **Command Center**: Proportional bottom pane for build output.
*   **Navigable Errors**: File paths in output are automatically linked to the editor.

---

## 6. Engineering Standards

*   **Declarative Logic**: Prefer QML bindings and property-driven state over manual assignments.
*   **Zero-Warning Policy**: Native controls must use the "Background Sibling" pattern to avoid `background` override warnings.
*   **Persistence**: Investigative windows must remember their geometry and spawn relative to the main workbench.
*   - **Testability**: All components should be verifyable via `tst_*.qml` using mocks for global context.
*   - **Tacile Feedback**: Every interactive element must provide tactile feedback (raised vs. depressed states).
