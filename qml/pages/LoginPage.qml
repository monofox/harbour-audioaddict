import QtQuick 2.0
import Sailfish.Silica 1.0
import "Utils.js" as Utils

Page {
    id: loginPage
    allowedOrientations: Orientation.All
    property string network: ""
    property Page stationPage: null

    Component.onCompleted: {
        busyIndicator.visible = true
        busyIndicator.running = true
        checkPremium(true);
        var url = "https://api.audioaddict.com/v1/di/plans/premium-pass"
        Utils.sendHttpRequest("GET", url, getPrices)
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: false
        visible: false
        size: BusyIndicatorSize.Large
    }

    function checkPremium(sendHook) {
        if (app.config.value("apiKey", "") !== "") {
            head.title = "User information"
            name.text = app.config.value("firstName", "") + " " + app.config.value("lastName", "");
            premiumFinished.text = app.config.value("expiresOn", "")
            if(app.config.value("status") !== "active") {
                premiumFinished.errorHighlight = true;
            } else {
                premiumFinished.errorHighlight = false;
            }

            userInfo.visible = true
            log_in.visible = false

            // We've already an API key. Be sure, to check if the key is valid!
            var url = "https://api.audioaddict.com/v1/di/members/authenticate"
            var params = "api_key=" + app.config.value("apiKey", "")
            if (sendHook) {
                Utils.sendHttpRequest("POST", url, updatePremium, params);
            }
        } else {
            console.log("Need to show login form.")
            log_in.visible = true
            userInfo.visible = false
        }
        busyIndicator.running = false
        busyIndicator.visible = false
    }

    function getPrices(data) {
        if(data !== 'error') {
            var tmp = JSON.parse(data)
            for(var i in tmp.price_sets[0].price_set_options) {
                priceModel.append(tmp.price_sets[0].price_set_options[i])
            }
        }
    }

    function updatePremium(data) {
        console.log("Login information available: ", data)
        if (data !== 'error') {
            Utils.updateApiLogin(app.config, data)
        } else {
            Utils.resetApiLogin(app.config)
        }
        if (stationPage !== null) {
            stationPage.loginChanged()
        }

        checkPremium(false)
    }

    ListModel {
        id: priceModel
    }

    PageHeader { id: head; title: 'Sign in' }

    Item {
        anchors.top: head.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: loginPage.height * 0.5 - head.height
        width: parent.width
        Item {
            id: log_in
            anchors.fill: parent
            visible: false
            Column {
                anchors.centerIn: parent
                width: parent.width
                spacing: 2
                TextField {
                    id: username
                    width: parent.width
                    text: ""
                    placeholderText: "Type username here..."
                    label: "Username"

                    // Only allow Enter key to be pressed when text has been entered
                    EnterKey.enabled: text.length > 0

                    // Show 'next' icon to indicate pressing Enter will move the
                    // keyboard focus to the next text field in the page
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"

                    // When Enter key is pressed, move the keyboard focus to the
                    // next field
                    EnterKey.onClicked: password.focus = true
                }

                TextField {
                    id: password
                    width: parent.width
                    text: ""
                    placeholderText: "Type password here..."
                    label: "Password"
                    echoMode: TextInput.PasswordEchoOnEdit
                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: {
                        var url = "https://api.audioaddict.com/v1/di/members/authenticate"
                        var params = "username=" + username.text + "&password=" + password.text
                        Utils.sendHttpRequest("POST", url, updatePremium, params);
                    }
                }

                Button {
                    id: loginButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Sign-in"
                    onClicked: {
                        var url = "https://api.audioaddict.com/v1/di/members/authenticate"
                        var params = "username=" + username.text + "&password=" + password.text
                        Utils.sendHttpRequest("POST", url, updatePremium, params);
                    }
                }
                onVisibleChanged: {
                    pricesItem.anchors.top = userInfo.visible?userInfo.bottom:log_in.bottom
                }
            }
        }

        Item {
            id: userInfo
            anchors.fill: parent
            visible: false
            Column {
                anchors.centerIn: parent
                width: parent.width
                spacing: 2
                TextField {
                    id: name
                    width: parent.width
                    text: ""
                    label: "Username"
                    readOnly: true
                }
                TextField {
                    id: premiumFinished
                    width: parent.width
                    text: ""
                    label: "Expires on"
                    readOnly: true
                }

                Button {
                    id: logoutButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Sign out"
                    onClicked: {
                        Utils.resetApiLogin(app.config)
                        if (stationPage !== null) {
                            stationPage.loginChanged()
                        }
                        checkPremium()
                    }
                }
            }
        }
    }

    Item {
        id: pricesItem
        height: loginPage.height * 0.5
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        visible: true
        Column {
            anchors.centerIn: parent
            spacing: 5
            Label {
                text: "Prices"
                font.bold: true
                font.pointSize: 26
            }
            Repeater {
                model: priceModel
                delegate: Label {
                    text: formatted_price_string + " for " + term_unit
                }
            }
        }
    }

    PullDownMenu {
        MenuItem {
            text: "Show prices"
            onClicked: {
                //
                console.log("Prices")
                priceDialog.open();
            }
        }
    }

    Dialog {
        id: priceDialog
        allowedOrientations: Orientation.Portrait
        Flickable {
            // ComboBox requires a flickable ancestor
            width: parent.width
            height: parent.height
            interactive: false

            Column {
                width: parent.width

                DialogHeader {
                    title: "Prices"
                }
            }
        }
    }
}

