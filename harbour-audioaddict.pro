# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-audioaddict

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-audioaddict.qml \
    qml/cover/CoverPage.qml \
    qml/pages/ChangeStreamQuality.qml \
    qml/pages/ChannelDelegeate.qml \
    qml/pages/ChannelPage.qml \
    qml/pages/Favorites.qml \
    qml/pages/LoginPage.qml \
    qml/pages/StationPage.qml \
    rpm/harbour-audioaddict.changes.in \
    rpm/harbour-audioaddict.changes.run.in \
    rpm/harbour-audioaddict.spec \
    rpm/harbour-audioaddict.yaml \
    translations/*.ts \
    harbour-audioaddict.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-audioaddict-de.ts
