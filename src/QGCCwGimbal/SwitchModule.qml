import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

Rectangle{
    id:_swittchModule
    property bool isOn: false
    property string onText:""
    property string offText:""

    signal onOffClick(bool isOn)

    anchors.fill: parent

    QGCPalette { id: qgcPal }

    Row {
        anchors.fill: parent
        spacing: 0
        // 开启区域

        Rectangle {
           width: parent.width / 2
           height: parent.height
           color: isOn ? qgcPal.buttonHighlight : qgcPal.windowShade
           border.width: 1
           border.color: ScreenTools.isMobile ? "#000" : "#FFF"
           Text {
               anchors.centerIn: parent
               text: _swittchModule.onText
               font.pointSize: ScreenTools.defaultFontPointSize //*1.2
               color:isOn ? qgcPal.buttonHighlightText :qgcPal.text
           }

           MouseArea {
               anchors.fill: parent
               onClicked: {
                   _swittchModule.isOn = true
                   onOffClick(_swittchModule.isOn)
               }
           }
        }

        // 关闭区域
        Rectangle {
            width: parent.width / 2
            height: parent.height
            color: isOn ?  qgcPal.windowShade : qgcPal.buttonHighlight
            border.width: 1
            border.color: ScreenTools.isMobile ? "#000" : "#FFF"
            Text {
                anchors.centerIn: parent
                text: _swittchModule.offText
                font.pointSize: ScreenTools.defaultFontPointSize//*1.2
                color:isOn ? qgcPal.text : qgcPal.buttonHighlightText
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    _swittchModule.isOn = false
                    onOffClick(_swittchModule.isOn)
                }
            }
        }

    }


}
