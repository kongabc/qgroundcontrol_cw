﻿/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.11
import QtQuick.Controls 2.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0

import QtQuick.Layouts              1.12
import QtQuick.Window 2.15
import QGCCwQml.QGCCwGimbalController 1.0
import QGCCwGimbal.Controls 1.0

Rectangle {
    id:         _root
    color:      qgcPal.toolbarBackground
    width:      _idealWidth < repeater.contentWidth ? repeater.contentWidth : _idealWidth
    height:     Math.min(maxHeight, toolStripColumn.height + (flickable.anchors.margins * 2))
    radius:     ScreenTools.defaultFontPixelWidth / 2

    property alias  model:              repeater.model
    property real   maxHeight           ///< Maximum height for control, determines whether text is hidden to make control shorter
    property alias  title:              titleLabel.text

    property var _dropPanel: dropPanel

    property int _dataShowLabelSize: ScreenTools.smallFontPointSize
    property int _dataShowValueSize: ScreenTools.mediumFontPointSize
    property int _radiusValueSize: ScreenTools.defaultFontPixelWidth / 2

    function simulateClick(buttonIndex) {
        buttonIndex = buttonIndex + 1 // skip over title label
        var button = toolStripColumn.children[buttonIndex]
        if (button.checkable) {
            button.checked = !button.checked
        }
        button.clicked()
    }

    // Ensure we don't get narrower than content
    property real _idealWidth: (ScreenTools.isMobile ? ScreenTools.minTouchPixels : ScreenTools.defaultFontPixelWidth * 8) + toolStripColumn.anchors.margins * 2

    signal dropped(int index)

    DeadMouseArea {
        anchors.fill: parent
    }

    QGCFlickable {
        id:                 flickable
        anchors.margins:    ScreenTools.defaultFontPixelWidth * 0.4
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        height:             parent.height
        contentHeight:      toolStripColumn.height
        flickableDirection: Flickable.VerticalFlick
        clip:               true

        Column {
            id:             toolStripColumn
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        ScreenTools.defaultFontPixelWidth * 0.25

            QGCLabel {
                id:                     titleLabel
                anchors.left:           parent.left
                anchors.right:          parent.right
                horizontalAlignment:    Text.AlignHCenter
                font.pointSize:         ScreenTools.smallFontPointSize
                visible:                title != ""
            }

            Repeater {
                id: repeater

                ToolStripHoverButton {
                    id:                 buttonTemplate
                    anchors.left:       toolStripColumn.left
                    anchors.right:      toolStripColumn.right
                    height:             width
                    radius:             ScreenTools.defaultFontPixelWidth / 2
                    fontPointSize:      ScreenTools.smallFontPointSize
                    toolStripAction:    modelData
                    dropPanel:          _dropPanel
                    onDropped:          _root.dropped(index)

                    onCheckedChanged: {
                        // We deal with exclusive check state manually since usinug autoExclusive caused all sorts of crazt problems
                        if (checked) {
                            for (var i=0; i<repeater.count; i++) {
                                if (i != index) {
                                    var button = repeater.itemAt(i)
                                    if (button.checked) {
                                        button.checked = false
                                    }
                                }
                            }
                            root.visible = false
                        }else{
                            root.visible = true
                        }
                    }
                }
            }
        }
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: true }
    Item {
        id: root
        anchors.left:  parent.right
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth*0.7
        anchors.top: parent.top
        anchors.topMargin: ScreenTools.defaultFontPixelWidth*5
        visible: true
        z:   QGroundControl.zOrderTopMost  //层级
        Rectangle {
            id: dataShow1
            radius: _radiusValueSize
            color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0,0,0,0.4)
            height : dataShow1Grid.height
            width : dataShow1Grid.width + ScreenTools.defaultFontPixelWidth*1.5
            Grid {
                id: dataShow1Grid
                verticalItemAlignment: Grid.AlignBottom

                columns: 2
                padding: ScreenTools.defaultFontPixelWidth * 0.5
                leftPadding: _dataShowLabelSize
                rightPadding: _dataShowValueSize
                spacing:  ScreenTools.defaultFontPixelWidth * 0.5


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
                        width: ScreenTools.defaultFontPixelWidth*2.8
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -_radiusValueSize
                        font.pointSize: _dataShowValueSize
                        text: QGCCwGimbalController.pitch
                        font.family:    ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }
                }

                Text {
                    font.pointSize: _dataShowValueSize
                    text: QGCCwGimbalController.mode
                    font.family:    ScreenTools.normalFontFamily
                    color: qgcPal.text
                }

                Row {
                    spacing:  ScreenTools.defaultFontPixelWidth * 0.2
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: _radiusValueSize
                        font.pointSize: _dataShowLabelSize
                        text: "YAW"
                        font.family:    ScreenTools.normalFontFamily
                         color: qgcPal.text
                    }

                    Text {
                        width: ScreenTools.defaultFontPixelWidth*2.4
                        font.pointSize: _dataShowValueSize
                        text: QGCCwGimbalController.yaw
                        font.family:    ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }
                }

            }
        }

        Rectangle {
//            visible: false
            id: dataShow2
            anchors.left: dataShow1.right
            anchors.leftMargin:_radiusValueSize
            radius: _radiusValueSize
            height : dataShow2Column.height
            width : dataShow2Column.width + ScreenTools.defaultFontPixelWidth*0.6
            color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0,0,0,0.4)
            Column {
                id: dataShow2Column
                padding: ScreenTools.defaultFontPixelWidth * 0.5
                leftPadding: _dataShowLabelSize
                rightPadding: ScreenTools.defaultFontPixelWidth *1.2
                spacing:  ScreenTools.defaultFontPixelWidth * 0.5

                Row {
                    Text {
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowLabelSize
                        text: "RNG(m)"
                        font.family:    ScreenTools.normalFontFamily
                         color: qgcPal.text
                    }

                    Text {
                        width: ScreenTools.defaultFontPixelWidth*5.4
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -_radiusValueSize
                        font.pointSize: _dataShowValueSize
                        text: QGCCwGimbalController.lazerDis
                        font.family:    ScreenTools.normalFontFamily
                         color: qgcPal.text
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowLabelSize
                        text: "    ASL(m)"
                        font.family:    ScreenTools.normalFontFamily
                         color: qgcPal.text
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -_radiusValueSize
                        font.pointSize: _dataShowValueSize
                        text: QGCCwGimbalController.altitude
                        font.family:    ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }

                }
                Row {
                    Text {
                        width: ScreenTools.defaultFontPixelWidth*13
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowValueSize
                        text: QGCCwGimbalController.longitude
                        font.family:    ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }

                    Text {
                        width: ScreenTools.defaultFontPixelWidth*13
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowValueSize
                        text: " , " + QGCCwGimbalController.latitude
                        font.family:    ScreenTools.normalFontFamily
                         color: qgcPal.text
                    }
                }
            }
        }

        Row {
            id: buttonRow
            anchors.top: dataShow1.bottom
            anchors.topMargin: ScreenTools.defaultFontPixelWidth
            spacing:  ScreenTools.defaultFontPixelWidth
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
                iconSource: "CameraFunciton.png"
                iconMarkShow: true
                overlayColor:ScreenTools.isMobile ? "#000" : "#fff"
                onBtnClicked: {
                    cameraFunctionSelectRect.visible = !cameraFunctionSelectRect.visible
                }

                Rectangle {
                    id: cameraFunctionSelectRect
                    anchors.top: parent.bottom
                    anchors.topMargin: ScreenTools.defaultFontPixelWidth/2
                    anchors.left: parent.left
                    visible: false
                    color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0,0,0,0.4)
                    radius: _radiusValueSize
                    height: cameraFunctionColumn.height
                    width: cameraFunctionColumn.width

                    Column {
                        id: cameraFunctionColumn
                        spacing:  ScreenTools.defaultFontPixelWidth * 0.5
                        CwGimbalBtn {
                            iconSource: "IRCut.png"
                            showHighlight: QGCCwGimbalController.btnState & 0x00000200 ? true : false
                            overlayColor:(QGCCwGimbalController.btnState & 0x00000200 || ScreenTools.isMobile) ? "#000" : "#fff"
                            onBtnClicked: {
                                cameraFunctionSelectRect.visible = false
                                QGCCwGimbalController.ircutSwitch();
                            }
                        }

                        CwGimbalBtn {
                            iconSource: "Lamp.png"
                            showHighlight: QGCCwGimbalController.btnState & 0x00000400 ? true : false
                            overlayColor:(QGCCwGimbalController.btnState & 0x00000400 || ScreenTools.isMobile) ? "#000" : "#fff"
                            visible: QGCCwGimbalController.lampAvailable
                            onBtnClicked: {
                                cameraFunctionSelectRect.visible = false
                                QGCCwGimbalController.lampSwitch();
                            }
                        }
                    }

                }
            }

            CwGimbalBtn {
                iconSource: "Track.png"
                visible: QGCCwGimbalController.trackAvailable
                showHighlight: QGCCwGimbalController.modeRaw ===3 ? true : false
                overlayColor:(QGCCwGimbalController.modeRaw ===3 || ScreenTools.isMobile) ? "#000" : "#fff"
                onBtnClicked: {
                    //QGCCwGimbalController.modeSwitch(3);
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
    }
    DropPanel {
        id:         dropPanel
        toolStrip:  _root
    }
}
