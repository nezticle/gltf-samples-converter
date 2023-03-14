#####################################################################
## qmlscenegrabber Binary:
#####################################################################

qt_internal_add_executable(qmlscenegrabber
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/.." # special case
    SOURCES
        main.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Quick3D
)
