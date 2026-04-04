# Building and Running

## Prerequisites

### macOS

Before building the project, you need to install the following dependencies:

- **Qt6:** You can install it using the official installer from the Qt website.

### Linux (Debian/Ubuntu)

Before building the project, you need to install the following dependencies:

```bash
sudo apt-get install -y qt6-base-dev qt6-declarative-dev qml-qt6 qmlscene-qt6 qml6-module-qtquick-controls qml6-module-qtquick-window qml6-module-qtquick-layouts qml6-module-qtquick-dialogs qml6-module-qtqml-workerscript qml6-module-qtquick qml6-module-qtquick-templates qml6-module-qtcore qml6-module-qt-labs-settings
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

To measure code coverage for unit tests, you need to have `gcov` installed.

1.  **Configure with coverage enabled:**
    ```bash
    cmake -DENABLE_COVERAGE=ON -B build
    ```

2.  **Build and run coverage target:**
    ```bash
    cmake --build build --target coverage
    ```

The coverage results will be generated as `.gcov` files in the `build/tests` directory. You can view them with any text editor or use tools like `lcov` or `gcovr` for better visualization. Note that the project target of 80% coverage applies specifically to the `.cpp` source files in the `src/` directory.
