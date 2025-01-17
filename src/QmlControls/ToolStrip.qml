/****************************************************************************
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

//new add 3
import QtGraphicalEffects 1.15
import QGCCwQml.QGCCwGimbalController 1.0

Rectangle {
    id:         _root
//    color:      qgcPal.toolbarBackground
    color:ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : "#000"
    width:      _idealWidth < repeater.contentWidth ? repeater.contentWidth : _idealWidth
    height:     Math.min(maxHeight, toolStripColumn.height + (flickable.anchors.margins * 2))
    radius:     ScreenTools.defaultFontPixelWidth / 2

    property alias  model:              repeater.model
    property real   maxHeight           ///< Maximum height for control, determines whether text is hidden to make control shorter
    property alias  title:              titleLabel.text

    property var _dropPanel: dropPanel

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
                                //new add 3
                                if(i == 0){
                                    packUpBtn.visible = false
                                }

                                if (i != index) {
                                    var button = repeater.itemAt(i)
                                    if (button.checked) {
                                        button.checked = false
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // new add 3 tcp
            Button{
//                visible: QGCCwGimbalController.remoteValid
                id: packUpBtn
                width: width
                height: width
                hoverEnabled:   true
                checkable:     true
                anchors.left:       toolStripColumn.left
                anchors.right:      toolStripColumn.right

                contentItem:Item{
                    id:contentLayoutItem1
                    anchors.fill:       parent
                    anchors.margins:    innerText1.height * 0.1
                    Column{
                        anchors.centerIn:   parent
                        spacing: ScreenTools.isMobile ? innerText1.height*0.2 : innerText1.height * 0.4
                        Image{
                            id:                         innerImage2
                            source: packUpBtn.checked ? "/qmlimages/unfoldMenu.png" : "/qmlimages/packup.png"
                            width: contentLayoutItem1.width*0.45
                            height: contentLayoutItem1.height*0.45
                            fillMode:                   Image.PreserveAspectFit
                            anchors.horizontalCenter:   parent.horizontalCenter
                            smooth:                     true
                            mipmap:                     true
                            sourceSize.height:          height
                            sourceSize.width:           width
                            antialiasing:               true

                            ColorOverlay {
                                anchors.fill: innerImage2
                                source: innerImage2
                                color: innerText1.color
                            }
                        }

                        Text{
                            id:  innerText1
                            text: packUpBtn.checked ?  "展开" : "收起"
                            color: ScreenTools.isMobile ? (packUpBtn.checked ? "#fff" : "#000") :  (packUpBtn.checked ? "#000" : "#fff")
                            font.pointSize: ScreenTools.isMobile ? ScreenTools.defaultFontPointSize/1.6 : ScreenTools.defaultFontPointSize*0.8
                            anchors.horizontalCenter:   parent.horizontalCenter
                            font.family:    ScreenTools.normalFontFamily
                            antialiasing:   true

                        }
                    }
                }
                background: Rectangle {
//                    color: QGCCwGimbalController.remoteValid ?( (packUpBtn.checked || packUpBtn.pressed) ?
//                            qgcPal.buttonHighlight :(packUpBtn.hovered ? qgcPal.toolStripHoverColor :
//                            ( ScreenTools.isMobile ? Qt.rgba(1,1,1,0.2) : "#000"))) : " "

                    color: (packUpBtn.checked || packUpBtn.pressed) ?  qgcPal.buttonHighlight :
                         (packUpBtn.hovered ? qgcPal.toolStripHoverColor : ( ScreenTools.isMobile ? Qt.rgba(1,1,1,0.2) : "#000"))

                    radius: ScreenTools.defaultFontPixelWidth / 2
                    anchors.fill:   parent

                }

                onCheckedChanged :{
                   widgetLayer.isVisibleBtn = !checked;
                }
            }
        }
    }

    DropPanel {
        id:         dropPanel
        toolStrip:  _root
    }

}
