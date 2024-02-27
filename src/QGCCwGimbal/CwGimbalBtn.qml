import QtQuick 2.15
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.15
import QGroundControl.ScreenTools           1.0

Item {
    id: control

    property int _horizontalPadding: 0
    property int _verticalPadding: 0
    property bool showHighlight: false
    property string iconSource
    property bool iconMarkShow: false
    property color overlayColor:"#fff"
    property real _idealWidth: ((ScreenTools.isMobile ? ScreenTools.minTouchPixels : ScreenTools.defaultFontPixelWidth * 8))/1.3
    property real   maxHeight

    signal btnClicked()

    implicitWidth: backRect.width
    implicitHeight: backRect.height

    Rectangle {
        id: backRect
        width:     _idealWidth
        height:     width

        radius:ScreenTools.defaultFontPixelWidth / 2
        color: showHighlight ? "#FFF291" :  ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4): Qt.rgba(0,0,0,0.4)

        Image {
            id: icon

            smooth: true
            mipmap: true
            antialiasing: true
            source: control.iconSource

            anchors.centerIn: parent
            height: parent.height * 0.6
            fillMode: Image.PreserveAspectFit
            sourceSize.height: height
        }

        Image {
            id: iconMark

            anchors.right: parent.right
            anchors.rightMargin: ScreenTools.defaultFontPixelWidth*0.3
            anchors.bottom: parent.bottom
            anchors.bottomMargin: ScreenTools.defaultFontPixelWidth*0.3

            height: parent.height * 0.15
            width: parent.height * 0.15

            visible: control.iconMarkShow

            smooth: true
            mipmap: true
            antialiasing: true
            source: "Unfold.png"

            fillMode: Image.PreserveAspectFit
            sourceSize.height: height
        }

        ColorOverlay {
            anchors.fill: icon
            source: icon
            color: overlayColor
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: "PointingHandCursor"
            onClicked: {
                btnClicked()
            }
        }
    }
}
