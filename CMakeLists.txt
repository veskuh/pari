cmake_minimum_required(VERSION 3.16)
project(Pari LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON) 

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(ENABLE_COVERAGE "Enable code coverage measurement" OFF)
if(ENABLE_COVERAGE)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        add_compile_options(--coverage)
        add_link_options(--coverage)
    endif()
endif()

find_package(Qt6 COMPONENTS Core Gui Quick QuickControls2 Qml Network Widgets Test LabsSettings QuickDialogs2 QuickTest Concurrent Core5Compat ShaderTools REQUIRED)
qt_standard_project_setup(REQUIRES 6.5)

add_subdirectory(3rdparty/Kaakao/src)
set(QML_IMPORT_PATH ${CMAKE_BINARY_DIR}/3rdparty CACHE STRING "QML Import Path" FORCE)
add_subdirectory(src)
add_subdirectory(tests)
