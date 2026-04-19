# Building and Running

## Prerequisites

### Common Dependencies
- **Qt6:** (Core, Gui, Qml, Quick, Widgets, Network, Test)
- **CMake:** 3.16 or newer.
- **Ninja/Make:** Build system generator.
- **Ollama:** Locally running instance for AI features.

### Tools for Features 
- **clang-format:** For C++ code formatting.
- **qmlformat:** For QML code formatting.

### macOS
Install dependencies via Homebrew:
```bash
brew install qt6 cmake lcov clang-format
```

### Linux (Debian/Ubuntu)
```bash
sudo apt-get install -y qt6-base-dev qt6-declarative-dev qml-qt6 qmlscene-qt6 \
    qml6-module-qtquick-controls qml6-module-qtquick-window qml6-module-qtquick-layouts \
    qml6-module-qtquick-dialogs qml6-module-qtqml-workerscript qml6-module-qtquick \
    qml6-module-qtquick-templates qml6-module-qtcore lcov clang-format
```

## Build Instructions

```bash
# Configure the build
cmake -B build

# Compile
cmake --build build
```

## Running the Application

### macOS
```bash
./build/src/pari.app/Contents/MacOS/pari
```

### Linux
```bash
./build/src/pari
```

## Code Coverage

Pari maintains a high quality standard with automated coverage reporting.

1.  **Rebuild with coverage enabled:**
    ```bash
    cmake -B build -DENABLE_COVERAGE=ON
    cmake --build build
    ```

2.  **Generate the report:**
    ```bash
    ./scripts/coverage_report.sh
    ```

3.  **View Results:**
    Open `coverage_html/index.html` in your browser to see the detailed line-by-line coverage.
