import QtQuick 2.2
import Sailfish.Silica 1.0

ListItem {
    contentHeight: Theme.itemSizeExtraLarge
    height: Theme.itemSizeExtraLarge
    width: parent.width
    property string radioIcon
    property alias radioTitleText: radioTitle.text
    property alias radioDescriptionText: radioDescription.text
    Image {
        id: delegateRadioIcon
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.itemSizeLarge
        height: Theme.itemSizeLargee
        sourceSize.width: Theme.itemSizeLarge
        sourceSize.height: Theme.itemSizeLargee
        fillMode: Image.PreserveAspectFit
        source:  radioIcon
        cache: true
        BusyIndicator {
            anchors.centerIn: parent
            running: delegateRadioIcon.status === Image.Ready?false:true
            visible: delegateRadioIcon.status === Image.Ready?false:true
            size: BusyIndicatorSize.Medium
        }
    }
    Label {
        id: radioTitle
        anchors.left: delegateRadioIcon.right
        anchors.leftMargin: Theme.paddingSmall
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingSmall
        font.bold: true
        text: ""
    }
    Text {
        id: radioDescription
        anchors.left: delegateRadioIcon.right
        anchors.leftMargin: Theme.paddingSmall
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingSmall
        anchors.top: radioTitle.bottom
        color: Theme.primaryColor
        wrapMode: Text.WordWrap
        font.pixelSize: 18 * Theme.pixelRatio
        text: ""
    }
}
