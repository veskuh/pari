cmake_minimum_required(VERSION 3.16)
project(Pari LANGUAGES CXX)

if(APPLE)
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT OR CMAKE_INSTALL_PREFIX STREQUAL "/usr/local")
        set(CMAKE_INSTALL_PREFIX "/Applications" CACHE PATH "Install path prefix" FORCE)
    endif()
endif()


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

find_package(Qt6 COMPONENTS Core Gui Quick QuickControls2 Qml Network Widgets Test QuickDialogs2 QuickTest Concurrent Core5Compat ShaderTools REQUIRED)
qt_standard_project_setup(REQUIRES 6.5)
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)

add_subdirectory(third-party/Kaakao/src kaakao)
add_library(Kaakao::Kaakao ALIAS Kaakao)
add_subdirectory(src)
add_subdirectory(tests)
