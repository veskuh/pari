# Building and Running

## Prerequisites

### macOS

Before building the project, you need to install the following dependencies:

- **Qt6:** You can install it using the official installer from the Qt website.
- **lcov:** Required for HTML coverage reports. Install with `brew install lcov`.

### Linux (Debian/Ubuntu)

Before building the project, you need to install the following dependencies:

```bash
sudo apt-get install -y qt6-base-dev qt6-declarative-dev qml-qt6 qmlscene-qt6 qml6-module-qtquick-controls qml6-module-qtquick-window qml6-module-qtquick-layouts qml6-module-qtquick-dialogs qml6-module-qtqml-workerscript qml6-module-qtquick qml6-module-qtquick-templates qml6-module-qtcore qml6-module-qt-labs-settings lcov
```

## Build

### macOS and Linux
Use the following commands to build the project:

```bash
mkdir build
cd build
cmake ..
make
```

## Run

After a successful build, the executables will be in the `build` directory.

### macOS
Run the application with:

```bash
./build/src/pari.app/Contents/MacOS/pari
```

### Linux
Run the application with:

```bash
./build/src/pari
```

## Code Coverage

Pari maintains a target of **80% code coverage** for all `.cpp` files in the `src/` directory. 

### Generating Reports

The project includes an automated script to run tests and generate coverage reports.

1.  **Configure with coverage enabled:**
    ```bash
    cmake -DENABLE_COVERAGE=ON -B build
    ```

2.  **Run the coverage script:**
    ```bash
    ./scripts/coverage_report.sh
    ```

This script will:
- Clean old profiling data.
- Run the full test suite (`tst_all`).
- Generate a text summary in the console.
- Generate a visual HTML report in the `coverage_html/` directory.

### Viewing Results
- **Text Summary:** Displayed directly in your terminal after running the script.
- **HTML Report:** Open `coverage_html/index.html` in your browser.
