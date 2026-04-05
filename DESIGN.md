# Design System Document: The Developer's Atelier (Pari)

## 1. Overview & Creative North Star: "The Precision Bench"
This design system rejects the sterile flatness of modern IDEs in favor of a "Developer's Atelier"—a workspace that feels like a physical, high-end machine housing pristine paper documents. We are capturing the peak of the "Unified" era (circa 2012), where UI felt tactile, heavy, and intentional.

**Creative North Star: The Master Watchmaker's Bench.**
The interface is not just a software window; it is a professional appliance for precision engineering. We achieve this by contrasting "Machine" elements (gradients, recessed wells, and metallic highlights) against "Paper" content areas (the code editor). We break the standard grid by using deep inset shadows for the editor area, making the code feel like it is "seated" into a physical tray.

---

## 2. Colors & Surface Logic
Our palette relies on the sophisticated interplay of neutral greys and high-energy blue accents for active states.

### The "No-Line" Rule
Prohibit 1px solid borders for sectioning. Structural separation is achieved through **Surface Hierarchy** and tonal shifts. For example, the File Tree sits flush against the Editor well without a stroke; the depth is created by the transition from a "recessed" well to a "raised" bezel.

### Surface Hierarchy & Nesting
*   **The Canvas (Base):** Use `surface_dim` with a subtle linen texture overlay for the outermost application background.
*   **The Machine (Sidebars/Toolbars):** Use `surface_container_high` (#e8e8e8) for the File Tree and `surface_container_highest` (#e2e2e2) for toolbars and status bars.
*   **The Paper (The Editor):** Use `surface_container_lowest` (#ffffff) for the code editor. This must always appear "recessed" into the machine using an inner shadow.

### The "Glass & Gradient" Rule
Standard flat colors are forbidden for functional elements.
*   **Toolbars:** Must use a linear gradient from `surface_bright` to `surface_container_high` with a `1px` top highlight of `inverse_on_surface` (100% white) to simulate a light-catching edge.
*   **Dark Mode Toolbars:** Transition to a deep charcoal gradient (#3c3c3c to #2d2d2d) with a subtle #505050 top highlight.
*   **Primary Actions (Build/Run):** Use a gradient from `primary` (#0051a6) to `primary_container` (#0069d3).

---

## 3. Typography: The System Editorial
We use **Public Sans** for the interface and **Menlo** for the technical instruments.

*   **Labels (The Interface):** Centered beneath icons, these use `on_secondary_container` (#646464) to distinguish "interface" text from "code" text.
*   **Monospace (The Instrument):** Use **Menlo** for the Code Editor, Terminal, and LCD readouts.

---

## 4. Components

### Toolbars (`PariToolBar`)
*   **Dimensions:** Fixed at 64px height.
*   **Layout:** Features a 4px vertical "breathing room" (padding) at the top and bottom.
*   **Skeuomorphism:** Uses a dual-stop vertical gradient and a 1px metallic top highlight to catch the light.

### Buttons (`PariToolButton`)
*   **Dimensions:** 56px x 56px, ensuring they remain vertically centered within the 64px toolbar.
*   **Push-Style:** Gradient with 4px rounded corners. Use `inset` shadow on `:active` and `:checked` states to simulate a physical "pressed" state.
*   **Status Colors:**
    *   **Primary (Optional):** Blue gradients for high-energy actions.
    *   **Machine (Default):** Grey/Charcoal gradients that blend into the toolbar bezel.
    *   **Checked State:** Transition to a depressed inset state with a highlighted label color (#0051a6 in light mode, #4aa9ff in dark mode).

### Status Bar (`CustomStatusBar`)
*   **Dimensions:** Fixed at 24px height.
*   **Skeuomorphism:** Uses a vertical gradient and a 1px top highlight for depth.
*   **LCD Readouts:** Functional information (Git branch, LLM model, Status) is housed in recessed "wells" with Menlo typography to simulate physical LCD displays.

### File Tree (Source Selection)
*   **Aesthetics:** The sidebar uses tonal shifts to appear slightly recessed from the toolbar bezel.
*   **Progressive Depth:** Uses subtle vertical "etched" lines and 16px indentation per level to show hierarchy.
*   **Iconography:** Features high-fidelity 3D iconography. Folders use a "Manila" metaphor (Open vs. Closed).
*   **Selection & Hover:**
    *   **Hover:** A subtle "raised bezel" effect (light top border, soft bottom shadow).
    *   **Active File:** Vibrant blue gradient (#0069d3 to #0051a6) with white text and a light-catching top edge.
*   **State LEDs:** Small, glowing circular indicators next to filenames:
    *   **Amber LED:** File has unsaved changes.
    *   **Green LED:** New/Untracked file.
    *   **Yellow LED:** Modified file.

### Inkwell Editor (v1)
*   **Aesthetics:** The editor background transitions to a warm Creamy finish (`#fffdf0`) in light mode or a Blueprint Navy (`#1e2538`) in dark mode when a file is "Dirty" (has unsaved changes) to signify an active drafting state.
*   **Skeuomorphism:** The editor is recessed into the machine using an outer bezel and inner shadow.
*   **Line Numbers:** Housed in a metallic column with high-contrast active line highlighting.
*   **Word Wrap:** Enabled by default to ensure no horizontal scrolling is required.

### Empty Editor State ("The Prepared Tray")
*   **Aesthetics:** When no documents are open, the "Machine Base" is revealed (#e8e8e8 in light, #1a1a1a in dark).
*   **Engraved Mark:** A large, centered "PARI" logo appears engraved into the surface.
*   **Action Cards:** Skeuomorphic "paper scraps" sit in the tray for primary actions (Open Folder, etc.), providing tactile entry points for the user.

### Syntax Highlighting
*   **Engine:** Centralized in `SyntaxHighlighterProvider` for global consistency.
*   **Palette:** Precision-tuned for high legibility on "Paper" wells. Use classic editorial colors (Deep Blue, Maroon, Forest Green).

---

## 5. Development Status Indicators
*   **Purpose:** Provide immediate visual feedback on the state of the local workspace relative to the project root and Git.
*   **Iconography:**
    *   ✅ **(In Sync):** File saved and Git status clean.
    *   ⬆️ **(Unsaved/Uncommitted):** Local changes waiting to be saved or committed.
    *   ✨ **(AI Thinking):** The LLM is actively processing a request.

---

## 6. Interactive Operations

The IDE is designed as an investigative tool for code, not just a text box.

*   **Surgical Refactoring:** AI-driven changes are presented as explicit actions. Use context menus or high-contrast action buttons in the "AI Pane."
*   **Command Center:** The "Output Pane" utilizes a standard skeuomorphic well with Menlo typography for terminal-like feedback.
*   **Drill-Down:** Clicking a file path in the build output triggers an immediate "Jump to Line" action in the Editor.

---

## 7. Three-Tier Backend Architecture

The application is engineered for maintainability and technical isolation using a specialized three-tier backend system.

*   **The Facade (`DocumentManager`):** The primary orchestrator. It manages the lifecycle of open documents and provides a clean API for the QML frontend.
*   **Specialized Instruments (`LspClient` / `BuildManager` / `Llm`):** Dedicated engines for language intelligence, compilation, and AI operations.
*   **Isolated Backends (`FileSystem` / `GitManager` / `Settings`):** Stateless abstraction layers for file system, version control, and configuration.

---

## 8. Self-Test & Verification Architecture

The project maintains a rigorous quality standard through automated testing and coverage measurement.

*   **Unit Testing:** Core C++ components are verified using the Qt Test framework. Integration with external services (like Ollama) is facilitated through localized mocks (e.g., `MockOllamaServer`) to ensure deterministic results.
*   **Code Coverage:** The project maintains a target of **80% weighted average coverage** across all `.cpp` files in the `src/` directory. Coverage is measured using `gcov` and `lcov`.
*   **Smoke Testing:** The system supports a `--selfcheck` CLI argument for validating the integrity of the QML engine and primary interface initialization.
*   **Automation:** A dedicated `scripts/coverage_report.sh` script automates the full profiling cycle, generating both terminal summaries and visual HTML reports.

---

## 9. Signature Interaction: The "Press"
Every interactive element must provide tactile feedback. When a user clicks a button or a sidebar item, it should transition from a drop-shadow (raised) to an inset-shadow (depressed). This 1:1 physical metaphor is the core of the user's trust in the "Precision Bench."
