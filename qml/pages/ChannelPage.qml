/*
  Copyright (C) 2014.
  Contact: Alexander Nenashev <anenash@gmail.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.mpris 1.0
import "Utils.js" as Utils

Page {
    id: channelPage
    allowedOrientations: Orientation.All

    //channels
    //http://api.audioaddict.com/v1/di/channels/

    //Playback history
    //http://api.audioaddict.com/v1/sky/track_history/channel/22.json
    //Icons:
    //http://api.audioaddict.com/v1/assets/channel_sprite/sky/default/?width=128&height=128
    property variant icons
    property variant radioIcon
    property variant currentTrackIcon
    property string currentTrackId: "0"
    property string currentTrackTitle: ""
    property string currentRadioId: ""
    property string currentStationTitle: "Radiotunes"
    property string currentStation: "radiotunes"
    property string domen: "com"
    property string currentStreamQuality: "premium"
    property string currentKey
    property bool networkConnection: app.connected

    onStateChanged: {
        console.log("Network status", app.connected)
        if (stationsList.count === 0) {
           init() 
        }
    }

    function getIcons(data) {
        //.channel-icon-32-
        for(var i in icons) {
            var pattern = "(?:.channel-icon-64-" + icons[i].id + " { background-image: url\\()(.*)(?:\\); })"
            var regexp = new RegExp(pattern, "g");
            var res = null;
            if((res = regexp.exec(data)) !== null) {
                icons[i].icon = res[1]
                var tmp = icons[i]
                tmp.icon = res[1]
                stationsList.append(tmp);
            }
        }
        busyIndicator.running = false;
        busyIndicator.visible = false;
    }

    function getCurrentRadioIcon(data) {
        var pattern = "(?:.channel-icon-128-" + currentRadioId + " { background-image: url\\()(.*)(?:\\); })"
        var regexp = new RegExp(pattern, "g");
        var res = null;
        if((res = regexp.exec(data)) !== null) {
            radioIcon = res[1]
            currentRadioIcon.source = radioIcon
            app.radioIcon = radioIcon;
            var url = "https://api.audioaddict.com/v1/" + currentStation + "/track_history/channel/" + currentRadioId + ".json";
            sendHttpRequest(url, getChannel);
            updateTrack.start();
        }
    }


    ///////////////////////


    function getChannels() {
        busyIndicator.running = true;
        busyIndicator.visible = true;
        var url = "https://api.audioaddict.com/v1/" + currentStation + "/channels";
        Utils.sendHttpRequest("GET", url, parseData);
    }

    function parseData(data) {
        if(data === "error") {
            console.log("Source does not found.")
            return;
        }
        var json = JSON.parse(data);
        icons = json;
        for(var i in json) {
            stationsList.append(json[i]);
        }

        busyIndicator.running = false;
        busyIndicator.visible = false;
    }

    function getSource(data) {
        console.log("Get data:",data);
        if(data === "error") {
            console.log("Source does not found.")
            return;
        }
        var links = JSON.parse(data);
        for(var i in links) {
            if(links[i] !== undefined) {
                console.log("Source", links[i])
                app.playManager.stop()
                console.log("Available services: ", app.playManager.availableServices)
                console.log("Supported uri schemes: ", app.playManager.supportedUriSchemes)
                console.log("Supported mime types: ", app.playManager.supportedMimeTypes)
                if (app.playManager.openUri(links[i])) {
                    app.playManager.play()
                }
                return;
            }
        }
        console.log("Source does not found.")
    }

    function init() {
        getChannels()
        radioList.focus = true
    }

    function getStream() {
        var playlist = "https://listen." + currentStation + "." + domen + "/" + currentStreamQuality + "/" + currentKey
        var listenKey = app.config.value("listenKey", "none")
        var status = app.config.value("status", "unknown")
        console.log("key", listenKey, "status", status)
        if (listenKey !== "none" && status === "active") {
            playlist += "?" + listenKey
        }
        console.log("playlist", playlist)
        Utils.sendHttpRequest("GET", playlist, getSource)
        updateTrack.start()
    }

    ///////////////////////

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: false
        visible: false
        size: BusyIndicatorSize.Large
    }

    Component.onCompleted: {
        currentStreamQuality = app.config.value("streamQuality", "premium")
        if (app.connected) {
            init()
        }
    }

    ListModel {
        id: stationsList
    }

    ListModel {
        id: stationsListEmpty
    }

    function getRadioIcon(link) {
//        var toString = {}.toString;
//        console.log("Type", toString.call(link), link.toString())
        // TO DO: add local picture if link is undefined
        return "https:" + link;
    }



        SilicaListView {
            id: radioList
            anchors.fill: parent
            header: PageHeader { id: viewHeader; title: currentStationTitle }
            focus: true
            spacing: Theme.paddingSmall
            currentIndex: -1
            highlight: Rectangle {
                color: "#b1b1b1"
                opacity: 0.3
            }
            model: stationsList
            delegate: ChannelDelegate {
                radioIcon: getRadioIcon(asset_url)
                radioTitleText: name
                radioDescriptionText: description_short
                onClicked: {
                    currentKey = key
                    updateTrack.stop()
                    app.playManager.stop()
                    app.player.channelKey = key
                    app.player.channelId = id
                    app.player.channelName = name
                    app.player.channelIcon = "https:" + asset_url
                    app.player.trackIcon = "https:" + asset_url
                    app.player.station = currentStation
                    console.log(id, app.player.channelId)
                    var url = "https://api.audioaddict.com/v1/" + app.player.station + "/track_history/channel/" + app.player.channelId + ".json"
                    Utils.sendHttpRequest("GET", url, getChannel)
                    getStream()
                    app.shouldPlay = true
                }
            }

            clip: true
            VerticalScrollDecorator { flickable: radioList }

            ViewPlaceholder {
                id: viewPlaceholder
                enabled: !app.connected
                text: "Please, check your network connection"
                onEnabledChanged: {
                    if (enabled) {
                        radioList.model = stationsListEmpty
                    } else {
                        radioList.model = stationsList
                    }
                }
            }

            PullDownMenu {
                /*MenuItem {
                    text: "Favorite"
                    visible: false
                    onClicked: {
                        //
                        pageStack.push(Qt.resolvedUrl("Favorites.qml"))
                    }
                }*/
                MenuItem {
                    text: "Change quality"
                    onClicked: {
                        //
                        var dialog = pageStack.push(Qt.resolvedUrl("ChangeStreamQuality.qml"), {currentQualityLink: currentStreamQuality})
                        dialog.accepted.connect(function() {
                            currentStreamQuality = dialog.dict.link
                            app.config.setValue("streamQuality", currentStreamQuality)
                            getStream()
                        })
                    }
                }
            }

        }

}

