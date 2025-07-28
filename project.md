# Simple AI C++/Qt Code Editor

## UI

* Code editor pane
* File System pane
* AI Message pane
* AI Output pane
* Menu bar
* Status bar
* Toolbar for common actions (e.g., save, open, build)
* Project explorer

## Features

* Reads `settings.md` for code structure (if it exists)
* Checks files in the directory
* Reads build configuration (qmake or CMake-based builds)
* Based on user requests:
    * Can comment/review current code
    * Can refactor code
    * Can add new code and code files
    * Can add documentation
    * Can refactor build and other configuration
* Provides error detection and explanation with suggested fixes, helping users quickly identify and resolve coding issues.
* Generates unit tests based on code analysis, facilitating automated testing and ensuring code reliability.

## Architecture and Implementation Plan

**1. UI/UX**

*   The main window will be a `SplitView`.
*   The left side will contain the "File System pane" and the "Project explorer".
*   The right side will be a vertical `SplitView` containing the "Code editor pane" on top and the "AI Message pane" and "AI Output pane" at the bottom.

**2. Core Components:**

*   **Prompt Engineering Module:**  Transforms user requests and code snippets into prompts suitable for the LLM.  Includes templates for different tasks (commenting, refactoring, documentation).
*   **LLM Interface:**  Handles communication with Ollama.  
*   **Code Generation/Modification Module:**  Applies the LLM's output to the code within the editor.  Handles code insertion, deletion, and modification safely.
*   **Context Management:**  Maintains context across multiple interactions with the LLM.  Includes code snippets, user requests, and previous LLM responses.
*   **UI:** QML based UI
    *   **File System Pane:** Implemented using `QFileSystemModel` to provide a view of the local file system.
    *   **Code Editor Pane:** A `TextArea` for code editing.

**3. Settings Management**

*   Application settings (e.g., window size, font size, theme) will be stored using `QSettings`.

**4. Error Handling**

*   Errors from the LLM API will be displayed in the "AI Output pane".
*   Application-level errors will be logged to a file and displayed in a dialog.

**5. Testing**

*   Unit tests will be written for the core components, including the `Llm` class and the prompt engineering module.

**6. Implementation Steps:**

*   **Phase 1: Foundational UI and Basic LLM Integration**
    *   **1.1: Basic UI Structure:**
        *   Implement the main `SplitView` layout in QML.
        *   Create placeholder panes for the "File System pane", "Project explorer", "Code editor pane", "AI Message pane", and "AI Output pane".
    *   **1.2: File System View:**
        *   Implement the "File System pane" using `QFileSystemModel` and a `TreeView` in QML.
        *   Allow browsing the file system.
        *   When a file is selected, its content should be loaded into the "Code editor pane".
    *   **1.3: Basic LLM Communication:**
        *   Implement the `Llm` class to send a hardcoded prompt to the Ollama API.
        *   Display the LLM's response in the "AI Output pane".
    *   **1.4: Code Commenting - UI Integration:**
        *   Add a "Comment Code" button to the toolbar.
        *   When the button is clicked, the content of the "Code editor pane" will be sent to the `Llm` class.
        *   The `Llm` class will use a prompt template for code commenting.
        *   The LLM's response (the commented code) will be displayed in the "AI Output pane".
*   **Phase 2: Refactoring & Documentation:**
    *   Expand prompting templates for refactoring and documentation.
    *   Implement code modification capabilities.
*   **Phase 3: Contextual Awareness & Advanced Features:**
    *   Implement context management for multi-turn conversations.
    *   Add support for more advanced features (e.g., code completion, bug detection).
    *   Optimize performance and scalability.
*   **Phase 4: UI/UX Polish and Testing**
    *   Refine the UI and user experience.
    *   Write comprehensive unit tests.

**7. Technology Stack:**

*   **LLM:** Ollama locally hosted LLM models
*   **Networking:** Qt's networking classes for LLM API communication.
*   **UI:** Qt/QML