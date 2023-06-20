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
import QGCCwQml.QGCCwGimbalController 1.0

Item {
    id:         _root
    visible:    QGroundControl.videoManager.hasVideo

    property Item pipState: videoPipState
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

    MouseArea {
        id: flyViewVideoMouseArea
        anchors.fill:       parent
        enabled:            pipState.state === pipState.fullState
        hoverEnabled: true

        cursorShape: "PointingHandCursor"
        acceptedButtons:Qt.LeftButton | Qt.RightButton
        onClicked: {
                 const rootW = _root.width;
                 const rootH = _root.height;

                 const lis = videoStreaming.children;
                 const videoW = lis[1].getWidth();
                 const videoH = lis[1].getHeight();

                 var dw = (rootW-videoW)/2
                 if(mouse.button === Qt.LeftButton){
                     if(QGCCwGimbalController.isTrack && QGCCwGimbalController.trackAvailable){

                         if((mouseX > dw) && (mouseX < rootW-dw)) {
                             var x = (mouseX-dw)*100/videoW
                             var y = mouseY*100 /videoH
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

                     }else{

                         if((mouseX > dw) && (mouseX < rootW-dw)) {

                             var mx = (mouseX-dw)*10000/videoW
                             var my = mouseY*10000 /videoH

//                             console.log("mx:" +mx);
//                             console.log("my:" +my);

                             QGCCwGimbalController.videoPointTranslation(mx,my);
                         }
                     }

                 }else if(mouse.button === Qt.RightButton){
//                     console.log("退出跟踪---");
                     QGCCwGimbalController.videoTrack("","","","",0x00);
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
