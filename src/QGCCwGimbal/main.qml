import QtQuick 2.15

import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

import QtQuick.Layouts              1.12
import QtQuick.Window 2.15
import QGCCwQml.QGCCwGimbalController 1.0
import QGCCwGimbal.Controls 1.0



Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    color: "lightsteelblue"

    property int _dataShowLabelSize: ScreenTools.isMobile ? ScreenTools.smallFontPointSize*0.8 : ScreenTools.smallFontPointSize
    property int _dataShowValueSize: ScreenTools.isMobile ? ScreenTools.mediumFontPointSize*0.7 : ScreenTools.mediumFontPointSize
    property int _radiusValueSize: ScreenTools.defaultFontPixelWidth / 2


    QGCPalette { id: qgcPal; colorGroupEnabled: true }
	
	Item {
        id: root
        anchors.top: parent.top
        anchors.topMargin: ScreenTools.defaultFontPixelWidth/1.4
        x:(_root.width - dataShow2.width*2.3)/2

        visible: true
        z:   QGroundControl.zOrderTopMost  

        Row {
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
                        width: ScreenTools.defaultFontPixelWidth*2.8
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
                        width: ScreenTools.defaultFontPixelWidth*4
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
                        width: ScreenTools.defaultFontPixelWidth*4
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowValueSize
                        text: QGCCwGimbalController.altitude
                        font.family:    ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }

                    Text {
                        anchors.bottom: parent.bottom
                        font.pointSize: _dataShowValueSize
                        text: QGCCwGimbalController.latitude
                        font.family:    ScreenTools.normalFontFamily
                        color: qgcPal.text
                    }
                }
            }
        }

    }

}
