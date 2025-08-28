cmake_minimum_required(VERSION 3.16)
project(Pari LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS Core Quick Qml Network Widgets Test LabsSettings REQUIRED)

add_subdirectory(src)
add_subdirectory(tests)
