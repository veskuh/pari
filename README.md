# Pari - Local AI Coding Companion

![Screenshot of Pari](assets/screenshot2.png)

Pari is a desktop application designed to be a local AI-powered coding partner. It leverages local Large Language Models (LLMs) through Ollama to assist with coding tasks.

## Purpose

The primary goal of Pari is to provide a simple way to use LLMs for:

*   **Code Review:** Get feedback and suggestions on your code.
*   **Documentation:** Generate comments and documentation for your code.
*   **Code Generation:** Get help with writing new code snippets.

Pari aims to be a trusted, local utility that can assist with coding tasks in an offline-first environment.

## Key Features

*   **Local LLM Integration:** Full streaming support for local Ollama instances.
*   **Code Editor:** Syntax highlighting for C++, QML, Markdown, and Shell. Supports auto-indentation and LSP integration.
*   **Git Support:** View diffs, logs, and branch information directly in the app.
*   **Diff View:** Visualize changes with integrated diff highlighting.
*   **Build System:** Configure and run build/run/clean commands.

## Testing & Quality

### Unit & UI Testing

The project includes automated tests covering both C++ logic and QML UI components.
*   **Unit Tests:** Verify core backend logic using the Qt Test framework.
*   **UI Tests:** verify component behavior and state using `QtQuickTest`.

To run the complete test suite:
```bash
# Run unit tests
./build/tests/tst_all

# Run UI tests
./build/tests/tst_ui -input tests/
```

### Code Coverage

Pari targets above 80% coverage. You can generate a detailed HTML report:

```bash
# Reconfigure with coverage enabled
cmake -B build -DENABLE_COVERAGE=ON
cmake --build build

# Generate report
./scripts/coverage_report.sh
open coverage_html/index.html
```

### Smoke Test

The application includes a smoke test that verifies if the main interface can be loaded successfully. This is triggered by the `--selfcheck` command-line flag.

```bash
# Example (macOS)
./build/src/pari.app/Contents/MacOS/pari --selfcheck
```

## Getting Started

See [BUILDING.md](BUILDING.md) for detailed build instructions and prerequisites.
