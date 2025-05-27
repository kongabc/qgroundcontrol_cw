import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

Rectangle{
    id:_tableModule

    property real _wid34: ScreenTools.defaultFontPixelWidth * 3.4
    property real _defaultFont: ScreenTools.defaultFontPointSize
    property color bgColor:"gray"
    property real rectWidth //:600
    property real rectHeight // :40
    property real columnWidth1
    property real columnWidth2
    property real columnWidth3
    property real columnWidth4
//    property var _dropArr:["None","1", "2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18"]
    property var _dropArr:["None",1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
    property int dropCheckedIndex:0
    //    property string dropCheckedValue
    property string channelVal
    property bool isChecked:false
    property string txtFir:""
    property string txtSec:""
    property string txtThi:""
    property real progressVal: 0 //  0.5

    signal dropCheckedChange(int checkIndex)
    signal checkBoxClick(bool checked)

    Layout.preferredWidth:rectWidth
    Layout.preferredHeight:rectHeight
    color: bgColor
//    anchors.horizontalCenter: parent.horizontalCenter
    Layout.alignment: Qt.AlignHCenter
    Layout.fillWidth: true

    GridLayout{
        columns: 4  // 总列数
//        Layout.fillWidth: true
//        anchors.horizontalCenter: parent.horizontalCenter
        QGCComboBox  {
            Layout.fillWidth: true
            Layout.preferredWidth: columnWidth1*0.98
            Layout.preferredHeight: _wid34
            Layout.alignment: Qt.AlignVCenter
            model: _tableModule._dropArr
            currentIndex:_tableModule.dropCheckedIndex
            onActivated:{
                //                _tableModule.dropCheckedValue = _dropArr[currentIndex]
                dropCheckedChange(currentIndex)
            }
        }
//        QGCCheckBox {
//            Layout.fillWidth: true
//            Layout.preferredWidth: columnWidth2
//            Layout.preferredHeight: 40
//            Layout.rightMargin: -ScreenTools.defaultFontPixelWidth/2
//            checked:_tableModule.isChecked
//            onClicked:{
//                checkBoxClick(checked)
//            }
//        }
        Item {
            Layout.preferredWidth: columnWidth2
            Layout.preferredHeight: rectHeight
            QGCCheckBox {
//                Layout.fillWidth: true
//                anchors.fill: parent
                checked:_tableModule.isChecked
                anchors{
                    left:parent.left
                    leftMargin:columnWidth2/3
                    verticalCenter: parent.verticalCenter
                }
                onClicked:{
                    checkBoxClick(checked)
                }
            }

        }
        Text {
            Layout.preferredWidth: columnWidth3
            Layout.preferredHeight: rectHeight
            text: _tableModule.channelVal
            font.pointSize: _defaultFont
            color: qgcPal.text
            leftPadding: columnWidth3/5
            verticalAlignment: Text.AlignVCenter
        }
        Rectangle{
            id:prossBox
            Layout.fillWidth: true
            Layout.preferredWidth: columnWidth4*0.96 //_tableModule.rectWidth*0.35  //200
            Layout.preferredHeight: rectHeight
            color: bgColor
            GridLayout{
                Layout.preferredWidth:columnWidth4*0.96 //columnWidth4*0.95 //prossBox.Layout.preferredWidth // _tableModule.rectWidth*0.6 //parent.width
                anchors.verticalCenter: parent.verticalCenter
                columns: 3
                Text {
                    Layout.row: 1; Layout.column: 0
                    Layout.preferredWidth:parent.Layout.preferredWidth/3
                    text: _tableModule.txtFir
                    font.pointSize: _defaultFont
                    color: qgcPal.text
                }
                Text {
                    Layout.preferredWidth:parent.Layout.preferredWidth/3
                    Layout.row: 1; Layout.column: 1
                    text: _tableModule.txtSec
                    font.pointSize: _defaultFont
                    color: qgcPal.text
                    Layout.leftMargin: -ScreenTools.defaultFontPixelWidth*1.4
                    horizontalAlignment:Text.AlignHCenter
                }
                Text {
                    Layout.preferredWidth: parent.Layout.preferredWidth/3
                    Layout.row: 1; Layout.column: 2
                    text: _tableModule.txtThi
                    font.pointSize: _defaultFont
                    color: qgcPal.text
                    Layout.leftMargin: -ScreenTools.defaultFontPixelWidth*1.6
                    horizontalAlignment:Text.AlignRight
                }
                ProgressBar {
                    id: progressBar
                    Layout.row: 2
                    Layout.columnSpan: 3
                    Layout.preferredWidth:columnWidth4*0.94 //_tableModule.rectWidth*0.6 //200
                    Layout.preferredHeight: 4
                    value: _tableModule.channelVal ? _tableModule.channelVal : 0  //(from设为0，to设为100):(model.value + 1024) / 20.48  //通道的值转换为0到100%，其中-1024对应0%，0对应50%，1024对应100%。那么可以计算(from设为0，to设为100)： valueNormalized = ((原始值 + 1024) / (1024 * 2)) * 100
                    from:-1024
                    to:1024
                    background: Rectangle {
                        color: "#e0e0e0"
                        height: parent.height
                    }
                    contentItem: Item {
                        height: parent.height
                        Rectangle {
                            width: progressBar.visualPosition * parent.width
                            height: parent.height
                            color:"#009fff"
                        }
                    }

                }
            }

        }

    }

}
