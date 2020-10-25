import QtQuick 2.0
import Sailfish.Silica 1.0
import "Utils.js" as Utils

Page {
    id: stationPage
    allowedOrientations: Orientation.All

    function onApiPremiumCheckDone(data) {
        console.log("api premium check done, result: ", data)
        if (data === "error") {
            if (app.connected) {
                //Utils.resetApiLogin(app.config)
                viewPlaceholderLogin.enabled = true
                viewPlaceholder.enabled = false
                stationsView.model = audioAddictStationsEmpty
                forceLogin()
            } else {
                viewPlaceholder.enabled = true
                viewPlaceholderLogin.enabled = false
            }
        } else {
            Utils.updateApiLogin(app.config, data)
            app.loggedIn = true
            viewPlaceholderLogin.enabled = false
            viewPlaceholder.enabled = false
            stationsView.model = audioAddictStations
        }
    }

    function forceLogin() {
        console.log("Need to go to login page... no other possibility!")
        pageStack.push(Qt.resolvedUrl("LoginPage.qml"), {network: "di", "stationPage": stationPage})

        console.log("All done....")
    }

    function checkLogin(switchToLogin) {
        console.log("Checking if login is fine (apiKey)")
        if (app.connected) {
            // Login is required meanwhile!
            if (app.config.value("apiKey", "") === "") {
                viewPlaceholderLogin.enabled = true
                if (switchToLogin) {
                    forceLogin()
                }
            } else {
                Utils.checkAccountByKey(app.config.value("apiKey", ""), onApiPremiumCheckDone)
            }
        } else {
            console.log("No network connections.")
            viewPlaceholderLogin.enabled = false
            viewPlaceholder.enabled = true
        }
    }

    function networkStateChanged(state) {
        console.log("Network state changed: ", state, app.connected)
        if (app.connected) {
            viewPlaceholder.enabled = false
            viewPlaceholderLogin.enabled = true
            checkLogin(true)
        } else {
            viewPlaceholder.enabled = true
            viewPlaceholderLogin.enabled = false
            stationsView.model = audioAddictStationsEmpty
        }
    }

    function loginChanged() {
        checkLogin(false)
    }

    Component.onCompleted: {
        app.stationPage = stationPage
        checkLogin(true)
    }

    ListModel {
        id: audioAddictStations
        ListElement { name: "Classical Radio"; link: "classicalradio"; domen: "com"; icon: "https://cdn.audioaddict.com/classicalradio.com/assets/logo-1bfff0f5c5b383c0be3f3cb214a7767eac8e3c7114576e15affd9cfaaeba0a72.svg" }
        ListElement { name: "DI.FM"; link: "di"; domen: "fm"; icon: "https://upload.wikimedia.org/wikipedia/en/3/3d/DI.FM_%28Digitally_Imported%29_New_Logo_-_2018.png" }
        ListElement { name: "JazzRadio"; link: "jazzradio"; domen: "com"; icon: "https://cdn.audioaddict.com/jazzradio.com/assets/logo-213eba1ee493292d34834889d5d6a87695cb1c06a425aec215d3be9a3b234e46.svg" }
        ListElement { name: "RadioTunes"; link: "radiotunes"; domen: "com"; icon: "https://cdn.audioaddict.com/radiotunes.com/assets/logo-7ecd74b319fa8ca47461e6c5aa8ba3f984983cad5ad16575d29dd3c19d4e5489.svg" }
        ListElement { name: "RockRadio"; link: "rockradio"; domen: "com"; icon: "https://cdn.audioaddict.com/rockradio.com/assets/logo@1x-59029197dbdd444853cf52fbed9f7a4511740e2b4314ce53937d9c4b8f2c0ced.png" }
        ListElement { name: "Zen Radio"; link: "zenradio"; domen: "com"; icon: "https://cdn.audioaddict.com/di.fm/assets/premium/network-zenradio-776e725336c8903f93fd1f1fa8284131d7be13a7ca9d2324b1a9318f7c2e3da2.png" }
    }

    ListModel { id: audioAddictStationsEmpty }

    SilicaListView {
        id: stationsView
        model: audioAddictStationsEmpty
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingSmall
        header: PageHeader { id: viewHeader; title: "Select a radio station" }
        focus: true
        spacing: Theme.paddingMedium
        delegate: ListItem {
            width: parent.width
            height: Theme.itemSizeExtraLarge
            Image {
                id: delegateRadioIcon
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                cache: true
                source: icon
                BusyIndicator {
                    anchors.centerIn: parent
                    running: delegateRadioIcon.status === Image.Ready ? false : true
                    visible: delegateRadioIcon.status === Image.Ready ? false : true
                    size: BusyIndicatorSize.Medium
                }
            }
            onClicked: {
                console.log("Open channels for: ", name, link, domen)
                app.config.setValue("lastChannelTitle", name)
                app.config.setValue("lastChannelLink", link)
                app.config.setValue("lastChannelDomen", domen)
                app.config.sync()
                pageStack.push(Qt.resolvedUrl("ChannelPage.qml"), {"currentStationTitle": name, "currentStation": link, "domen": domen})
            }
        }

        clip: true
        VerticalScrollDecorator { flickable: radioList }

        ViewPlaceholder {
            id: viewPlaceholderLogin
            enabled: app.connected && !app.loggedIn
            text: "Not logged in yet."
        }

        ViewPlaceholder {
            id: viewPlaceholder
            enabled: !app.connected
            text: "Please, check your network connection"
        }

        PullDownMenu {
            MenuItem {
                text: "User information"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LoginPage.qml"), {network: "di", "stationPage": stationPage})
                }
            }
        }
    }
}
