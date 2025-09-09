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
    visible:  QGroundControl.videoManager.hasVideo

    property Item pipState: videoPipState

    property real _moveBtnWidth: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 3.4 : ScreenTools.defaultFontPixelWidth * 3.6

    property bool   isLeftBtn: false
    property bool   isPressed: false
    property int startX: 0
    property int startY: 0
    property int disX: 0
    property int disY: 0

    property int offInitY: ScreenTools.isMobile ? -4 : 1

    property real _toolStripWidth

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
    Image {
         id: cameraCenter1
         source: "qrc:/qml/QGCCwGimbal/Controls/CameraCenter.png"
         sourceSize.width: ScreenTools.defaultFontPixelHeight*1.4
         anchors.centerIn: parent
         z:QGroundControl.zOrderTopMost
         visible: false // QGCCwGimbalController.showCenter &&  QGroundControl.videoManager.decoding
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

    Item {
        id: cameraCenter
        z: QGroundControl.zOrderTopMost+1
        visible: QGCCwGimbalController.showCenter &&  QGroundControl.videoManager.decoding
        // 保持原来的尺寸定义
        property var imageSizes: [
            Qt.size(parent.width*0.5, parent.width*0.5),
            Qt.size(parent.width*0.32, parent.width*0.32),
            Qt.size(parent.width*0.05, parent.width*0.05),
            Qt.size(parent.width*0.5, parent.width*0.5),
            Qt.size(parent.width*0.32, parent.width*0.32),
            Qt.size(parent.width*0.05, parent.width*0.05),
        ]

        width: imageSizes[QGCCwGimbalController.iconStyle].width
        height: imageSizes[QGCCwGimbalController.iconStyle].height

        // 动态计算位置
        property real centerX: (_root.width - width) / 2
        property real centerY: (_root.height - height) / 2
        x: centerX + (QGCCwGimbalController ? QGCCwGimbalController.iconOffsetX : 0)
        y: centerY + (QGCCwGimbalController ? QGCCwGimbalController.iconOffsetY : offInitY)

        Connections{
            target:QGCCwGimbalController
            onParamToCenterChanged:{
                if(QGCCwGimbalController.showToCenter){
                    QGCCwGimbalController.iconOffsetX = 0;
                    QGCCwGimbalController.iconOffsetY = offInitY;
                }
            }

            onParamIconStyleChanged:{
                QGCCwGimbalController.reloadOffset();

                if(QGCCwGimbalController.iconOffsetX === 0 && QGCCwGimbalController.iconOffsetY ===offInitY){
                    QGCCwGimbalController.showToCenter = true;
                }else{
                    QGCCwGimbalController.showToCenter = false;
                }


            }
        }

        // 绘制加号 (+)
        Rectangle {
            id: plusHorizontal
            visible: QGCCwGimbalController.iconStyle < 3  // 前3种样式显示加号
            width: parent.width
            height: 1
            color: "white"
            anchors.centerIn: parent
        }

        Rectangle {
            id: plusVertical
            visible: QGCCwGimbalController.iconStyle < 3
            width: 1
            height: parent.height
            color: "white"
            anchors.centerIn: parent
        }
        Rectangle {
            id: xLine1
            visible: QGCCwGimbalController.iconStyle >= 3  // 后3种样式显示叉号
            width: parent.width
            height: 1
            color: "white"
            anchors.centerIn: parent
            rotation: 45
            transformOrigin: Item.Center

        }

        Rectangle {
            id: xLine2
            visible: QGCCwGimbalController.iconStyle >= 3
            width: parent.width
            height: 1
            color: "white"
            anchors.centerIn: parent
            rotation: -45
            transformOrigin: Item.Center
        }

        // 监听尺寸和偏移量变化
        onWidthChanged: updatePosition()
        onHeightChanged: updatePosition()

        function updatePosition() {
            x = Qt.binding(function() { return centerX + (QGCCwGimbalController ? QGCCwGimbalController.iconOffsetX : 0) })
            y = Qt.binding(function() { return centerY + (QGCCwGimbalController ? QGCCwGimbalController.iconOffsetY : offInitY) })
        }

        Component.onCompleted: updatePosition()
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

                    if(QGCCwGimbalController.modeRaw !== 3){
                        QGCCwGimbalController.trackObject();
                    }
                    else{
                      QGCCwGimbalController.videoTrack(0,0,0,0,0x00);
                    }
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

    Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth*7 : ScreenTools.defaultFontPixelWidth*14
        anchors.leftMargin: _toolStripWidth + ScreenTools.defaultFontPixelWidth*2
        z:QGroundControl.zOrderTopMost+2
        visible:  cameraCenter.visible && QGCCwGimbalController.showMoveBtn && (pipState.state === pipState.fullState)
        Rectangle {
            id: controlPanel
            width: ScreenTools.defaultFontPixelWidth* 13.2
            height: ScreenTools.defaultFontPixelWidth*10.6
            implicitWidth: ScreenTools.defaultFontPixelWidth*13
            color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0,0,0,0.35)
//            radius: ScreenTools.defaultFontPixelWidth / 2
            MouseArea {
                anchors.fill: parent
                preventStealing: true
                propagateComposedEvents: false
            }
            // 上按钮
            Button {
                id: upButton
                text: "↑"
                width: _moveBtnWidth
                height: _moveBtnWidth
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: ScreenTools.defaultFontPixelWidth / 2

                background: Rectangle {
                   color:ScreenTools.isMobile ?  Qt.rgba(0,0,0,0.4) : Qt.rgba(1,1,1,0.6)
                }
                contentItem: Text {
                    text: parent.text
                    color: ScreenTools.isMobile ? "#fff" : "#000"
                    font.pointSize:ScreenTools.defaultFontPointSize*1.4
                    font.bold: true
                    opacity: 1
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    QGCCwGimbalController.iconOffsetY　-= 1 // 向上移动1像素
                    QGCCwGimbalController.showToCenter = false;
                }
            }

            // 左按钮
            Button {
                id: leftButton
                text: "←"
                width: _moveBtnWidth
                height: _moveBtnWidth
                anchors.left: parent.left
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth / 2
                anchors.verticalCenter: parent.verticalCenter
                background: Rectangle {
                   color:ScreenTools.isMobile ?  Qt.rgba(0,0,0,0.4) : Qt.rgba(1,1,1,0.6)
                }
                contentItem: Text {
                    text: parent.text
                    color: ScreenTools.isMobile ? "#fff" : "#000"
                    font.pointSize:ScreenTools.defaultFontPointSize*1.4
                    font.bold: true
                    opacity: 1
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    QGCCwGimbalController.iconOffsetX -= 1 // 向左移动1像素
                    QGCCwGimbalController.showToCenter = false;
                }
            }

            // 右按钮
            Button {
                id: rightButton
                text: "→"
                width: _moveBtnWidth
                height: _moveBtnWidth
                anchors.right: parent.right
                anchors.rightMargin: ScreenTools.defaultFontPixelWidth / 2
                anchors.verticalCenter: parent.verticalCenter
                background: Rectangle {
                   color:ScreenTools.isMobile ?  Qt.rgba(0,0,0,0.4) : Qt.rgba(1,1,1,0.6)
                }
                contentItem: Text {
                    text: parent.text
                    color: ScreenTools.isMobile ? "#fff" : "#000"
                    font.pointSize:ScreenTools.defaultFontPointSize*1.4
                    font.bold: true
                    opacity: 1
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    QGCCwGimbalController.iconOffsetX += 1 // 向右移动1像素
                    QGCCwGimbalController.showToCenter = false;
                }
            }

            // 下按钮
            Button {
                id: downButton
                text: "↓"
                width: _moveBtnWidth
                height: _moveBtnWidth
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: ScreenTools.isMobile ?  ScreenTools.defaultFontPixelWidth/2  : ScreenTools.defaultFontPixelWidth
                background: Rectangle {
                   color:ScreenTools.isMobile ?  Qt.rgba(0,0,0,0.4) : Qt.rgba(1,1,1,0.6)
                }
                contentItem: Text {
                    text: parent.text
                    color: ScreenTools.isMobile ? "#fff" : "#000"
                    font.pointSize:ScreenTools.defaultFontPointSize*1.4
                    font.bold: true
                    opacity: 1
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    QGCCwGimbalController.iconOffsetY += 1 // 向下移动1像素
                    QGCCwGimbalController.showToCenter = false;
                }
            }

        }
        Rectangle{
            anchors.top: controlPanel.bottom
            width: controlPanel.width
            height: controlPanel.height/3
            implicitWidth:controlPanel.implicitWidth
//            color: controlPanel.color
            color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.6) : Qt.rgba(0,0,0,0.6)
//            Rectangle{
//                width: parent.width
//                height: 1
//                color:qgcPal.text
//                anchors.top: parent.top
//                anchors.topMargin: ScreenTools.defaultFontPixelWidth/2
//            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: (parent.height-height)/2  //ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth/1.8 : ScreenTools.defaultFontPixelWidth*1.1
                text: qsTr("确定")
                font.pointSize:ScreenTools.defaultFontPointSize
                color: ScreenTools.isMobile ? "#000" : "#fff" // qgcPal.text
            }
            MouseArea {
                anchors.fill: parent
                onClicked:{
                    QGCCwGimbalController.showMoveBtn = false;
                }
            }

        }

    }

}
