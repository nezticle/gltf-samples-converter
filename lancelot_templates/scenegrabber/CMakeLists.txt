#####################################################################
## qmlscenegrabber Binary:
#####################################################################

if (NOT QT_BUILD_STANDALONE_TESTS AND NOT QT_BUILDING_QT)
    cmake_minimum_required(VERSION 3.16)
    project(qmlscenegrabber LANGUAGES C CXX)
    find_package(Qt6BuildInternals REQUIRED COMPONENTS STANDALONE_TEST)
endif()

qt_internal_add_executable(qmlscenegrabber
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/.." # special case
    SOURCES
        main.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Quick3D
)
