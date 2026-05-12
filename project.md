# Pari: Your Local AI Coding Companion

## Completed Features

*   **Modular Architecture:** Refactored into a clean, component-based structure (`AppLogic`, `PariActions`, etc.).
*   **Intelligent UI:** Resizable panes using `SplitView`, togglable sidebars, and proportional layouts.
*   **Local AI Power:** Full streaming integration with Ollama for real-time responses.
*   **Contextual AI:** Automatic injection of file content and user selection into prompts.
*   **Visual Diffs:** Integrated diff view for AI-suggested changes.
*   **Integrated Git & Workspace Status:** High-fidelity structured diffs with precision navigation and "Atelier Workspace Status" for untracked files.
*   **Build System:** Configurable build/run/clean commands with clickable error navigation.
*   **Advanced Search:** Integrated incremental search and **Grep-like line filtering** with original document numbering.
*   **Project-Wide Investigation:** Background-threaded search and global replacement engine across the entire codebase.
*   **Multi-Language:** Precision syntax highlighting for **C++, Go, Java, JavaScript, Kotlin, Markdown, QML, Rust, Shell, and Swift**.
*   **Skeuomorphic Design:** Tactile "Precision Bench" design with "Machine Bezel" top-tab navigation and premium tactile refinements.
*   **Quality First:** Robust test suite with **350+ tests** and **85.7%** line coverage.

## Current Architecture

*   **Frontend:** QML with a modular component system and high-fidelity skeuomorphic refinements.
*   **Backend Facade (`DocumentManager`):** Central orchestrator for document lifecycles and state.
*   **Engines:** 
    *   `ProjectSearchModel`: High-performance, background-threaded project-wide search engine.
    *   `GitDiffModel`: Structured diff parser for high-fidelity investigation.
    *   `Llm`: Streaming Ollama integration.

## Development & Testing

### Running Tests
```bash
# C++ Unit Tests (204 tests)
./build/tests/tst_all

# QML UI Tests (147 tests)
./build/tests/tst_ui -input tests/
```

### Coverage Reports
Configure with `-DENABLE_COVERAGE=ON` and run `./scripts/coverage_report.sh`.

## Future Roadmap

*   **Full LSP Support:** Deepen integration for advanced refactoring and go-to-definition.
*   **Multi-turn Conversations:** Maintain full chat history context for complex tasks.
*   **Refined Surgical Edits:** Direct application of AI diffs to the code editor.
*   **Hunk Staging:** Selective staging of Git changes directly from the Diff view.
