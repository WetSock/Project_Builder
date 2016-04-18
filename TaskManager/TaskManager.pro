TEMPLATE = app

QT += qml quick widgets svg xml
QTPLUGIN += qsvg qsvgicon


CONFIG += c++11

SOURCES += main.cpp \
    user.cpp \
    task.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    user.h \
    task.h


