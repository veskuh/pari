# Building and Running

## Prerequisites

### macOS

Before building the project, you need to install the following dependencies:

- **Qt6:** You can install it using the official installer from the Qt website.

### Linux (Debian/Ubuntu)

Before building the project, you need to install the following dependencies:

```bash
sudo apt-get install -y qt6-base-dev qt6-declarative-dev qml-qt6 qmlscene-qt6 qml6-module-qtquick-controls qml6-module-qtquick-window qml6-module-qtquick-layouts qml6-module-qtquick-dialogs qml6-module-qtqml-workerscript qml6-module-qtquick qml6-module-qtquick-templates
```

## Build

### macOS
Use the following commands to build the project:

```bash
mkdir build
cd build
~/Qt/6.8.0/macos/bin/qmake ../pari.pro
make
```

### Linux
Use the following commands to build the project:

```bash
mkdir build
cd build
qmake6 ../pari.pro
make
```

## Run

### macOS
After a successful build, run the application with:

```bash
./pari.app/Contents/MacOS/pari
```

### Linux
After a successful build, run the application with:

```bash
./build/src/pari
```
