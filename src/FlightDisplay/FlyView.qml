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

    property real _labelWidth:          ScreenTools.defaultFontPixelWidth * 7
    property real _valueWidth:          ScreenTools.defaultFontPixelWidth * 10
    property real _switchBtnHe:         ScreenTools.defaultFontPixelWidth*3.4
    property real _defaultFont:         ScreenTools.defaultFontPointSize

    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    property int _dataShowLabelSize: ScreenTools.isMobile ? ScreenTools.mediumFontPointSize*0.6 : ScreenTools.mediumFontPointSize*0.8
    property int _dataShowValueSize: ScreenTools.isMobile ? ScreenTools.mediumFontPointSize*0.75 : ScreenTools.mediumFontPointSize*1.2
    property int _radiusValueSize: ScreenTools.defaultFontPixelWidth / 2

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
        x:  ScreenTools.isMobile ? _root.width/4 : _root.width/3.5 //ScreenTools.defaultFontPixelWidth  // _root.width/5 //  (_root.width - _root.width/2)/2  //new add 3   - dataShow2.width*2.3
        z:   QGroundControl.zOrderTopMost
//        anchors.verticalCenter: _root.verticalCenter
//        visible:  widgetLayer.isVisibleBtn  // QGCCwGimbalController.remoteValid
        Row {
            z: QGroundControl.zOrderTopMost+1   //new add 3
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
                iconSource: lockBtn.showHighlight ? "Lock.png" : (followBtn.showHighlight ? "Follow.png" : (orthoviewBtn.showHighlight ? "Orthoview.png" : (gazeBtn.showHighlight ? "Gaze.png" : (fpvBtn.showHighlight ? "FPV.png": "Mode.png")) ))  // "Mode.png"
                iconMarkShow: true
                showHighlight: (lockBtn.showHighlight || followBtn.showHighlight || orthoviewBtn.showHighlight || gazeBtn.showHighlight || fpvBtn.showHighlight) ? true: false
                overlayColor: (showHighlight || ScreenTools.isMobile)? "#000" : "#fff"
                onBtnClicked: {
                    modeSelectRect.visible = !modeSelectRect.visible
                    if(modeSelectRect.visible){
                        popupBox.visible = false;
                    }
                }
                Rectangle {
                    z: QGroundControl.zOrderTopMost+1
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
                            id:lockBtn
                            iconSource: "Lock.png"
                            showHighlight: QGCCwGimbalController.modeRaw === 1 ? true: false
                            overlayColor: (QGCCwGimbalController.modeRaw === 1 || ScreenTools.isMobile)? "#000" : "#fff"
                            onBtnClicked: {
                                modeSelectRect.visible = QGCCwGimbalController.trackBtnState = false
                                QGCCwGimbalController.modeSwitch(1);
                            }
                        }

                        CwGimbalBtn {
                            id:followBtn
                            iconSource: "Follow.png"
                            showHighlight: QGCCwGimbalController.modeRaw === 0 ? true: false
                            overlayColor: (QGCCwGimbalController.modeRaw === 0 || ScreenTools.isMobile)? "#000" : "#fff"
                            onBtnClicked: {
                                modeSelectRect.visible = QGCCwGimbalController.trackBtnState = false
                                QGCCwGimbalController.modeSwitch(0);
                            }
                        }

                        CwGimbalBtn {
                            id:orthoviewBtn
                            iconSource: "Orthoview.png"
                            showHighlight: QGCCwGimbalController.modeRaw === 2 ? true: false
                            overlayColor: (QGCCwGimbalController.modeRaw === 2 || ScreenTools.isMobile) ? "#000" : "#fff"

                            onBtnClicked: {
                                modeSelectRect.visible = false
                                QGCCwGimbalController.modeSwitch(2);
                            }
                        }

                        CwGimbalBtn {
                            id:gazeBtn
                            iconSource: "Gaze.png"
                            showHighlight: QGCCwGimbalController.modeRaw === 4 ? true: false
                            overlayColor: (QGCCwGimbalController.modeRaw === 4 || ScreenTools.isMobile) ? "#000" : "#fff"
                            onBtnClicked: {
                                modeSelectRect.visible = false
                                QGCCwGimbalController.modeSwitch(4);
                            }
                        }

                        CwGimbalBtn {
                            id:fpvBtn
                            iconSource: "FPV.png"
                            showHighlight: QGCCwGimbalController.modeRaw === 5 ? true: false
                            overlayColor: (QGCCwGimbalController.modeRaw === 5 || ScreenTools.isMobile) ? "#000" : "#fff"
                            onBtnClicked: {
                                modeSelectRect.visible = false
                                QGCCwGimbalController.modeSwitch(7);
                            }
                        }
                    }

                }
            }


            CwGimbalBtn {
                id:ircutBtn
               iconSource: "IRCut.png"
               iconMarkShow: true
               showHighlight: QGCCwGimbalController.firmwareVer ?
                                  (QGCCwGimbalController.firmwareVer/10 < 6 ?
                                       (((QGCCwGimbalController.btnState & 0x00000200) || (QGCCwGimbalController.btnState & 0x00000400))? true : false) :
                                       (((QGCCwGimbalController.btnState & 0x00000200) || (QGCCwGimbalController.ispEffect === 2) || (QGCCwGimbalController.btnState & 0x00000400)) ? true : false)) :
                                  (((QGCCwGimbalController.btnState & 0x00000200) || (QGCCwGimbalController.btnState & 0x00000400))? true : false)

               overlayColor:(showHighlight || ScreenTools.isMobile ) ? "#000" : "#fff"
               visible: QGCCwGimbalController.iRCutAvailable || (QGCCwGimbalController.devideType == "D-80N") || QGCCwGimbalController.lampAvailable
               onBtnClicked: {
                   popupBox.visible = !popupBox.visible
                   if(popupBox.visible){
                        modeSelectRect.visible = temperatureSelectRect.visible = false
                   }

               }
            }

            Popup {
                id: popupBox
                x: ircutBtn.x + ircutBtn.width/2 - width/2
                y: ircutBtn.y + ircutBtn.height*1.3
                width: _labelWidth*1.2 + _valueWidth + _margins*4.8
                height:{
                    var h = 0;
                    if (nightModeGrid.visible) h += _switchBtnHe;
                    if (fullColorGrid.visible) h += _switchBtnHe + contentColumn.spacing;
                    if (lampGrid.visible) h += _switchBtnHe + contentColumn.spacing;
                    return h + contentColumn.padding*2;
                } // (QGCCwGimbalController.devideType == "D-80N") ? (_switchBtnHe*3 + _margins*8) :(QGCCwGimbalController.lampAvailable ? (_switchBtnHe*2 + _margins*6) : (_switchBtnHe + _margins*3))
                padding: 0
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                visible: false
                background: Rectangle {
                    color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.6) : Qt.rgba(0,0,0,0.6)
                    radius: 4

                    // 正三角部分
                    Canvas {
                        id: triangle
                        width: 20
                        height: 10
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                            topMargin: -10
                        }
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.fillStyle = ScreenTools.isMobile ? Qt.rgba(1,1,1,0.6) : Qt.rgba(0,0,0,0.6)
                            ctx.strokeStyle = "transparent"
                            ctx.lineWidth = 0

                            ctx.beginPath()
                            ctx.moveTo(width/2, 0)
                            ctx.lineTo(0, height)
                            ctx.lineTo(width, height)
                            ctx.closePath()

                            ctx.fill()
                            ctx.stroke()

                        }
                    }
                }
                contentItem: Column {
                    id: contentColumn
                    padding: _margins*1.6
                    spacing: _margins*2

                    GridLayout{
                        id: nightModeGrid
                        columns: 2
                        visible:  QGCCwGimbalController.iRCutAvailable
                        QGCLabel {
                            Layout.preferredWidth:  _labelWidth*1.2
                            text: qsTr("IRCUT")
                            font.pointSize:_defaultFont
                        }
                        Rectangle{
                            Layout.preferredWidth:  _valueWidth
                            height: _switchBtnHe
                            SwitchModule{
                                externalState:(QGCCwGimbalController.btnState & 0x00000200) ? true : false
//                                isOn:Qt.binding(() => (QGCCwGimbalController.btnState & 0x00000200) ? true : false)
                                onText:qsTr("ON")
                                offText:qsTr("OFF")
                                isRes:true
                                onOnOffClick:{
                                    if(isOn){
                                        QGCCwGimbalController.ircutSwitch(0x01);
                                    }else{
                                        QGCCwGimbalController.ircutSwitch(0x00);
                                    }
                                }
                            }
                        }
                    }

                    GridLayout{
                         id: fullColorGrid
                        columns: 2
                        visible: QGCCwGimbalController.devideType == "D-80N"
                        QGCLabel {
                            Layout.preferredWidth: _labelWidth*1.2
                            text: qsTr("Night Scene")
                            font.pointSize:_defaultFont
                        }
                        Rectangle{
                            Layout.preferredWidth:  _valueWidth
                            height: _switchBtnHe
                            SwitchModule{
                                externalState: (QGCCwGimbalController.ispEffect === 2) ? true : false
                                onText:qsTr("ON")
                                offText:qsTr("OFF")
                                isRes:true
                                onOnOffClick:{
                                    if(isOn){
                                       QGCCwGimbalController.ispSwitch(0x02);
                                    }else{
                                       QGCCwGimbalController.ispSwitch(0x01);
                                    }
                                }
                            }

                        }
                    }

                    GridLayout{
                        id: lampGrid
                        columns: 2
                        visible: QGCCwGimbalController.lampAvailable
                        QGCLabel {
                            Layout.preferredWidth:  _labelWidth*1.2
                            text: qsTr("Lamp")
                            font.pointSize:_defaultFont
                        }
                        Rectangle{
                            Layout.preferredWidth:  _valueWidth
                            height: _switchBtnHe
                            SwitchModule{
                                externalState: (QGCCwGimbalController.btnState & 0x00000400) ? true : false
                                onText:qsTr("ON")
                                offText:qsTr("OFF")
                                isRes:true
                                onOnOffClick:{
                                    if(isOn){
                                        QGCCwGimbalController.lampSwitch(0x01);
                                    }else{
                                        QGCCwGimbalController.lampSwitch(0x00);
                                    }

                                }
                            }

                        }
                    }

                }

            }


            CwGimbalBtn {
                id:trackBtn
                iconSource: "Track.png"
                visible: QGCCwGimbalController.firmwareVer ? (QGCCwGimbalController.firmwareVer/10 < 6 ? QGCCwGimbalController.trackAvailable : (QGCCwGimbalController.trackAvailable && QGCCwGimbalController.recognizeSta === 1)) : QGCCwGimbalController.trackAvailable
                showHighlight: QGCCwGimbalController.trackBtnState ? true : false

                overlayColor:(showHighlight || ScreenTools.isMobile) ? "#000" : "#fff"
                onBtnClicked: {
                    QGCCwGimbalController.trackBtnState = !QGCCwGimbalController.trackBtnState;
                    if(!showHighlight){
                        QGCCwGimbalController.videoTrack(0,0,0,0,0x00);
                    }
                }
            }

//            CwGimbalBtn {
//                id:mapPointBtn
//                iconSource: "MapPoint.png"
//                showHighlight: false//QGCCwGimbalController.trackBtnState ? true : false
//                overlayColor:(showHighlight || ScreenTools.isMobile) ? "#000" : "#fff"
//                onBtnClicked: {
//                }
//            }

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
                    if(temperatureSelectRect.visible){
                        popupBox.visible = false;
                    }
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
                            showHighlight:(QGCCwGimbalController.ircamFlags & 0x40) ? true: false
                            overlayColor:(showHighlight || ScreenTools.isMobile ) ? "#000" : "#fff"
                            onBtnClicked: {
                                temperatureSelectRect.visible = false;
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
            anchors.top: buttonRow.bottom
            anchors.left: buttonRow.left
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

    }

    Rectangle{
        id:photoVideoControlBox
        width: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth *14 : ScreenTools.defaultFontPixelWidth * 14
        height: ScreenTools.isMobile ? (timeRec.visible ? ScreenTools.defaultFontPixelWidth* 5 : ScreenTools.defaultFontPixelWidth* 3.8) : ScreenTools.defaultFontPixelWidth* 7.2 // 5.2
        anchors.right: parent.right
        anchors.rightMargin: ScreenTools.isMobile ? 0 : ScreenTools.defaultFontPixelWidth * 2
        anchors.bottom: infoCont.top
        anchors.bottomMargin: ScreenTools.isMobile ?  ScreenTools.defaultFontPixelWidth*0.8 : ScreenTools.defaultFontPixelWidth * 3
        z: QGroundControl.zOrderTopMost
        color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0,0,0,0.35)
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: false
            onClicked: {
               console.log("Rectangle clicked");
               // 阻止事件继续传递
               mouse.accepted = true;
            }
            onPressed: mouse.accepted = true;
            onReleased: mouse.accepted = true;
        }
        ColumnLayout  {
            anchors.fill: parent
            spacing: 0
            anchors.topMargin: _margins/2
            RowLayout  {
                Layout.alignment: Qt.AlignHCenter
                width: parent.width
                Layout.preferredHeight: parent.height * 0.62
                spacing: 0
                Rectangle{
                    Layout.preferredWidth: photoVideoControlBox.width/3
                    Layout.fillHeight: true
                    color: "transparent"
//                    border.width: 1
                    Image {
                        id:vRecord
                        source: (QGCCwGimbalController.btnState & 0x00000100) ? "qrc:/qml/QGCCwGimbal/Controls/VideoRecordActive.png" : "qrc:/qml/QGCCwGimbal/Controls/VideoRecord.png"
                        sourceSize.width: ScreenTools.defaultFontPixelHeight*1.5
                        anchors.centerIn: parent
                    }
                    MouseArea{
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"

                        onClicked: {
                            QGCCwGimbalController.takeRecording();
                        }
                    }
                }

                Rectangle{
                    Layout.preferredWidth:  photoVideoControlBox.width/3
                    Layout.fillHeight: true
                    color: "transparent"
                    Text {
                        id:txtCont
                        text: "REC"
                        font.pointSize:ScreenTools.isMobile ? ScreenTools.defaultFontPointSize*1.2 : ScreenTools.defaultFontPointSize*1.4
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: qgcPal.text// (QGCCwGimbalController.btnState & 0x00000100) ? "#ff0000" : qgcPal.text
                        visible: !txtCont2.visible
                        font.bold: ScreenTools.isMobile ? false : true

                        SequentialAnimation on color {
                            running: (QGCCwGimbalController.btnState & 0x00000100)
                            loops: Animation.Infinite
                            onRunningChanged: {
                                if (!running) txtCont.color = qgcPal.text
                            }
                            ColorAnimation { to: "#ff0000"; duration: 600 ;easing.type: Easing.InOutQuad}
                            ColorAnimation { to: qgcPal.text; duration: 600 ;easing.type: Easing.InOutQuad}
                        }

                    }

                    Text {
                        id:txtCont2
                        text: "PIC"
                        font.pointSize: ScreenTools.isMobile ? ScreenTools.defaultFontPointSize*1.2 : ScreenTools.defaultFontPointSize*1.4
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color:"#ff0000"
                        visible: false
                        font.bold: ScreenTools.isMobile ? false : true
                    }
                }
                Rectangle{
                    Layout.preferredWidth:  photoVideoControlBox.width/3
                    Layout.fillHeight: true
                    color: "transparent"
                    Image {
                        id:tPhoto
                        anchors.centerIn: parent
                        source: "qrc:/qml/QGCCwGimbal/Controls/TakePhoto.png"
                        sourceSize.width: ScreenTools.defaultFontPixelHeight*1.4
                    }
                    MouseArea{
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"
                        onPressed: {
                            tPhoto.source = "qrc:/qml/QGCCwGimbal/Controls/TakePhotoActive.png"
                            txtCont2.visible = true;
                        }
                        onReleased: {
                            QGCCwGimbalController.takePhoto();
                            tPhoto.source = "qrc:/qml/QGCCwGimbal/Controls/TakePhoto.png"
                            txtCont2.visible = false;
                        }
                    }
                }

            }
            Rectangle{
                id:timeRec
                width: parent.width
                Layout.preferredHeight: parent.height * 0.38
                color: "transparent"
                visible:isNaN(QGCCwGimbalController.firmwareVer) ? false :((QGCCwGimbalController.firmwareVer/10 >= 6) ? true : false)
                Text{
                    id:timeTxt
                    font.pointSize:ScreenTools.isMobile ? ScreenTools.defaultFontPointSize*1.1 : ScreenTools.defaultFontPointSize*1.4
                    horizontalAlignment: Text.AlignHCenter

                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter

                    color: qgcPal.text
                    text: {
                        if (QGCCwGimbalController.recTime <= 0) {
                           return "00:00:00";
                        }

                        let h = Math.floor(QGCCwGimbalController.recTime / 3600)
                        let m = Math.floor((QGCCwGimbalController.recTime % 3600) / 60)
                        let s = QGCCwGimbalController.recTime % 60

    //                    return Qt.formatTime(new Date(0, 0, 0, h, m, s), "hh:mm:ss")

                        return ("00" + h).slice(-2) + ":" + ("00" + m).slice(-2) + ":" + ("00" + s).slice(-2);

                    }
                }
            }


        }
    }

    //info
    Rectangle{
       id: infoCont
       width:ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 14 : ((QGCCwGimbalController.modeRaw === 0 || QGCCwGimbalController.modeRaw === 8) ? ScreenTools.defaultFontPixelWidth * 19.8 : ScreenTools.defaultFontPixelWidth * 18.6)  // 20.1
//       height:ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 20.5 : ScreenTools.defaultFontPixelWidth * 36 //topTab.height + valInfo.height
       implicitHeight: topTab.height + valInfo.implicitHeight
       color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.6) : Qt.rgba(0,0,0,0.6)
       anchors.bottom: parent.bottom
       anchors.right: parent.right
       z:   QGroundControl.zOrderTopMost
       visible: root.visible

       Rectangle{
           id:topTab
           width: parent.width
           height: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth*2 : ScreenTools.defaultFontPixelWidth*3.6
           color: "#454545" // ScreenTools.isMobile ? Qt.rgba(1,1,1,0.9) : Qt.rgba(0,0,0,0.9) //
           Row{
               anchors.fill: parent
               Item{
                   width: parent.width/2
                   height: parent.height
                   Text{
                       id:tarText
                       text: qsTr("Target")
                       width: parent.width
                       height: parent.height
                       horizontalAlignment: Text.AlignHCenter
                       verticalAlignment: Text.AlignVCenter
                       font.pointSize: ScreenTools.isMobile ? ScreenTools.defaultFontPointSize*0.8 : ScreenTools.defaultFontPointSize*1.4
                       color: "#fffc00"// "#FFF291"// qgcPal.text
                       font.bold: true
                   }
                   MouseArea{
                       anchors.fill: parent
                       onClicked: { //阻止点击事件穿透
                           if(targetVal.visible){
                               return;
                           }
                           tarText.color = "#fffc00";
                           carText.color = qgcPal.text;
                           targetVal.visible = true;
                           carrierVal.visible = false;
                       }
                   }
               }
               Item{
                   width: parent.width/2
                   height: parent.height
                   visible: false
                   Text{
                       id:carText
                       text: qsTr("Carrier")
                       width: parent.width
                       height: parent.height
                       horizontalAlignment: Text.AlignHCenter
                       verticalAlignment: Text.AlignVCenter
                       font.pointSize: ScreenTools.isMobile ? ScreenTools.defaultFontPointSize*0.8 : ScreenTools.defaultFontPointSize*1.4
                       color: qgcPal.text
                       font.bold: true
                   }
                   MouseArea{
                       anchors.fill: parent
                       onClicked: { //阻止点击事件穿透
                            if(carrierVal.visible){
                                return;
                            }

                           tarText.color = qgcPal.text;
                           carText.color = "#fffc00";
                           targetVal.visible = false;
                           carrierVal.visible = true;
                       }
                   }
               }
           }
       }
//       Flickable {
//           width: parent.width
//           height: parent.height - topTab.height
//           contentHeight: valInfo.height
//           clip: true
           Rectangle{
               id:valInfo
               width:parent.width
               implicitHeight: childrenRect.height
//               {
//                          // 计算所有子项的总高度
//                          let totalHeight = 0
//                          if (targetVal.visible) totalHeight += targetVal.implicitHeight
//                          if (carrierVal.visible) totalHeight += carrierVal.implicitHeight
//                          totalHeight += showVal.implicitHeight
//                          return totalHeight
//                      }
               anchors.top: topTab.bottom
               anchors.bottomMargin: _radiusValueSize
               color:"transparent"
               Grid{
                   id:targetVal
//                   implicitHeight: childrenRect.height + padding * 2
                   columns: 1
                   padding: 10
                   visible: true
                   spacing: ScreenTools.isMobile ? (-ScreenTools.defaultFontPixelWidth*0.6) : 0
                   Row{

                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "E: "
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text:QGCCwGimbalController.longitude
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }

                   Row{
                       Layout.alignment: Qt.AlignVCenter
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "N: "
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text: QGCCwGimbalController.latitude
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }
                   Row{

                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "ASL: "
                           font.family:  ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }

                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text:QGCCwGimbalController.altitude + "m"
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }

               }

               Grid{
                   id:carrierVal
//                   implicitHeight: childrenRect.height + padding * 2
                   columns: 1
                   padding: 10
                   visible: false
                   spacing: ScreenTools.isMobile ? (-ScreenTools.defaultFontPixelWidth*0.6) : 0
                   Row{
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "E: "
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text:"888.9999999" //QGCCwGimbalController.longitude
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }

                   Row{
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "N: "
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text: "32.0000000" // QGCCwGimbalController.latitude
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }
                   Row{

                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "ASL: "
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }

                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text: "300.5" + "m" // QGCCwGimbalController.altitude + "m"
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }

               }

               Grid{
                   id:showVal
//                   implicitHeight: childrenRect.height + padding * 2
                   columns: 1
                   padding: 10
                   anchors.top: targetVal.bottom
                   anchors.topMargin: ScreenTools.isMobile ? (-ScreenTools.defaultFontPixelWidth*0.8 ): (-ScreenTools.defaultFontPixelWidth*0.8)
                   spacing: ScreenTools.isMobile ? (-ScreenTools.defaultFontPixelWidth*0.6) : 0
                   Row{
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "Mode: "
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text:QGCCwGimbalController.mode
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }

                   Row{
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "EO/IR: "
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }

                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text:QGCCwGimbalController.formatFloat("%.1f",(QGCCwGimbalController.zoomvalue / 10)) //(QGCCwGimbalController.zoomvalue / 10).toLocaleString(Qt.locale(), 'f', 1)
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text:"X" +" / "
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text: QGCCwGimbalController.formatFloat("%.1f",(QGCCwGimbalController.zoomvalue2 / 10))  //((QGCCwGimbalController.zoomvalue2 / 10)+ Number.EPSILON).toFixed(1)
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text:"X"
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }

                   Row{
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "RNG: "
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text: QGCCwGimbalController.lazerDis + "m"
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }

                   Row {

                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "Pitch: "
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }

                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text: ((((QGCCwGimbalController.pitch)/10)+ Number.EPSILON)* 10).toFixed(1) // (QGCCwGimbalController.pitch).toFixed(1)
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }
                   Row {
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "Yaw: "
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }

                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text: ((((QGCCwGimbalController.yaw)/10)+ Number.EPSILON)* 10).toFixed(1) //(QGCCwGimbalController.yaw).toFixed(1)
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }

                   Row {
                       visible: isNaN(QGCCwGimbalController.firmwareVer) ? false :((QGCCwGimbalController.firmwareVer/10 >= 6) ? true : false)
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "CPU: "
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }

                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text: QGCCwGimbalController.cpuTemp < -1000 ? (0 +"℃")  : (QGCCwGimbalController.formatFloat("%.2f",(QGCCwGimbalController.cpuTemp/10)) +"℃") //(((QGCCwGimbalController.cpuTemp/10)+ Number.EPSILON).toFixed(2)  +"℃")
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }
                   Row{
                       visible: isNaN(QGCCwGimbalController.firmwareVer) ? false :((QGCCwGimbalController.firmwareVer/10 >= 6) ? true : false)
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowValueSize
                           text:QGCCwGimbalController.sdRemainCapacity < 0 ? 0 : QGCCwGimbalController.formatFloat("%.2f",QGCCwGimbalController.sdRemainCapacity)//(QGCCwGimbalController.sdRemainCapacity).toFixed(2)
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                       Text {
                           anchors.verticalCenter: parent.verticalCenter
                           font.pointSize: _dataShowLabelSize
                           text: "GB"
                           font.family:    ScreenTools.normalFontFamily
                           color: qgcPal.text
                       }
                   }

               }
           }
//       }
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
//        property bool isVisibleBtn :  true// QGCCwGimbalController.remoteValid
        isVisibleBtn :  true
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
        _toolStripWidth:widgetLayer._toolStripWidth
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
        visible: false//areaTempBtn.showHighlight && QGroundControl.videoManager.hasVideo   //QGCCwGimbalController.isAreaTemp //

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
                    btnBox.anchors.rightMargin = ScreenTools.defaultFontPixelWidth*2
                }else{
                    btnBox.anchors.rightMargin = -ScreenTools.defaultFontPixelWidth*9
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
                        btnBox.anchors.rightMargin = -ScreenTools.defaultFontPixelWidth*9
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
                        btnBox.anchors.rightMargin = ScreenTools.defaultFontPixelWidth*2
                        btnBox.anchors.topMargin = ScreenTools.defaultFontPixelWidth*1.2
                    }

                }
                onReleased: {
                    if((draggableRect.x + draggableRect.width + btnBox.width) < _root.width){ // (draggableRect._videoWidth + draggableRect._dW)
                        btnBox.anchors.rightMargin = -ScreenTools.defaultFontPixelWidth*9
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
                        btnBox.anchors.rightMargin = -ScreenTools.defaultFontPixelWidth*9
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
                        btnBox.anchors.rightMargin = ScreenTools.defaultFontPixelWidth*2
                        btnBox.anchors.topMargin = ScreenTools.defaultFontPixelWidth*1.2
                    }
                }
                onReleased: {

                    if((draggableRect.x + draggableRect.width + btnBox.width) < _root.width){
                        btnBox.anchors.rightMargin = -ScreenTools.defaultFontPixelWidth*9
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
            anchors.rightMargin:-ScreenTools.defaultFontPixelWidth*9
            anchors.top: topRightRect.bottom
            anchors.topMargin: ScreenTools.defaultFontPixelWidth*1.2
            color: "transparent"
            Column {
                anchors.centerIn: btnBox
                spacing: ScreenTools.defaultFontPixelWidth*1.2

                Button {
                    text: qsTr("Entire Area")
                    width: ScreenTools.defaultFontPixelWidth*9
                    height: ScreenTools.defaultFontPixelWidth * 3
                    font.pointSize:ScreenTools.defaultFontPointSize
                    font.family:ScreenTools.normalFontFamily
                    background: Rectangle {
                        color: "#fff"
                        radius: ScreenTools.defaultFontPixelWidth / 2
                    }
                    onClicked:{
                        draggableRect.width = ScreenTools.isMobile ?_root.width : draggableRect._videoWidth
                        draggableRect.height =  draggableRect._videoHeight   //_root.height //
                        draggableRect.x = ScreenTools.isMobile ? 0 : (_root.width-draggableRect.width)/2
                        draggableRect.y = 0

                        _circlePointMargin = -ScreenTools.defaultFontPixelWidth*0.7
                        btnBox.anchors.rightMargin = ScreenTools.defaultFontPixelWidth*2
                        btnBox.anchors.topMargin = ScreenTools.defaultFontPixelWidth*2.4

                    }
                }
                Button {
                    text:qsTr ("Start Temp")
                    width: ScreenTools.defaultFontPixelWidth*9
                    height: ScreenTools.defaultFontPixelWidth * 3
                    font.pointSize:ScreenTools.defaultFontPointSize
                    font.family:ScreenTools.normalFontFamily
                    background: Rectangle {
                        color: "#fff"
                        radius: ScreenTools.defaultFontPixelWidth / 2
                    }
                    onClicked:{

//                        QGCCwGimbalController.areaTempShow(0,0,0,0,0x00);  //待测。。

                        const rootW = _root.width;
                        const rootH = _root.height;

                        const videoW = draggableRect._videoWidth;
                        const videoH = draggableRect._videoHeight;
                        var dw = (rootW-videoW)/2

                        var x1 = (draggableRect.x-dw)*100/videoW
                        var y1 = draggableRect.y*100/videoH  //rootH  //
                        var x2 = (draggableRect.x + draggableRect.width - dw)*100/videoW
                        var y2 = (draggableRect.y + draggableRect.height)*100/videoH  //rootH  //
                        if(x1<0) { x1=0 }
                        if(y1<0) { y1=0 }
                        if(x2>100) { x2=100 }
                        if(y2>100) { y2=100 }

                        QGCCwGimbalController.areaTempShow(x1,y1,x2,y2,0x01);
                    }
                }
                Button {
                    text: qsTr("Cancel")
                    width: ScreenTools.defaultFontPixelWidth*9
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
                        btnBox.anchors.rightMargin=-ScreenTools.defaultFontPixelWidth*9
                        btnBox.anchors.topMargin = ScreenTools.defaultFontPixelWidth*1.2

//                        if(!(QGCCwGimbalController.ircamFlags & 0x40)){   //如果点击开启测温，需要等待2秒按钮返回
//                            areaTempBtn.showHighlight = false
//                        }

//                        QGCCwGimbalController.areaTempShow(0,0,0,0,0x00);

//                        delayTimer.start();
                    }
                }
                Timer {
                     id: delayTimer
                     interval: 3000
                     repeat: false
                     onTriggered: {
                         if(!(QGCCwGimbalController.ircamFlags & 0x40)){   //如果点击开启测温，需要等待2秒按钮返回
                             areaTempBtn.showHighlight = false
                         }
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
