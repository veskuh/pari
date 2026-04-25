# Pari: Your Local AI Coding Companion

## Completed Features

*   **Modular Architecture:** Refactored into a clean, component-based structure (`AppLogic`, `PariActions`, etc.).
*   **Intelligent UI:** Resizable panes using `SplitView`, togglable sidebars, and proportional layouts.
*   **Local AI Power:** Full streaming integration with Ollama for real-time responses.
*   **Contextual AI:** Automatic injection of file content and user selection into prompts.
*   **Visual Diffs:** Integrated diff view for AI-suggested changes.
*   **Git Integration:** Built-in support for git diff, git log (with blame), and branch status.
*   **Build System:** Configurable build/run/clean commands with clickable error navigation.
*   **Advanced Search:** Integrated incremental search and **Grep-like line filtering** with original document numbering.
*   **Multi-Language:** Precision syntax highlighting for C++, QML, Markdown, Shell, **Swift**, and **JavaScript**.
*   **Skeuomorphic Design:** Tactile "Precision Bench" design with full Light/Dark mode support.
*   **Quality First:** Robust test suite with **233+ tests** and **85.7%** line coverage.

## Current Architecture

*   **Frontend:** QML with a modular component system and declarative logic.
*   **Backend Facade (`DocumentManager`):** Central orchestrator for document lifecycles and state.
*   **Engines:** 
    *   `Llm`: Streaming Ollama integration.
    *   `ToolManager`: External process handling (Git, Formatting).
    *   `BuildManager`: Project build and execution engine.
    *   `SyntaxHighlighterProvider`: Multi-language highlighting manager.

## Development & Testing

### Running Tests
```bash
# C++ Unit Tests
./build/tests/tst_all

# QML UI Tests
./build/tests/tst_ui -input tests/
```

### Coverage Reports
Configure with `-DENABLE_COVERAGE=ON` and run `./scripts/coverage_report.sh`.

## Future Roadmap

*   **Full LSP Support:** Deepen integration for advanced refactoring and go-to-definition.
*   **Multi-turn Conversations:** Maintain full chat history context for complex tasks.
*   **Project-wide AI Search:** Investigative tools for exploring large codebases.
*   **Refined Surgical Edits:** Direct application of AI diffs to the code editor.
