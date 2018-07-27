QT += core quick network quickcontrols2 svg
CONFIG += c++11

unix:!macx {
    TARGET = moonlight
} else {
    # On macOS, this is the name displayed in the global menu bar
    TARGET = Moonlight
}

TEMPLATE = app

# The following define makes your compiler emit warnings if you use
# any feature of Qt which has been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

win32 {
    INCLUDEPATH += $$PWD/../libs/windows/include

    contains(QT_ARCH, i386) {
        LIBS += -L$$PWD/../libs/windows/lib/x86
    }
    contains(QT_ARCH, x86_64) {
        LIBS += -L$$PWD/../libs/windows/lib/x64
    }

    LIBS += ws2_32.lib winmm.lib dxva2.lib ole32.lib
}
macx {
    INCLUDEPATH += $$PWD/../libs/mac/include
    LIBS += -L$$PWD/../libs/mac/lib
}

unix:!macx {
    CONFIG += link_pkgconfig
    PKGCONFIG += openssl sdl2
    LIBS += -ldl

    packagesExist(libavcodec) {
        PKGCONFIG += libavcodec libavutil
        CONFIG += ffmpeg

        packagesExist(libva) {
            CONFIG += libva
        }
    }
}
win32 {
    LIBS += -llibssl -llibcrypto -lSDL2 -lavcodec -lavutil
    CONFIG += ffmpeg
}
macx {
    LIBS += -lssl -lcrypto -lSDL2 -lavcodec.58 -lavutil.56
    LIBS += -lobjc -framework VideoToolbox -framework AVFoundation -framework CoreVideo -framework CoreGraphics -framework CoreMedia -framework AppKit
    CONFIG += ffmpeg
}

SOURCES += \
    main.cpp \
    backend/identitymanager.cpp \
    backend/nvhttp.cpp \
    backend/nvpairingmanager.cpp \
    backend/computermanager.cpp \
    backend/boxartmanager.cpp \
    settings/streamingpreferences.cpp \
    streaming/input.cpp \
    streaming/session.cpp \
    streaming/audio.cpp \
    gui/computermodel.cpp \
    gui/appmodel.cpp

HEADERS += \
    utils.h \
    backend/identitymanager.h \
    backend/nvhttp.h \
    backend/nvpairingmanager.h \
    backend/computermanager.h \
    backend/boxartmanager.h \
    settings/streamingpreferences.h \
    streaming/input.hpp \
    streaming/session.hpp \
    gui/computermodel.h \
    gui/appmodel.h \
    streaming/video/decoder.h

# Platform-specific renderers and decoders
ffmpeg {
    message(FFmpeg decoder selected)

    DEFINES += HAVE_FFMPEG
    SOURCES += \
        streaming/video/ffmpeg.cpp \
        streaming/video/ffmpeg-renderers/sdl.cpp
    HEADERS += \
        streaming/video/ffmpeg.h \
        streaming/video/ffmpeg-renderers/renderer.h
}
libva {
    message(VAAPI renderer selected)

    DEFINES += HAVE_LIBVA
    SOURCES += streaming/video/ffmpeg-renderers/vaapi.cpp
    HEADERS += streaming/video/ffmpeg-renderers/vaapi.h
}
config_SLVideo {
    message(SLVideo decoder/renderer selected)

    DEFINES += HAVE_SLVIDEO
    LIBS += -lSLVideo
    SOURCES += streaming/video/sl.cpp
    HEADERS += streaming/video/sl.h
}
win32 {
    message(DXVA2 renderer selected)

    SOURCES += streaming/video/ffmpeg-renderers/dxva2.cpp
    HEADERS += streaming/video/ffmpeg-renderers/dxva2.h
}
macx {
    message(VideoToolbox renderer selected)

    SOURCES += streaming/video/ffmpeg-renderers/vt.mm
    HEADERS += streaming/video/ffmpeg-renderers/vt.h
}

RESOURCES += \
    resources.qrc \
    qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../moonlight-common-c/release/ -lmoonlight-common-c
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../moonlight-common-c/debug/ -lmoonlight-common-c
else:unix: LIBS += -L$$OUT_PWD/../moonlight-common-c/ -lmoonlight-common-c

INCLUDEPATH += $$PWD/../moonlight-common-c/moonlight-common-c/src
DEPENDPATH += $$PWD/../moonlight-common-c/moonlight-common-c/src

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../opus/release/ -lopus
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../opus/debug/ -lopus
else:unix: LIBS += -L$$OUT_PWD/../opus/ -lopus

INCLUDEPATH += $$PWD/../opus/opus/include
DEPENDPATH += $$PWD/../opus/opus/include

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../qmdnsengine/release/ -lqmdnsengine
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../qmdnsengine/debug/ -lqmdnsengine
else:unix: LIBS += -L$$OUT_PWD/../qmdnsengine/ -lqmdnsengine

INCLUDEPATH += $$PWD/../qmdnsengine/qmdnsengine/src/include $$PWD/../qmdnsengine
DEPENDPATH += $$PWD/../qmdnsengine/qmdnsengine/src/include $$PWD/../qmdnsengine

unix:!macx: {
    isEmpty(PREFIX) {
        PREFIX = /usr/local
    }
    isEmpty(BINDIR) {
        BINDIR = bin
    }

    target.path = $$PREFIX/$$BINDIR/

    desktop.files = deploy/linux/com.moonlight_stream.Moonlight.desktop
    desktop.path = $$PREFIX/share/applications/

    icons.files = res/moonlight.svg
    icons.path = $$PREFIX/share/icons/hicolor/scalable/apps/

    appdata.files = deploy/linux/com.moonlight_stream.Moonlight.appdata.xml
    appdata.path = $$PREFIX/share/metainfo/

    INSTALLS += target desktop icons appdata
}

win32 {
    RC_ICONS = moonlight.ico
}

macx {
    QMAKE_INFO_PLIST = $$PWD/Info.plist
    APP_QML_FILES.files = res/macos.icns
    APP_QML_FILES.path = Contents/Resources
    QMAKE_BUNDLE_DATA += APP_QML_FILES
}

VERSION = 0.0.2
