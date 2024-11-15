/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.12

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Airmap        1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

import QGCCwQml.QGCCwGimbalController 1.0
import QGCCwGimbal.Controls 1.0


Item {
    id: _root

    // These should only be used by MainRootWindow
    property var planController:    _planController
    property var guidedController:  _guidedController

    PlanMasterController {
        id:                     _planController
        flyView:                true
        Component.onCompleted:  start()
    }

    property bool   _mainWindowIsMap:       mapControl.pipState.state === mapControl.pipState.fullState
    property bool   _isFullWindowItemDark:  _mainWindowIsMap ? mapControl.isSatelliteMap : true
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _missionController:     _planController.missionController
    property var    _geoFenceController:    _planController.geoFenceController
    property var    _rallyPointController:  _planController.rallyPointController
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property var    _guidedController:      guidedActionsController
    property var    _guidedActionList:      guidedActionList
    property var    _guidedAltSlider:       guidedAltSlider
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property var    _mapControl:            mapControl

    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    property int    _dataShowLabelSize: ScreenTools.isMobile ? ScreenTools.smallFontPointSize*0.8 : ScreenTools.smallFontPointSize
    property int    _dataShowValueSize: ScreenTools.isMobile ? ScreenTools.mediumFontPointSize*0.7 : ScreenTools.mediumFontPointSize
    property int    _radiusValueSize: ScreenTools.defaultFontPixelWidth / 2


    function _calcCenterViewPort() {
        var newToolInset = Qt.rect(0, 0, width, height)
        toolstrip.adjustToolInset(newToolInset)
        if (QGroundControl.corePlugin.options.instrumentWidget) {
            flightDisplayViewWidgets.adjustToolInset(newToolInset)
        }
    }

    QGCToolInsets {
        id:                     _toolInsets
        leftEdgeBottomInset:    _pipOverlay.visible ? _pipOverlay.x + _pipOverlay.width : 0
        bottomEdgeLeftInset:    _pipOverlay.visible ? parent.height - _pipOverlay.y : 0
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    Item {
        id: root
        anchors.top: parent.top
        anchors.topMargin: ScreenTools.defaultFontPixelWidth/1.4
        x:(_root.width - dataShow2.width*2.3)/2
        z:   QGroundControl.zOrderTopMost
//        visible:  widgetLayer.isVisibleBtn  // QGCCwGimbalController.remoteValid
        Row {
            z: QGroundControl.zOrderTopMost+1
            id: buttonRow
            spacing:  ScreenTools.defaultFontPixelWidth/1.7

            CwGimbalBtn {
                iconSource: "ToCenter.png"
                showHighlight: false
                overlayColor: (showHighlight || ScreenTools.isMobile)? "#000" : "#fff"
                onBtnClicked: {
                    QGCCwGimbalController.toCenter();
                }
            }

            CwGimbalBtn {
                iconSource: "Mode.png"
                iconMarkShow: true
                overlayColor:ScreenTools.isMobile ? "#000" : "#fff"
                onBtnClicked: {
                    modeSelectRect.visible = !modeSelectRect.visible
                }
                Rectangle {
                    id: modeSelectRect
                    anchors.top: parent.bottom
                    anchors.topMargin: ScreenTools.defaultFontPixelWidth/2
                    anchors.left: parent.left
                    visible: false
                    color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0,0,0,0.4)
                    radius: _radiusValueSize
                    height: modeColumn.height
                    width: modeColumn.width

                    Column {
                        id: modeColumn
                        spacing:  ScreenTools.defaultFontPixelWidth * 0.5
                        CwGimbalBtn {
                            iconSource: "Lock.png"
                            showHighlight: QGCCwGimbalController.modeRaw === 1 ? true: false
                            overlayColor: (QGCCwGimbalController.modeRaw === 1 || ScreenTools.isMobile)? "#000" : "#fff"
                            onBtnClicked: {
                                modeSelectRect.visible = QGCCwGimbalController.trackBtnState = false
                                QGCCwGimbalController.modeSwitch(1);
                            }
                        }

                        CwGimbalBtn {
                            iconSource: "Follow.png"
                            showHighlight: QGCCwGimbalController.modeRaw === 0 ? true: false
                            overlayColor: (QGCCwGimbalController.modeRaw === 0 || ScreenTools.isMobile)? "#000" : "#fff"
                            onBtnClicked: {
                                modeSelectRect.visible = QGCCwGimbalController.trackBtnState = false
                                QGCCwGimbalController.modeSwitch(0);
                            }
                        }

                        CwGimbalBtn {
                            iconSource: "Orthoview.png"
                            showHighlight: QGCCwGimbalController.modeRaw === 2 ? true: false
                            overlayColor: (QGCCwGimbalController.modeRaw === 2 || ScreenTools.isMobile) ? "#000" : "#fff"

                            onBtnClicked: {
                                modeSelectRect.visible = false
                                QGCCwGimbalController.modeSwitch(2);
                            }
                        }

                        CwGimbalBtn {
                            iconSource: "Gaze.png"
                            showHighlight: QGCCwGimbalController.modeRaw === 4 ? true: false
                            overlayColor: (QGCCwGimbalController.modeRaw === 4 || ScreenTools.isMobile) ? "#000" : "#fff"
                            onBtnClicked: {
                                modeSelectRect.visible = false
                                QGCCwGimbalController.modeSwitch(4);
                            }
                        }
                    }
                }
            }

            CwGimbalBtn {
               iconSource: "IRCut.png"
               showHighlight: QGCCwGimbalController.btnState & 0x00000200 ? true : false
               overlayColor:(QGCCwGimbalController.btnState & 0x00000200 || ScreenTools.isMobile ) ? "#000" : "#fff"
               onBtnClicked: {
                   QGCCwGimbalController.ircutSwitch();
               }
            }

            CwGimbalBtn {
               iconSource: "Lamp.png"
               showHighlight: QGCCwGimbalController.btnState & 0x00000400 ? true : false
               overlayColor:(QGCCwGimbalController.btnState & 0x00000400 || ScreenTools.isMobile ) ? "#000" : "#fff"
               visible: QGCCwGimbalController.lampAvailable
               onBtnClicked: {
                   QGCCwGimbalController.lampSwitch();
               }
            }

            CwGimbalBtn {
                id:trackBtn
                iconSource: "Track.png"
                visible: QGCCwGimbalController.trackAvailable
                showHighlight: QGCCwGimbalController.trackBtnState ? true : false

                overlayColor:(showHighlight || ScreenTools.isMobile) ? "#000" : "#fff"
                onBtnClicked: {
                    QGCCwGimbalController.trackBtnState = !QGCCwGimbalController.trackBtnState;
                    if(!showHighlight){
                        QGCCwGimbalController.videoTrack(0,0,0,0,0x00);
                    }
                }
            }
            CwGimbalBtn {
                iconSource: "Palette.png"
                visible: QGCCwGimbalController.paletteAvailable
                overlayColor:ScreenTools.isMobile ? "#000" : "#fff"
                onBtnClicked: {
                    QGCCwGimbalController.paletteSwitch();
                }
            }

            CwGimbalBtn {
                visible: QGCCwGimbalController.irCamAvailable
                iconSource: "TempIcon.png"
                iconMarkShow: true
                overlayColor:ScreenTools.isMobile ? "#000" : "#fff"
                onBtnClicked: {
                    temperatureSelectRect.visible = !temperatureSelectRect.visible
                }

                Rectangle {
                    id: temperatureSelectRect
                    anchors.top: parent.bottom
                    anchors.topMargin: ScreenTools.defaultFontPixelWidth/2
                    anchors.left: parent.left
                    color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0,0,0,0.4)
                    radius: _radiusValueSize
                    height: tempColumn.height
                    width: tempColumn.width
                    visible: false

                    Column {
                        id: tempColumn
                        spacing: ScreenTools.defaultFontPixelWidth * 0.5

                        CwGimbalBtn {
                            id:areaTempBtn
                            iconSource: "AreaTemp.png"
                            showHighlight: (QGCCwGimbalController.ircamFlags & 0x40) ? true: false
                            overlayColor:(showHighlight || ScreenTools.isMobile ) ? "#000" : "#fff"
                            onBtnClicked: {
                                temperatureSelectRect.visible = false
                                draggableRect.visible = showHighlight = !showHighlight;

//                                QGCCwGimbalController.isAreaTemp = showHighlight;

                                if(!showHighlight){
                                    QGCCwGimbalController.areaTempShow(0,0,0,0,0x00);
                                }
                            }
                        }

                        CwGimbalBtn {
                            id:spotTempBtn
                            iconSource: "SpotTemp.png"
                            showHighlight:(QGCCwGimbalController.ircamFlags & 0x08) ? true: false
                            overlayColor:(showHighlight || ScreenTools.isMobile) ? "#000" : "#fff"
                            onBtnClicked: {
                                temperatureSelectRect.visible = false
                                showHighlight = !showHighlight;  //|| (QGCCwGimbalController.ircamFlags & 0x08)
                                QGCCwGimbalController.isPointTemp = showHighlight;
                                switchControl.isCheckedOn = true;
                                switchControl.isCheckedOff = false;
                                if(!showHighlight){
                                    QGCCwGimbalController.spotTempSwitch(0,0,0x00);   
                                }
                            }
                        }

                        CwGimbalBtn {
                            iconSource: "TempWarn.png"
                            showHighlight:(QGCCwGimbalController.ircamFlags & 0x20) ? true: false
                            overlayColor:(showHighlight || ScreenTools.isMobile ) ? "#000" : "#fff"
                            onBtnClicked: {
                                temperatureSelectRect.visible = false
                                QGCCwGimbalController.tempWarnSwitch(QGCCwGimbalController.tempWarnH*10,QGCCwGimbalController.tempWarnL*10,false);
                            }
                        }

                        CwGimbalBtn {
                            iconSource: "IsothermLine.png"
                            showHighlight:(QGCCwGimbalController.ircamFlags & 0x10) ? true: false
                            overlayColor:(showHighlight || ScreenTools.isMobile ) ? "#000" : "#fff"
                            onBtnClicked: {
                                temperatureSelectRect.visible = false;
                                QGCCwGimbalController.isoThermSwitch(QGCCwGimbalController.isothermH*10,QGCCwGimbalController.isothermL*10,false);
                            }
                        }
                    }
                }
            }

            CwGimbalBtn {
                iconSource: "PipinPipSwitch.png"
                visible: QGCCwGimbalController.pipSwitchAvailable
                overlayColor:ScreenTools.isMobile ? "#000" : "#fff"
                onBtnClicked: {
                    QGCCwGimbalController.picInPicSwitch();
                }
            }
            CwGimbalBtn {
                iconSource: "Range.png" //Range.png problem
                showHighlight: QGCCwGimbalController.btnState & 0x00000800 ? true : false
                overlayColor: (QGCCwGimbalController.btnState & 0x00000800 || ScreenTools.isMobile) ? "#000" : "#fff"
                visible: QGCCwGimbalController.rangeAvailable
                onBtnClicked: {
                    QGCCwGimbalController.rangeSwitch();
                }
            }

//            CwGimbalBtn {
//                iconSource: "Palette.png"
//                overlayColor: QGCCwGimbalController.calibrateStatusCode === 1 ? "pink" :( QGCCwGimbalController.calibrateStatusCode === 2 ? "blue" :QGCCwGimbalController.calibrateStatusCode === 3 ? "green" : "gray")
//                onBtnClicked: {
//                    QGCCwGimbalController.calibrateFun();
//                }
//            }
        }

        Rectangle{
            id: spotTempRect
            visible: spotTempBtn.showHighlight
            anchors.top: dataShow1.bottom
            anchors.left: dataShow1.left
            anchors.topMargin: ScreenTools.defaultFontPixelWidth/2
            color:ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0,0,0,0.4)
            height : switchBox.height
            width : switchBox.width + ScreenTools.defaultFontPixelWidth
            radius:_radiusValueSize
            Grid {
                id: switchBox
                padding:ScreenTools.defaultFontPixelWidth*0.4
                columns:2
                horizontalItemAlignment:Grid.AlignHCenter
                verticalItemAlignment: Grid.AlignVCenter
                spacing: -ScreenTools.defaultFontPixelWidth
                Row{
                    id:imgRow
                    width:((ScreenTools.isMobile ? ScreenTools.minTouchPixels : ScreenTools.defaultFontPixelWidth * 5))/1.3
                    height:ScreenTools.defaultFontPixelWidth*3.2
                    Image {
                        horizontalAlignment:Image.AlignHCenter
                        id:img
                        source: "SpotTemp2.png"
                        height: parent.height * 0.8
                        smooth: true
                        mipmap: true
                        antialiasing: true
                        fillMode: Image.PreserveAspectFit
                        sourceSize.height: height
                    }
                }

                Row{

                    Rectangle  {
                        id: switchControl
                        width: ScreenTools.defaultFontPixelWidth*5
                        height: ScreenTools.defaultFontPixelWidth*2.2
                        property bool isCheckedOn: (QGCCwGimbalController.isPointTemp) ? true : false
                        property bool isCheckedOff: !isCheckedOn
                        Rectangle{
                            id: bg1
                            width: parent.width/1.8
                            height: parent.height
                            anchors.left: parent.left
                            color: switchControl.isCheckedOn ? "#fff" : "#404040"
                            Text {
                               anchors.centerIn: parent
                               text: "ON"
                               font.pointSize: ScreenTools.isMobile ? ScreenTools.mediumFontPointSize*0.7 : ScreenTools.mediumFontPointSize*0.6
                               font.family:    ScreenTools.normalFontFamily
                               color: switchControl.isCheckedOn ? "black" : "white"
                           }

                           MouseArea{
                                anchors.fill: parent
                                cursorShape: "PointingHandCursor"
                                onClicked: {
                                    switchControl.isCheckedOn = QGCCwGimbalController.isPointTemp = true;
                                    switchControl.isCheckedOff = false;
//                                    QGCCwGimbalController.spotTempOnOffState(true);
                                }
                           }
                        }
                        Rectangle{
                            id: bg2
                            anchors.left: bg1.right
                            width: parent.width/1.8
                            height: parent.height
                            color: switchControl.isCheckedOff ? "#fff" : "#404040"
                            Text {
                                anchors.centerIn: parent
                                text: "OFF"
                                font.family:    ScreenTools.normalFontFamily
                                font.pointSize: ScreenTools.isMobile ? ScreenTools.mediumFontPointSize*0.7 : ScreenTools.mediumFontPointSize*0.6
                                color: switchControl.isCheckedOff ? "black" : "white"
                            }
                            MouseArea{
                                 anchors.fill: parent
                                 enabled: true
                                 cursorShape: "PointingHandCursor"
                                 onClicked: {
                                    switchControl.isCheckedOff = true;
                                    switchControl.isCheckedOn = QGCCwGimbalController.isPointTemp = false;

//                                    QGCCwGimbalController.spotTempOnOffState(false);

                                }
                            }
                        }

                    }

                }

            }
        }

        Rectangle {
            id: dataShow1
            anchors.top: buttonRow.bottom
            anchors.topMargin: ScreenTools.defaultFontPixelWidth/2.2

            radius: _radiusValueSize
            color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0,0,0,0.4)
            height : dataShow1Grid.height
            width : dataShow1Grid.width
            Grid {
                id: dataShow1Grid
                verticalItemAlignment: Grid.AlignBottom

                columns: 2
                padding: ScreenTools.defaultFontPixelWidth * 0.2
                leftPadding: _dataShowLabelSize
                rightPadding: _dataShowValueSize

                Text {
                    font.pointSize: _dataShowLabelSize
                    text: "MODE"
                    font.family:    ScreenTools.normalFontFamily
                    color: qgcPal.text
                }

                Row {
                    id: posMark
                    rightPadding: ScreenTools.defaultFontPixelWidth*0.7
                    spacing: ScreenTools.defaultFontPixelWidth * 0.2

                    Text {
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowLabelSize
                        text: "PITCH"
                        font.family:    ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }

                    Text {
                        width: ScreenTools.defaultFontPixelWidth*3.4
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowValueSize
                        text: QGCCwGimbalController.pitch
                        font.family:    ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }
                }

                Text {
                    id:modeText
                    rightPadding: ScreenTools.defaultFontPixelWidth*0.2
                    font.pointSize: _dataShowValueSize
                    text: QGCCwGimbalController.mode
                    font.family:    ScreenTools.normalFontFamily
                    color: qgcPal.text
                }

                Row {
                    spacing:  ScreenTools.defaultFontPixelWidth * 0.2
                    Text {
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowLabelSize
                        text: "YAW"
                        font.family:    ScreenTools.normalFontFamily
                         color: qgcPal.text
                    }

                    Text {
                        width: ScreenTools.defaultFontPixelWidth*2.8
                        font.pointSize: _dataShowValueSize
                        text: QGCCwGimbalController.yaw
                        font.family:    ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }
                }

            }
        }

        Rectangle {
            id: dataShow2
            anchors.top: dataShow1.top
            anchors.left: dataShow1.right
            anchors.leftMargin:_radiusValueSize
            radius: _radiusValueSize
            height : dataShow2Column.height
            width : dataShow2Column.width
            color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0,0,0,0.4)
            Column {
                id: dataShow2Column
                padding: ScreenTools.defaultFontPixelWidth * 0.2
                leftPadding: _dataShowLabelSize
                rightPadding: ScreenTools.defaultFontPixelWidth *1.2

                Row {
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: _radiusValueSize/3
                        font.pointSize: _dataShowLabelSize
                        text: "RNG(m)"
                        font.family:    ScreenTools.normalFontFamily
                         color: qgcPal.text
                    }

                    Text {
                        width: ScreenTools.defaultFontPixelWidth*6.4
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowValueSize
                        text: QGCCwGimbalController.lazerDis
                        font.family:    ScreenTools.normalFontFamily
                         color: qgcPal.text
                    }
                    Text {
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowValueSize
                        text: QGCCwGimbalController.longitude
                        font.family:    ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }

                }
                Row {
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: _radiusValueSize/2.8
                        font.pointSize: _dataShowLabelSize
                        text: "ASL(m)"
                        font.family:    ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }

                    Text {
                        width: ScreenTools.defaultFontPixelWidth*6.4
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowValueSize
                        text:QGCCwGimbalController.altitude
                        font.family:    ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowValueSize
                        text: QGCCwGimbalController.latitude
                        font.family:  ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }
                }
            }
        }

    }

    FlyViewWidgetLayer {
        id:                     widgetLayer
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.left:           parent.left
        anchors.right:          guidedAltSlider.visible ? guidedAltSlider.left : parent.right
        z:                      _fullItemZorder + 1
        parentToolInsets:       _toolInsets
        mapControl:             _mapControl
        visible:                !QGroundControl.videoManager.fullScreen

        //new add 3
        property bool isVisibleBtn :  true// QGCCwGimbalController.remoteValid
        onIsVisibleBtnChanged: {
            root.visible = isVisibleBtn
        }
    }

    FlyViewCustomLayer {
        id:                 customOverlay
        anchors.fill:       widgetLayer
        z:                  _fullItemZorder + 2
        parentToolInsets:   widgetLayer.totalToolInsets
        mapControl:         _mapControl
        visible:            !QGroundControl.videoManager.fullScreen
    }

    GuidedActionsController {
        id:                 guidedActionsController
        missionController:  _missionController
        actionList:         _guidedActionList
        altitudeSlider:     _guidedAltSlider
    }

    /*GuidedActionConfirm {
        id:                         guidedActionConfirm
        anchors.margins:            _margins
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
        altitudeSlider:             _guidedAltSlider
    }*/

    GuidedActionList {
        id:                         guidedActionList
        anchors.margins:            _margins
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
    }

    //-- Altitude slider
    GuidedAltitudeSlider {
        id:                 guidedAltSlider
        anchors.margins:    _toolsMargin
        anchors.right:      parent.right
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        z:                  QGroundControl.zOrderTopMost
        radius:             ScreenTools.defaultFontPixelWidth / 2
        width:              ScreenTools.defaultFontPixelWidth * 10
        color:              qgcPal.window
        visible:            false
    }

    FlyViewMap {
        id:                     mapControl
        planMasterController:   _planController
        rightPanelWidth:        ScreenTools.defaultFontPixelHeight * 9
        pipMode:                !_mainWindowIsMap
        toolInsets:             customOverlay.totalToolInsets
        mapName:                "FlightDisplayView"
    }

    FlyViewVideo {
        id: videoControl
    }
    Component.onCompleted: {
//        console.log(8888888888888888)
//        console.log(videoControl.width + ";" + videoControl.height)

//        for (let i = 0; i < videoControl.children.length; i++) {
//          let child = videoControl.children[i];
//          if (child.width) {
//              console.log("Child width:", child.width);
//          }
//        }

//        console.log(99999)
//        for (let j = 0; j < videoControl.children[2].children.length; j++) {
//          let child1 = videoControl.children[2].children[j];
//          if (child1.width) {
//              console.log("Child width:", child1.width);
//          }
//        }


//        _videoWidth = videoControl.children[2].children[1].getWidth()
//        _videoHeight = videoControl.children[2].children[1].getHeight()

//        _videoWidth = videoControl.width
//        _videoHeight = videoControl.height

//        console.log(_videoWidth  + "---;---" + _videoHeight)

    }

    Rectangle{
        id:areaTempBg
        width: videoControl.width;
        height:videoControl.height
        color: Qt.rgba(0, 0, 0, 0.5)
        visible: draggableRect.visible
        z: QGroundControl.zOrderTopMost + 10

        MouseArea {
            anchors.fill: parent
            onClicked: { //阻止点击事件穿透
            }
        }
    }

    property real   _circlePointMargin:  -ScreenTools.defaultFontPixelWidth*0.8
    Rectangle {
        id: draggableRect
        width: ScreenTools.defaultFontPixelWidth*20
        height: width
        border.width: ScreenTools.defaultFontPixelWidth*0.1
        border.color: Qt.rgba(1,1, 1, 0.6)
        color: Qt.rgba(0, 0, 0, 0.4)
        visible:  false//areaTempBtn.showHighlight && QGroundControl.videoManager.hasVideo   //QGCCwGimbalController.isAreaTemp //

        property int _videoWidth: videoControl.children[2].children[1].getWidth()
        property int _videoHeight: videoControl.children[2].children[1].getHeight()
        property int _dW: (_root.width-draggableRect._videoWidth)/2

        // 初始位置
        x: (videoControl.width-ScreenTools.defaultFontPixelWidth*20)/2
        y: (videoControl.height-ScreenTools.defaultFontPixelWidth*20)/2
        z: QGroundControl.zOrderTopMost + 13


        // 设置最小宽度和高度
        property int _minWidth: ScreenTools.defaultFontPixelWidth*8
        property int _minHeight: _minWidth

        property int _circleBoxW: ScreenTools.defaultFontPixelWidth*5.6
        property int _circleW: ScreenTools.defaultFontPixelWidth*2.6

        // 添加MouseArea以使矩形可拖动
        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: draggableRect
            onPressed: {
               originalMouseAreaX = draggableRect.x
               originalMouseAreaY=  draggableRect.y
            }

            onReleased: {

                if(draggableRect.x < 0 ){
                   draggableRect.x = 0;
                }

                if((draggableRect.x + draggableRect.width) > _root.width){
                   draggableRect.x = originalMouseAreaX;
                }
                if((draggableRect.x + draggableRect.width + btnBox.width) > _root.width){
                    btnBox.anchors.rightMargin = ScreenTools.defaultFontPixelWidth
                }else{
                    btnBox.anchors.rightMargin = -ScreenTools.defaultFontPixelWidth*8
                }

                if(draggableRect.y < 0){
                    draggableRect.y = 0;
                }
                if((draggableRect.y + draggableRect.height) > _root.height){
                   draggableRect.y = originalMouseAreaY;
                }
            }

            property var originalMouseAreaX
            property var originalMouseAreaY
        }

        // 左上
        Rectangle {
            id: topRect
            width: draggableRect._circleBoxW
            height: draggableRect._circleBoxW
            color: "transparent"
            anchors.top: parent.top
            anchors.topMargin: _circlePointMargin
            anchors.left: parent.left
            anchors.leftMargin:_circlePointMargin
            Drag.active: draggableRect
            Rectangle{
                width: draggableRect._circleW
                height: draggableRect._circleW
                border.color: "#000"
                border.width: 1
                radius: draggableRect._circleW/2
                color: "#fff"
            }
            MouseArea {
                 anchors.fill: parent
                 onPressed: {
                    originalMouseX = mouse.x
                    originalMouseY=  mouse.y
                 }
                onPositionChanged: {

                    let dx = originalMouseX - mouse.x
                    let dy = originalMouseY - mouse.y
                    let newWidth = draggableRect.width + dx
                    let newHeight = draggableRect.height + dy
                    let newX = draggableRect.x - dx
                    let newY = draggableRect.y - dy

                    if(newWidth >= draggableRect._minWidth && newHeight >= draggableRect._minHeight &&
                        newX >= 0  && newY >=0 &&
                        (newX + newWidth) <= _root.width && (newY + newHeight) <= _root.height)
                    {
                        draggableRect.width = newWidth
                        draggableRect.height = newHeight
                        draggableRect.x = newX
                        draggableRect.y = newY
                    }

                }
                onReleased: {
                    if((draggableRect.x + draggableRect.width + btnBox.width) < _root.width){  // (draggableRect._videoWidth + draggableRect._dW)
                        btnBox.anchors.rightMargin = -ScreenTools.defaultFontPixelWidth*8
                        btnBox.anchors.topMargin = ScreenTools.defaultFontPixelWidth*1.2
                    }
                }

               property var originalMouseX
               property var originalMouseY
             }

         }


        // 右上
        Rectangle {
             id: topRightRect
             width: draggableRect._circleBoxW
             height: draggableRect._circleBoxW
             color: "transparent"
             anchors.top: parent.top
             anchors.topMargin: _circlePointMargin
             anchors.right: parent.right
             anchors.rightMargin: _circlePointMargin
             Drag.active: draggableRect
            Rectangle{
                width: draggableRect._circleW
                height: draggableRect._circleW
                border.color: "#000"
                border.width: 1
                radius: draggableRect._circleW/2
                color: "#fff"
                anchors.right:parent.right
            }
            MouseArea {
                 anchors.fill: parent
                 onPressed: {
                    originalMouseX1 = mouse.x
                    originalMouseY1 =  mouse.y
                 }
                onPositionChanged: {
                    let dx = mouse.x - originalMouseX1
                    let dy = originalMouseY1 - mouse.y

                    let newWidth = draggableRect.width + dx
                    let newHeight = draggableRect.height + dy
                    let newY = draggableRect.y - dy

                    if(newWidth >= draggableRect._minWidth  && newHeight >= draggableRect._minHeight &&
                        (draggableRect.x + newWidth) <= _root.width && newY >= 0 &&
                        draggableRect.x >= 0 && (newY + newHeight) <= _root.height )
                    {
                        draggableRect.width = newWidth
                        draggableRect.height = newHeight
                        draggableRect.y = newY
                    }

                    if((draggableRect.x + newWidth + btnBox.width) > _root.width){  //(draggableRect._videoWidth + draggableRect._dW)
                        btnBox.anchors.rightMargin = ScreenTools.defaultFontPixelWidth
                        btnBox.anchors.topMargin = ScreenTools.defaultFontPixelWidth*1.2
                    }

                }
                onReleased: {
                    if((draggableRect.x + draggableRect.width + btnBox.width) < _root.width){ // (draggableRect._videoWidth + draggableRect._dW)
                        btnBox.anchors.rightMargin = -ScreenTools.defaultFontPixelWidth*8
                        btnBox.anchors.topMargin = ScreenTools.defaultFontPixelWidth*1.2
                    }
                }

               property var originalMouseX1
               property var originalMouseY1
             }

         }

        // 左下
        Rectangle {
             id: bottomLeftArea
             width: draggableRect._circleBoxW
             height: draggableRect._circleBoxW
             color: "transparent"
             anchors.left: parent.left
             anchors.bottom: parent.bottom
             anchors.leftMargin: _circlePointMargin
             anchors.bottomMargin: _circlePointMargin
            Drag.active: draggableRect
            Rectangle{
               width: draggableRect._circleW
               height: draggableRect._circleW
               border.color: "#000"
               border.width: 1
               radius: draggableRect._circleW/2
               color: "#fff"
               anchors.bottom:parent.bottom
            }
            MouseArea {
                 anchors.fill: parent
                 onPressed: {
                    originalMouseX2 = mouse.x
                    originalMouseY2 =  mouse.y
                 }
                onPositionChanged: {
                    let dx = originalMouseX2 - mouse.x
                    let dy = mouse.y - originalMouseY2

                    let newWidth = draggableRect.width + dx
                    let newHeight = draggableRect.height + dy
                    let newX = draggableRect.x - dx

                    if(newWidth >= draggableRect._minWidth  && newHeight >= draggableRect._minHeight &&
                        newX >= 0 && (draggableRect.y + newHeight) <= _root.height && (newX + newWidth) <= _root.width && //(newX + newWidth) <= (ScreenTools.isMobile ? draggableRect._videoWidth : (draggableRect._videoWidth + draggableRect._dW)) &&
                        draggableRect.y >= 0)
                    {
                        draggableRect.width = newWidth
                        draggableRect.height = newHeight
                        draggableRect.x = newX
                    }

                }
                onReleased: {

                    if((draggableRect.x + draggableRect.width + btnBox.width) < _root.width){  //(draggableRect._videoWidth + draggableRect._dW)
                        btnBox.anchors.rightMargin = -ScreenTools.defaultFontPixelWidth*8
                        btnBox.anchors.topMargin = ScreenTools.defaultFontPixelWidth*1.2
                    }
                }

               property var originalMouseX2
               property var originalMouseY2
             }

         }

        // 右下
        Rectangle {
             id: bottomRightArea
             width: draggableRect._circleBoxW
             height: draggableRect._circleBoxW
             color: "transparent"
              anchors.right: parent.right
             anchors.bottom: parent.bottom
             anchors.rightMargin: _circlePointMargin
             anchors.bottomMargin: _circlePointMargin
             // 启用拖动
            Drag.active: draggableRect
            Rectangle{
              width: draggableRect._circleW
              height: draggableRect._circleW
              border.color: "#000"
              border.width: 1
              radius: draggableRect._circleW/2
              color: "#fff"
              anchors.right:parent.right
              anchors.bottom:parent.bottom
            }
            MouseArea {
                 anchors.fill: parent
                 onPressed: {
                    originalMouseX3 = mouse.x
                    originalMouseY3 =  mouse.y
                 }
                onPositionChanged: {
                    let dx = mouse.x - originalMouseX3
                    let dy = mouse.y - originalMouseY3
                    let newWidth = draggableRect.width + dx
                    let newHeight = draggableRect.height + dy

                    if(newWidth >= draggableRect._minWidth && newHeight >= draggableRect._minHeight &&
                        (draggableRect.x + newWidth) <= _root.width && (draggableRect.y + newHeight) <= _root.height &&
                        draggableRect.x >= 0 && draggableRect.y >= 0)
                    {
                        draggableRect.width = newWidth
                        draggableRect.height = newHeight
                    }

                    if((draggableRect.x + newWidth + btnBox.width) > _root.width){
                        btnBox.anchors.rightMargin = ScreenTools.defaultFontPixelWidth
                        btnBox.anchors.topMargin = ScreenTools.defaultFontPixelWidth*1.2
                    }
                }
                onReleased: {

                    if((draggableRect.x + draggableRect.width + btnBox.width) < _root.width){
                        btnBox.anchors.rightMargin = -ScreenTools.defaultFontPixelWidth*8
                        btnBox.anchors.topMargin = ScreenTools.defaultFontPixelWidth*1.2
                    }
                }

               property var originalMouseX3
               property var originalMouseY3
             }

        }

        Rectangle{
            id:btnBox
            width: ScreenTools.defaultFontPixelWidth*8
            height: ScreenTools.defaultFontPixelWidth*10
            anchors.right:topRightRect.right
            anchors.rightMargin:-ScreenTools.defaultFontPixelWidth*8
            anchors.top: topRightRect.bottom
            anchors.topMargin: ScreenTools.defaultFontPixelWidth*1.2
            color: "transparent"
            Column {
                anchors.centerIn: btnBox
                spacing: ScreenTools.defaultFontPixelWidth*1.2

                Button {
                    text: "全区域"
                    width: btnBox.width
                    height: ScreenTools.defaultFontPixelWidth * 3
                    font.pointSize:ScreenTools.defaultFontPointSize
                    font.family:ScreenTools.normalFontFamily
                    background: Rectangle {
                        color: "#fff"
                        radius: ScreenTools.defaultFontPixelWidth / 2
                    }
                    onClicked:{

                        draggableRect.width = ScreenTools.isMobile ?_root.width : draggableRect._videoWidth
                        draggableRect.height = draggableRect._videoHeight
                        draggableRect.x = ScreenTools.isMobile ? 0 : (_root.width-draggableRect.width)/2
                        draggableRect.y = 0

                        _circlePointMargin = -ScreenTools.defaultFontPixelWidth*0.7
                        btnBox.anchors.rightMargin = ScreenTools.defaultFontPixelWidth
                        btnBox.anchors.topMargin = ScreenTools.defaultFontPixelWidth*2.4

                    }
                }
                Button {
                    text: "开启测温"
                    width: btnBox.width
                    height: ScreenTools.defaultFontPixelWidth * 3
                    font.pointSize:ScreenTools.defaultFontPointSize
                    font.family:ScreenTools.normalFontFamily
                    background: Rectangle {
                        color: "#fff"
                        radius: ScreenTools.defaultFontPixelWidth / 2
                    }
                    onClicked:{
                        const rootW = _root.width;
                        const rootH = _root.height;
//                        const rootW = videoControl.width;
//                        const rootH = videoControl.height;

                        const videoW = draggableRect._videoWidth;
                        const videoH = draggableRect._videoHeight;
                        var dw = (rootW-videoW)/2

                        var x1 = (draggableRect.x-dw)*100/videoW
                        var y1 = draggableRect.y*100/videoH
                        var x2 = (draggableRect.x + draggableRect.width - dw)*100/videoW
                        var y2 = (draggableRect.y + draggableRect.height)*100/videoH
                        if(x1<0) { x1=0 }
                        if(y1<0) { y1=0 }
                        if(x2>100) { x2=100 }
                        if(y2>100) { y2=100 }
                        QGCCwGimbalController.areaTempShow(x1,y1,x2,y2,0x01);
                    }
                }
                Button {
                    text: "取消编辑"
                    width: btnBox.width
                    height: ScreenTools.defaultFontPixelWidth * 3
                    font.pointSize:ScreenTools.defaultFontPointSize
                    font.family:ScreenTools.normalFontFamily
                    background: Rectangle {
                        color: "#fff"
                        radius: ScreenTools.defaultFontPixelWidth / 2
                    }
                    onClicked:{
                        draggableRect.visible = false
                        draggableRect.width = draggableRect.height = ScreenTools.defaultFontPixelWidth*20
                        draggableRect.x = (videoControl.width-ScreenTools.defaultFontPixelWidth*20)/2
                        draggableRect.y = (videoControl.height-ScreenTools.defaultFontPixelWidth*20)/2
                        btnBox.anchors.rightMargin=-ScreenTools.defaultFontPixelWidth*8
                        btnBox.anchors.topMargin = ScreenTools.defaultFontPixelWidth*1.2
                        if(!(QGCCwGimbalController.ircamFlags & 0x40)){
                            areaTempBtn.showHighlight =false
                        }
//
//                        QGCCwGimbalController.areaTempShow(0,0,0,0,0x00);
                    }
                }
            }
        }
    }


    QGCPipOverlay {
        id:                     _pipOverlay
        anchors.left:           parent.left
        anchors.bottom:         parent.bottom
        anchors.margins:        _toolsMargin
        item1IsFullSettingsKey: "MainFlyWindowIsMap"
        item1:                  mapControl
        item2:                  QGroundControl.videoManager.hasVideo ? videoControl : null
        fullZOrder:             _fullItemZorder
        pipZOrder:              _pipItemZorder
        show:                   !QGroundControl.videoManager.fullScreen &&
                                    (videoControl.pipState.state === videoControl.pipState.pipState || mapControl.pipState.state === mapControl.pipState.pipState)
    }
}
