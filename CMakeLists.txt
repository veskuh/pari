cmake_minimum_required(VERSION 3.16)
project(Pari LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6 COMPONENTS Core Gui Quick QuickControls2 Qml Network Widgets Test LabsSettings QuickDialogs2 REQUIRED)
qt_standard_project_setup(REQUIRES 6.5)

add_subdirectory(src)
add_subdirectory(tests)
