import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
    property variant dict: ({})
    property string currentQualityName
    property string currentQualityLink
    allowedOrientations: Orientation.All

    ListModel {
        id: streamQuality
        ListElement { name: "Low"; link: "premium_medium" }
        ListElement { name: "Medium"; link: "premium" }
        ListElement { name: "High"; link: "premium_high" }
    }

    Component.onCompleted: {
        switch (currentQualityLink) {
        case "premium_medium":
            switch0.checked = true
            break
        case "premium":
            switch1.checked = true
            break
        case "premium_high":
            switch2.checked = true
            break
        }
    }


    Column {
        width: parent.width

        DialogHeader { }
        TextSwitch {
            id: switch0
            width: parent.width
            text: streamQuality.get(0).name
            onCheckedChanged: {
                if(checked) {
                    switch1.checked = false
                    switch2.checked = false
                    currentQualityName = streamQuality.get(0).name
                    currentQualityLink = streamQuality.get(0).link
                }
            }
        }
        TextSwitch {
            id: switch1
            width: parent.width
            text: streamQuality.get(1).name
            onCheckedChanged: {
                if(checked) {
                    switch0.checked = false
                    switch2.checked = false
                    currentQualityName = streamQuality.get(1).name
                    currentQualityLink = streamQuality.get(1).link
                }
            }
        }
        TextSwitch {
            id: switch2
            width: parent.width
            text: streamQuality.get(2).name
            onCheckedChanged: {
                if(checked) {
                    switch1.checked = false
                    switch0.checked = false
                    currentQualityName = streamQuality.get(2).name
                    currentQualityLink = streamQuality.get(2).link
                }
            }
        }
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            dict = { name: currentQualityName, link: currentQualityLink }
        }
    }
}

