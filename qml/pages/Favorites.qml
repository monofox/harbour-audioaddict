import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: favPage
    allowedOrientations: Orientation.Portrait
    z: 1

    property string recordForDelete: ""

    PageHeader { id: head; title: 'Favorites' }

    Component.onCompleted: {
        //Database.initialize();
        getFavorites();
    }

    function getFavorites() {
        /*var res = Database.getFavorites();
        if (res.constructor === Array) {
            emptyBase.visible = false;
            for(var i in res) {
                favList.append({id: res[i].track_id, artist: res[i].artist, title: res[i].title, art: res[i].art});
            }
            favListView.visible = true;
        } else {
            emptyBase.visible = true;
            favListView.visible = false;
        }*/
    }

    ListModel {
        id: favList
    }

    Component {
        id: favListComponent
        Rectangle {
            id: baseItem
            width: parent.width
            height: 138
            color: "transparent"
            Image {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                width: 128
                height: 128
                source: art
            }
            Label {
                id: authorName
                anchors.left: icon.right
                anchors.top: icon.top
                anchors.right: parent.right
                anchors.margins: 10
                text: "Artist: " + artist
            }
            Label {
                id: track
                anchors.left: icon.right
                anchors.top: authorName.bottom
                anchors.right: parent.right
                anchors.margins: 10
                text: "Track: " + title
                truncationMode: TruncationMode.Elide
            }

            MouseArea {
                anchors.fill: parent

                onFocusChanged: {
                    if(focus) {
                        baseItem.color = Theme.highlightBackgroundColor
                    } else {
                        baseItem.color = "transparent"
                    }
                }

//                onPressed: {
//                    baseItem.color = Theme.highlightBackgroundColor
//                }
//                onReleased: {
//                    baseItem.color = "transparent"
//                }

                onPressAndHold: {
                    recordForDelete = id;
                    deleteRecord.open();
                }
                onClicked: {
                    var link = "https://www.google.com/search?&q=" + artist + " " + title;
//                    Qt.openUrlExternally(link);
                    pageStack.push(Qt.resolvedUrl("TrackInfo.qml"), {url: link})
                }
            }
        }
    }

    Dialog {
        id: deleteRecord
        DialogHeader {
            title: qsTr("Delete track")
            acceptText: qsTr("Delete")
            cancelText: qsTr("Cancel")
        }
//        title: Text {
//            text: qsTr("Delete track")
//            anchors.centerIn: parent;
//            color: "white"
//            font.pixelSize: 28
//            font.bold: true
//        }
//        message: qsTr("Record will be deleted")
//        acceptButtonText: qsTr("Delete")
//        rejectButtonText: qsTr("Cancel")
        onAccepted: {
            //Database.deleteRecord(recordForDelete);
            favList.clear();
            getFavorites();
            deleteRecord.close()
        }
        onRejected: {
            deleteRecord.close()
        }
    }

    SilicaFlickable {
//        anchors.fill: parent
        anchors.top: head.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        contentHeight: favPage.height
        SilicaListView {
            id: favListView
            anchors.fill: parent
            visible: false
            model: favList
            delegate: favListComponent
            spacing: 5
            clip: true
        }
    }

    Label {
        id: emptyBase
        anchors.centerIn: parent
        visible: true
        text: qsTr("The favorite list is empty")
    }
}
