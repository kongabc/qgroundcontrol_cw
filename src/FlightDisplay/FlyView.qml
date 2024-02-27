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

    property int _dataShowLabelSize: ScreenTools.isMobile ? ScreenTools.smallFontPointSize*0.8 : ScreenTools.smallFontPointSize
    property int _dataShowValueSize: ScreenTools.isMobile ? ScreenTools.mediumFontPointSize*0.7 : ScreenTools.mediumFontPointSize
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
        x:(_root.width - dataShow2.width*2.3)/2  //new add 3
        z:   QGroundControl.zOrderTopMost
//        visible:  widgetLayer.isVisibleBtn  // QGCCwGimbalController.remoteValid
        Row {
            z: QGroundControl.zOrderTopMost+1   //new add 3
            id: buttonRow
            spacing:  ScreenTools.defaultFontPixelWidth/1.7
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
                                modeSelectRect.visible = false
                                QGCCwGimbalController.modeSwitch(1);
                            }
                        }

                        CwGimbalBtn {
                            iconSource: "Follow.png"
                            showHighlight: QGCCwGimbalController.modeRaw === 0 ? true: false
                            overlayColor: (QGCCwGimbalController.modeRaw === 0 || ScreenTools.isMobile)? "#000" : "#fff"
                            onBtnClicked: {
                                modeSelectRect.visible = false
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
                iconSource: "Track.png"
                visible: QGCCwGimbalController.trackAvailable
                showHighlight: QGCCwGimbalController.modeRaw ===3 ? true : false
                overlayColor:(QGCCwGimbalController.modeRaw ===3 || ScreenTools.isMobile) ? "#000" : "#fff"
                onBtnClicked: {
                    QGCCwGimbalController.trackObject();
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
                iconSource: "PipinPipSwitch.png"
                visible: QGCCwGimbalController.pipinPipSwitchAvailable
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
