/*
  Copyright (C) 2014
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
import QtMultimedia 5.6
import MeeGo.Connman 0.2
import Nemo.Configuration 1.0
import org.nemomobile.mpris 1.0
import "pages/Utils.js" as Utils
import "pages"

ApplicationWindow
{
    id: app

    property bool shouldPlay: false
    property alias nm: networkConnection
    property alias connected: networkConnection.connected
    property alias connectedWifi: networkConnection.connectedWifi
    property alias config: appConfig
    property alias player: radioPlayer
    property alias playManager: radioManager
    property bool loggedIn: false
    property Page stationPage: null

    ConfigurationGroup {
        id: appConfig
        path: "/harbour-audioaddict"
    }

    NetworkManager {
        id: networkConnection
        onStateChanged: {
            console.log("Network state", state, "Connected: ", connected, "player", radioPlayer.playbackState)
            if (stationPage) {
                stationPage.networkStateChanged(state)
            }
            if (connected && shouldPlay) {
                console.log("Network state: starting player", radioPlayer.playbackState)
                if(radioManager.playbackStatus === Mpris.Paused || radioManager.playbackStatus === Mpris.Stopped) {
                    console.log("Network state: start player")
                    //radioPlayer.seek(0)
                    radioManager.play()
                }
            } else {
                console.log("Network state: stop player", radioPlayer.errorString)
                radioManager.stop()
            }
        }
    }

    MprisManager {
        id: radioManager
        singleService: true
        currentService: "harbour-audioaddict"
    }

    MprisPlayer {
        id: radioPlayer
        property string artist
        property string title
        property string album
        property string titleLength
        property string track
        property string trackIcon
        property string station
        property string channelName
        property string channelIcon
        property int channelId: 0
        property string channelKey

        serviceName: "harbour-audioaddict"
        identity: "AudioAddict Radio"
        desktopEntry: "harbour-audioaddict"
        //supportedUriSchemes: ["file", "http", "https"]
        // Sailfish bug: MPris service handles correctly, but this Qt thing for openUri handles inverted !?
        // Propagate both....
        supportedUriSchemes: ["http", "https", "audio/x-wav", "audio/x-vorbis+ogg", "audio/aac", "application/octet-stream"]
        supportedMimeTypes: ["http", "https", "audio/x-wav", "audio/x-vorbis+ogg", "audio/aac", "application/octet-stream"]
        //supportedMimeTypes: ["audio/x-wav", "audio/x-vorbis+ogg", "audio/aac"]
        canGoNext: false
        canGoPrevious: false
        canSeek: false
        canControl: true
        shuffle: false
        playbackStatus: Mpris.Stopped
        loopStatus: Mpris.None
        canPause: true
        canPlay: true

        onOpenUriRequested: {
            console.log("Requested to open uri \"" + url + "\"")
            mediaPlayer.source = url
        }
        onPlayRequested: {
            console.log("Play requested... ?")
            mediaPlayer.play()
        }

        onPlayPauseRequested: {
            console.log("PlayPause requested... ?")
            if (playbackStatus === Mpris.Playing) {
                mediaPlayer.pause()
            } else {
                mediaPlayer.play()
            }
        }

        onStopRequested: {
            console.log("Stop requested... ?")
            mediaPlayer.stop()
        }

        onPauseRequested: {
            console.log("Pause requested... ?")
            mediaPlayer.pause()
        }

        onChannelNameChanged: {
            currentRadio.text = channelName
        }

        onChannelIconChanged: {
            currentRadioIcon.source = channelIcon
            if (channelIcon !== "") {
                currentRadioIcon.opacity = 1
            } else {
                currentRadioIcon.opacity = 0
            }
        }

        onArtistChanged: {
            var metadata = radioPlayer.metadata
            metadata[Mpris.metadataToString(Mpris.Artist)] = [artist] // List of strings
            radioPlayer.metadata = metadata
            console.log("New artist: ", artist)
        }

        onTitleChanged: {
            var metadata = radioPlayer.metadata
            metadata[Mpris.metadataToString(Mpris.Title)] = title // String
            radioPlayer.metadata = metadata
        }

        onAlbumChanged: {
            var metadata = radioPlayer.metadata
            metadata[Mpris.metadataToString(Mpris.Album)] = album // String
            radioPlayer.metadata = metadata
        }

        onTitleLengthChanged: {
            var metadata = radioPlayer.metadata
            metadata[Mpris.metadataToString(Mpris.Length)] = titleLength // int
            radioPlayer.metadata = metadata
        }

        onTrackChanged: {
            currentTrack.text = track
        }

        /*onPlaybackStatusChanged: {
            radioPlayer.canPause = playbackStatus === Mpris.Playing
            radioPlayer.canPlay = playbackStatus !== Mpris.Playing
        }*/
    }

    Audio {
        id: mediaPlayer
        source: ""
        autoLoad: false
        autoPlay: false
        audioRole: Audio.MusicRole
        onError: {
            console.log("Error happened", radioPlayer.errorString, "error num", radioPlayer.error)
            if (networkConnection.connected && 3 === radioPlayer.error) {
                radioPlayer.play()
            }
            mprisManager.play()
        }
        onPlaying: {
            radioPlayer.playbackStatus = Mpris.Playing
            updateTrack.start()
        }
        onStopped: {
            radioPlayer.playbackStatus = Mpris.Stopped
            updateTrack.stop()
        }
        onPaused: {
            radioPlayer.playbackStatus = Mpris.Paused
            updateTrack.stop()
        }
    }

    bottomMargin: playControlDock.open ? playControlDock.visibleSize : 0
    initialPage: Component { StationPage { } }
    allowedOrientations: Orientation.All
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    function getChannel(data) {
        if(data === "error") {
            console.log("Source does not found.")
            return;
        }
        var json = JSON.parse(data);
        for(var i in json) {
            if (json[i].type !== "advertisement") {
                if(app.player.track !== json[i].track) {
                    app.player.artist = json[i].display_artist;
                    app.player.title = json[i].display_title;
                    if (json[i].release) {
                        app.player.album = json[i].release
                    } else {
                        app.player.album = ""
                    }
                    app.player.titleLength = json[i].length;
                    app.player.track = json[i].track;
                    /*if(Database.recordIsPresent(currentTrackId)) {
                        favButton.icon.source = "image://theme/icon-l-favorite"
                        favButton.enabled = false;
                    } else {
                        favButton.icon.source = "image://theme/icon-l-star"
                        favButton.enabled = true;
                    }*/
                    if (json[i].art_url) {
                        app.player.channelIcon = "https:" + json[i].art_url
                    } else {
                        app.player.channelIcon = currentTrackIcon
                    }
                }
                break;
            }
        }
    }

    Timer {
        id: updateTrack
        interval: 5000
        repeat: true
        running: radioManager.playbackStatus === Mpris.Playing
        onTriggered: {
            var url = "https://api.audioaddict.com/v1/" + radioPlayer.station + "/track_history/channel/" + radioPlayer.channelId + ".json"
            Utils.sendHttpRequest("GET", url, getChannel)
            if (radioManager.playbackStatus !== Mpris.Playing) {
                updateTrack.stop()
            }
        }
    }

    DockedPanel {
        id: playControlDock
        property bool _isLandscape: pageStack && pageStack.currentPage && pageStack.currentPage.isLandscape
        anchors.bottom: parent.bottom
        z: 1
        dock: Dock.Bottom
        open: radioManager.playbackStatus !== Mpris.Stopped
        width: parent.width
        height: playerItem.height + (_isLandscape ? Theme.paddingLarge : Theme.paddingLarge * 2)
        contentHeight: height
        flickableDirection: Flickable.VerticalFlick
        opacity: Qt.inputMethod.visible ? 0.0 : 1.0
        Behavior on opacity { FadeAnimation {}}
        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.7; color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity) }
            }
        }

        onOpenChanged: {
            console.log("Landscape? ", _isLandscape)
            playerItem.height = _isLandscape ? 200 * Theme.pixelRatio : 320 * Theme.pixelRatio
            console.log("Docked height: ", playerItem.height)
            console.log("Orientation: ", pageStack.currentOrientation)
        }

        Item {
            id: playerItem
            width: parent.width
            height: _isLandscape ? 280 * Theme.pixelRatio : 320 * Theme.pixelRatio
            visible: radioManager.playbackStatus !== Mpris.Stopped
            focus: false

            Image {
                id: currentRadioIcon
                anchors.top: parent.top
                anchors.left: parent.left
                width: Theme.itemSizeHuge
                height: Theme.itemSizeHuge
                source: radioPlayer.channelIcon
            }
            Label {
                id: currentRadio
                anchors.top: currentRadioIcon.top
                anchors.left: currentRadioIcon.right
                anchors.leftMargin: Theme.paddingMedium
                font.bold: true
                font.pointSize: Theme.fontSizeTiny
                text: radioPlayer.channelName
            }

            IconButton {
                id: playButton
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: currentRadioIcon.verticalCenter
                anchors.verticalCenterOffset: Theme.paddingMedium
                icon.source: radioManager.playbackStatus !== Mpris.Playing ? "image://theme/icon-l-play" : "image://theme/icon-l-pause"
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                onClicked: {
                    console.log("State", radioManager.playbackStatus)
                    console.log("Current service: ", radioManager.currentService)
                    if (radioManager.playbackStatus === Mpris.Playing) {
                        radioManager.pause()
                        app.shouldPlay = false
                    } else {
                        app.playManager.play()
                        app.shouldPlay = true
                    }
                    playerItem.focus = false
                }
            }

            IconButton {
                id: favButton
                visible: false
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.verticalCenter: currentRadioIcon.verticalCenter
                anchors.verticalCenterOffset: Theme.paddingSmall
                icon.source: "image://theme/icon-l-star" //Database.recordIsPresent(currentTrackId)?"image://theme/icon-l-favorite":"image://theme/icon-l-star"
                width: Theme.iconSizeSmall
                height: Theme.iconSizeSmall
                /*onClicked: {
                    console.log("Fav", currentTrackId)
                    if (!Database.recordIsPresent(currentTrackId)) {
                        Database.addToFavorites(currentTrackId, app.radioStation, currentTrackTitle, app.radioIcon);
                        icon.source = "image://theme/icon-l-favorite";
                    }
                }*/
            }

            Label {
                id: currentTrack
                anchors.top: currentRadioIcon.bottom
                anchors.topMargin: Theme.paddingMedium
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: radioPlayer.track
            }
        }
    }
}


