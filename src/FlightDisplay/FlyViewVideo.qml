/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick 2.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0

import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QGCCwQml.QGCCwGimbalController 1.0


Item {
    id:         _root
    visible:    QGroundControl.videoManager.hasVideo

    property Item pipState: videoPipState

    property bool   isLeftBtn: false
    property bool   isPressed: false
    property int startX: 0
    property int startY: 0
    property int disX: 0
    property int disY: 0

    QGCPipState {
        id:         videoPipState
        pipOverlay: _pipOverlay
        isDark:     true

        onWindowAboutToOpen: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay.start()
        }

        onWindowAboutToClose: {
            QGroundControl.videoManager.stopVideo()
            videoStartDelay.start()
        }

        onStateChanged: {
            if (pipState.state !== pipState.fullState) {
                QGroundControl.videoManager.fullScreen = false
            }
        }
    }
    Component.onCompleted:{
//        console.log("QGCCwGimbalController.showCenter---",QGCCwGimbalController.showCenter);
    }

    Image {
        id: cameraCenter
        source: "qrc:/qml/QGCCwGimbal/Controls/CameraCenter.png"
        sourceSize.width: ScreenTools.defaultFontPixelHeight*1.4
        anchors.centerIn: parent
        z:QGroundControl.zOrderTopMost
        visible:QGCCwGimbalController.showCenter && QGroundControl.videoManager.hasVideo &&  QGroundControl.videoManager.decoding

    }

    Timer {
        id:           videoStartDelay
        interval:     2000;
        running:      false
        repeat:       false
        onTriggered:  QGroundControl.videoManager.startVideo()
    }

    //-- Video Streaming
    FlightDisplayViewVideo {
        id:             videoStreaming
        objectName: "childVideoStreaming"
        anchors.fill:   parent
        useSmallFont:   _root.pipState.state !== _root.pipState.fullState
        visible:        QGroundControl.videoManager.isGStreamer
    }
    //-- UVC Video (USB Camera or Video Device)
    Loader {
        id:             cameraLoader
        anchors.fill:   parent
        visible:        !QGroundControl.videoManager.isGStreamer
        source:         QGroundControl.videoManager.uvcEnabled ? "qrc:/qml/FlightDisplayViewUVC.qml" : "qrc:/qml/FlightDisplayViewDummy.qml"
    }

    QGCLabel {
        text: qsTr("Double-click to exit full screen")
        font.pointSize: ScreenTools.largeFontPointSize
        visible: QGroundControl.videoManager.fullScreen && flyViewVideoMouseArea.containsMouse
        anchors.centerIn: parent

        onVisibleChanged: {
            if (visible) {
                labelAnimation.start()
            }
        }

        PropertyAnimation on opacity {
            id: labelAnimation
            duration: 10000
            from: 1.0
            to: 0.0
            easing.type: Easing.InExpo
        }
    }

    Timer{
       id:timerClick
       interval:300
       repeat: false
       onTriggered: {
           if(isPressed){
               videoStartMove.start();
           }
       }
    }
    Timer{
       id:videoStartMove
       interval:50
       repeat: true
       onTriggered:{
           QGCCwGimbalController.joyControl(1,0,-disY*1.6,disX*1.6)
       }
    }
    Timer{
       id:timerSecondClick
       interval:100
       repeat: false
    }

    MouseArea {
        id: flyViewVideoMouseArea
        anchors.fill:       parent
        enabled:            pipState.state === pipState.fullState
        hoverEnabled: true

        cursorShape: "PointingHandCursor"
        acceptedButtons:Qt.LeftButton | Qt.RightButton
        onClicked: {
            if(timerSecondClick.running){
                return
            }
            const rootW = _root.width;
            const rootH = _root.height;

            const lis = videoStreaming.children;
            const videoW = lis[1].getWidth();
            const videoH = lis[1].getHeight();

            var dw = (rootW-videoW)/2

            if(mouse.button === Qt.LeftButton){
                if((QGCCwGimbalController.trackBtnState) && QGCCwGimbalController.trackAvailable){
                    QGCCwGimbalController.trackObject();
                    if((mouseX > dw) && (mouseX < rootW-dw)) {
                        let x = (mouseX-dw)*100/videoW
                        let y = mouseY*100 /videoH
                        var x1 = x-5
                        var y1 = y-5
                        var x2 = x+5
                        var y2 = y+5
                        if(x1<0) { x1=0 }
                        if(y1<0) { y1=0 }
                        if(x2>100) { x2=100 }
                        if(y2>100) { y2=100 }

                        QGCCwGimbalController.videoTrack(x1,y1,x2,y2,0x02);
                    }

                }else if(QGCCwGimbalController.isPointTemp){
                    if((mouseX > dw) && (mouseX < rootW-dw)) {
                        let mx1 = (mouseX-dw)*10000/videoW
                        let my1 = mouseY*10000 /videoH
                        QGCCwGimbalController.spotTempSwitch(mx1,my1,0x01);
                    }
                } else{
                    if((mouseX > dw) && (mouseX < rootW-dw)) {
                        let mx = (mouseX-dw)*10000/videoW
                        let my = mouseY*10000 /videoH
                        QGCCwGimbalController.videoPointTranslation(mx,my);
                    }
                }


            }else if(mouse.button  === Qt.RightButton){
                QGCCwGimbalController.videoTrack("","","","",0x00);
            }
        }
        onPressed: {
            startX=0
            startY=0
            disX= 0
            disY=0
            if(mouse.button === Qt.LeftButton){
                timerClick.start()
                isPressed = true
                isLeftBtn = true
                startX = mouseX
                startY = mouseY
            }
        }
        onPositionChanged:{
            if(isPressed){
                if(QGCCwGimbalController.modeRaw === 3){
                    return
                }
                if(isLeftBtn){
                    disX = mouse.x-startX
                    disY = mouse.y-startY
                }
            }
        }
        onReleased: {
            isLeftBtn = false;
            isPressed = false;
            startX=0
            startY=0
            disX=0
            disY=0
            if(videoStartMove.running){
                videoStartMove.stop()
                QGCCwGimbalController.joyControl(1,0,0,0)

                timerSecondClick.start()
            }
        }

        onDoubleClicked:    QGroundControl.videoManager.fullScreen = !QGroundControl.videoManager.fullScreen
    }


    ProximityRadarVideoView{
        anchors.fill:   parent
        vehicle:        QGroundControl.multiVehicleManager.activeVehicle
    }

    ObstacleDistanceOverlayVideo {
        id: obstacleDistance
        showText: pipState.state === pipState.fullState
    }
}
