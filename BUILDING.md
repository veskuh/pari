# Building and Running

## Prerequisites

### Common Dependencies
- **Qt6:** (Core, Gui, Qml, Quick, Widgets, Network, Test, Core5Compat, ShaderTools)
- **CMake:** 3.16 or newer.
- **Ninja/Make:** Build system generator.
- **Ollama:** Locally running instance for AI features.

### Tools for Features 
- **clang-format:** For C++ code formatting.
- **clang-tidy:** For C++ static analysis.
- **qmlformat:** For QML code formatting.

### macOS
Install dependencies via Homebrew:
```bash
brew install qt6 cmake lcov clang-format llvm
```

### Linux (Debian/Ubuntu / openSUSE)
```bash
sudo apt-get install -y qt6-base-dev qt6-declarative-dev qml-qt6 qmlscene-qt6 \
    qml6-module-qtquick-controls qml6-module-qtquick-window qml6-module-qtquick-layouts \
    qml6-module-qtquick-dialogs qml6-module-qtqml-workerscript qml6-module-qtquick \
    qml6-module-qtquick-templates qml6-module-qtcore qml6-module-qt5compat-graphicaleffects \
    qt6-5compat-dev qt6-shadertools-dev lcov clang-format clang-tidy
# openSUSE: qt6-qt5compat-devel qt6-shadertools-devel
```

## Build Instructions

```bash
# Configure the build
cmake -B build

# Compile
cmake --build build
```

## Static Analysis

To run `clang-tidy` static analysis locally:

```bash
# Export compile commands
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# Run static analysis
clang-tidy -p build src/integrations/*.cpp src/core/*.cpp src/editor/*.cpp src/formatting/*.cpp
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

