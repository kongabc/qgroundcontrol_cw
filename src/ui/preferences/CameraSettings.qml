import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtQuick.Layouts          1.2
import QtQuick.Window   2.11

//import QtWebView 1.15

import QGroundControl                       1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.FactControls          1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controllers           1.0
import QGroundControl.SettingsManager       1.0

//new add 4
import QtQuick.Controls         2.15
import QtQml 2.15
import QGCCwQml.QGCCwGimbalController 1.0
import QGCCwGimbal.Controls 1.0

Rectangle {
    id:   _root
    color:          qgcPal.window
    anchors.fill:   parent
    anchors.margins:    ScreenTools.defaultFontPixelWidth

    QGCPalette { id: qgcPal }

    property var    _videoSettings:             QGroundControl.settingsManager.videoSettings
    property string _videoSource:               _videoSettings.videoSource.rawValue
    property bool   _isGst:                     QGroundControl.videoManager.isGStreamer
    property bool   _isUDP264:                  _isGst && _videoSource === _videoSettings.udp264VideoSource
    property bool   _isUDP265:                  _isGst && _videoSource === _videoSettings.udp265VideoSource
    property bool   _isRTSP:                    _isGst && _videoSource === _videoSettings.rtspVideoSource
    property bool   _isTCP:                     _isGst && _videoSource === _videoSettings.tcpVideoSource
    property bool   _isMPEGTS:                  _isGst && _videoSource === _videoSettings.mpegtsVideoSource
    property bool   _videoAutoStreamConfig:     QGroundControl.videoManager.autoStreamConfigured
    property bool   _showSaveVideoSettings:     _isGst || _videoAutoStreamConfig


    property real   _margins:           ScreenTools.defaultFontPixelWidth/2
    property real _labelWidth:          ScreenTools.defaultFontPixelWidth * 16
    property real _valueWidth:          ScreenTools.defaultFontPixelWidth * 24
    property real  _valueFieldWidth:    ScreenTools.defaultFontPixelWidth * 10
    property real _rectHeight:          ScreenTools.defaultFontPixelWidth * 4.4
    property real _defaultFont:         ScreenTools.defaultFontPointSize
    property int  _selectedCount:       0
    property real _columnSpacing:       ScreenTools.defaultFontPixelHeight * 1.4
    property real _comboFieldWidth:     ScreenTools.defaultFontPixelWidth * 24
    property real _tableHeight:         ScreenTools.defaultFontPixelWidth * 3.8
    property int  _dataShowValueSize: ScreenTools.isMobile ? ScreenTools.mediumFontPointSize*0.75 : ScreenTools.mediumFontPointSize*1.2
    property bool _uploadedSelected:    false
    property color _rowColor: "#626270"
    property color _selectedColor: qgcPal.buttonHighlight// "#FFF291"
    property color _selectedTextColor: qgcPal.buttonHighlightText
    property color _unselectedColor: qgcPal.windowShade
    property real  _widths:Math.round(_root.width*0.8)

    property real _tabBoxWid:ScreenTools.isMobile ? _root.width : (_root.width*0.9)
    property real _rowWidths:ScreenTools.isMobile ? _tabBoxWid*0.95 : _tabBoxWid*0.7
    property real _rowCol1:_rowWidths*0.2
    property real _rowCol2:_rowWidths*0.8

    property real _colW1:ScreenTools.isMobile ? _rowCol2*0.2 : _rowCol2*0.28
    property real _colW2:_rowCol2*0.1
    property real _colW3:_rowCol2*0.12
    property real _colW4:_rowCol2*0.5

    property real _switchBtnHe:ScreenTools.defaultFontPixelWidth*3.4

    property var  columnWidths: [w1*0.15, w1*0.2, w1*0.15,w1*0.1,w1*0.4,w1*0.85]

    property real w1:setWidth2.Layout.preferredWidth*0.85


    function validateIPaddress(ipaddress) {
        if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(ipaddress))
            return true
        return false
    }

    function isAllOnesMask(mask) {
        const parts = mask.split('.');
        return parts.every(part => parseInt(part, 10) === 255);
    }

    QGCFlickable {
        id:scrollTopCont
        clip:               true
        anchors.fill:       parent
        anchors.margins: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth/5 : ScreenTools.defaultFontPixelWidth
        contentHeight:      tabColumn.height
        contentWidth:       tabColumn.width
        flickableDirection: Flickable.VerticalFlick
        Rectangle{
            id: tabColumn
            width: _root.width
            height: tabBarBtn.height + Math.max(swipeViewCont.maxItemHeight, _root.height - tabBarBtn.height)
            color: "transparent"

            TabBar {
                id: tabBarBtn
                width:ScreenTools.isMobile ? _root.width : _root.width * 0.9
                height:ScreenTools.defaultFontPixelHeight*1.8
                anchors.horizontalCenter: parent.horizontalCenter
                currentIndex: swipeViewCont.currentIndex
                onCurrentIndexChanged: {
                    if (swipeViewCont.currentIndex !== currentIndex) {
                       swipeViewCont.currentIndex = currentIndex;
//                       console.log("tabBarBtn.currentIndex" ,tabBarBtn.currentIndex, ":" ,swipeViewCont.currentIndex)
                       QGCCwGimbalController.saveState = false;

                       if(tabBarBtn.currentIndex != 3){
                           QGCCwGimbalController.resetNoSaveData();
                        }
                       if(tabBarBtn.currentIndex == 1){
                           QGCCwGimbalController.reqCameraConf();
                        }

                       if(tabBarBtn.currentIndex == 2){
                          QGCCwGimbalController.startRequest(QGCCwGimbalController.cameraIpAddr);
                        }
                    }
                }
                TabButton {
                    id: btn1
                    text:qsTr("General") //ScreenTools.isMobile ? qsTr("General") : qsTr("General Setting")
                    font.pointSize: _defaultFont
                    font.family:    ScreenTools.normalFontFamily
                    height: tabBarBtn.height
                    anchors.verticalCenter: parent.verticalCenter
                    background: Rectangle {
                        color: btn1.checked ? _selectedColor : _unselectedColor
                    }
//                    palette.buttonText: btn1.checked ? _selectedTextColor : qgcPal.text
                    contentItem: Text {
                        text: btn1.text
                        color: btn1.checked ? _selectedTextColor : qgcPal.text
                        font: btn1.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                TabButton {
                    id: btn2
                    text:qsTr("Net") //ScreenTools.isMobile ? "Net" : "Net Setting"
                    font.pointSize: _defaultFont
                    font.family:    ScreenTools.normalFontFamily
                    height: tabBarBtn.height
                    anchors.verticalCenter: parent.verticalCenter
                    background: Rectangle {
                        color: btn2.checked ? _selectedColor : _unselectedColor
                    }
                    contentItem: Text {
                        text: btn2.text
                        color: btn2.checked ? _selectedTextColor : qgcPal.text
                        font: btn2.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                TabButton {
                    id: btn3
                    text:qsTr("Camera")
                    font.pointSize: _defaultFont
                    font.family:    ScreenTools.normalFontFamily
                    height: tabBarBtn.height
                    anchors.verticalCenter: parent.verticalCenter
                    background: Rectangle {
                        color: btn3.checked ? _selectedColor : _unselectedColor
                    }
                    contentItem: Text {
                        text: btn3.text
                        color: btn3.checked ? _selectedTextColor : qgcPal.text
                        font: btn3.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                TabButton {
                    id: btn4
                    text:qsTr("S.BUS")//ScreenTools.isMobile ? "S.BUS" :"S.BUS设置"
                    font.pointSize: _defaultFont
                    font.family:    ScreenTools.normalFontFamily
                    height: tabBarBtn.height
                    anchors.verticalCenter: parent.verticalCenter
                    background: Rectangle {
                        color: btn4.checked ? _selectedColor : _unselectedColor
                    }
                    contentItem: Text {
                        text: btn4.text
                        color: btn4.checked ? _selectedTextColor : qgcPal.text
                        font: btn4.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                TabButton {
                    id: btn5
                    text:qsTr("Calib")
                    height: tabBarBtn.height
                    font.pointSize: _defaultFont
                    font.family:    ScreenTools.normalFontFamily
                    anchors.verticalCenter: parent.verticalCenter
                    background: Rectangle {
                        color: btn5.checked ? _selectedColor : _unselectedColor
                    }
                    contentItem: Text {
                        text: btn5.text
                        color: btn5.checked ? _selectedTextColor : qgcPal.text
                        font: btn5.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                TabButton {
                    id: btn6
                    text:qsTr("Vehicle") // ScreenTools.isMobile ? "载机" :"载机数据"
                    font.pointSize: _defaultFont
                    font.family:    ScreenTools.normalFontFamily
                    height: tabBarBtn.height
                    anchors.verticalCenter: parent.verticalCenter
                    background: Rectangle {
                        color: btn6.checked ? _selectedColor : _unselectedColor
                    }
                    contentItem: Text {
                        text: btn6.text
                        color: btn6.checked ? _selectedTextColor : qgcPal.text
                        font: btn6.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                TabButton {
                    id: btn7
                    text:qsTr("Advance")// ScreenTools.isMobile ? "高级" :"高级设置"
                    font.pointSize: _defaultFont
                    font.family:    ScreenTools.normalFontFamily
                    visible: QGCCwGimbalController.firmwareVer ? ((QGCCwGimbalController.firmwareVer/10) >= 5 ? true : false) : false
                    height: tabBarBtn.height
//                    width: visible ?  btn5.width : 0
                    anchors.verticalCenter: parent.verticalCenter
                    background: Rectangle {
                        color: btn7.checked ? _selectedColor : _unselectedColor
                    }
                    contentItem: Text {
                        text: btn7.text
                        color: btn7.checked ? _selectedTextColor : qgcPal.text
                        font: btn7.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Component.onCompleted: {
                        btn7.width = Qt.binding(function() {
                            return visible ? btn1.width : 0
                        })
                    }
                }
            }

            SwipeView {
                id: swipeViewCont
                anchors {
                    top: tabBarBtn.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                width: parent.width
                property real maxItemHeight: {
                       let maxH = 0;
                       for (let i = 0; i < count; ++i) {
                           const item = itemAt(i);
                           if (item && item.implicitHeight > maxH) {
                               maxH = item.implicitHeight;
                           }
                       }
                       return maxH;
                   }

                currentIndex: tabBarBtn.currentIndex
                anchors.topMargin:ScreenTools.isMobile ? _columnSpacing/2 : _columnSpacing
                clip: true

                onCurrentIndexChanged: {
                    if (tabBarBtn.currentIndex !== currentIndex) {
                        tabBarBtn.currentIndex = currentIndex;
                        QGCCwGimbalController.saveState = false;

                        scrollTopCont.contentY = 0;
                    }

                }
                interactive:ScreenTools.isMobile ? false : true


                // 添加的滚轮处理区域

                Item{
                    width: SwipeView.view.width
                    implicitHeight: childHeight1.implicitHeight +  _columnSpacing * 2
                    //pc use ListView ， Android use ScrollView
                    ScrollView { //ScrollView { //
                        anchors.fill: parent
                        contentHeight: childHeight1.implicitHeight
                        Rectangle{
                            id:childHeight1
                            width: _tabBoxWid
//                            height: parent.height
                            implicitHeight:columnHei1.implicitHeight +  _columnSpacing * 2
                            color: qgcPal.windowShade
                            anchors.horizontalCenter: parent.horizontalCenter // 水平居中
                            ColumnLayout{
                                id:columnHei1
                                anchors.top:                parent.top
                                anchors.topMargin: _columnSpacing
                                anchors.horizontalCenter:   parent.horizontalCenter
                                spacing: ScreenTools.isMobile ? _columnSpacing/2 : _columnSpacing/1.4
                                RowLayout{
                                    QGCLabel {
                                        width: _labelWidth
                                        text: qsTr("Model:")
                                    }
                                    Text{
                                        text: QGCCwGimbalController.devideType ? QGCCwGimbalController.devideType : qsTr("Unknown")
                                        font.pointSize:_defaultFont*1.2
                                        font.family:    ScreenTools.normalFontFamily;
                                        color: qgcPal.text
                                    }
                                }
                                RowLayout{
                                    QGCLabel {
                                        width: _labelWidth
                                        text: qsTr("GCU:")
                                    }
                                    Text{
                                        text: isNaN(QGCCwGimbalController.firmwareVer) ? qsTr("Unknown") : QGCCwGimbalController.firmwareVer/10
                                        font.pointSize:_defaultFont*1.2
                                        font.family:    ScreenTools.normalFontFamily;
                                        color: qgcPal.text
                                    }
                                    Item{
                                        width: _columnSpacing/2
                                    }
                                    QGCLabel {
                                        width: _labelWidth
                                        text: qsTr("Gimbal:")
                                    }
                                    Text{
                                        text: isNaN(QGCCwGimbalController.hardwareVer) ? qsTr("Unknown") : QGCCwGimbalController.hardwareVer/10
                                        font.pointSize:_defaultFont*1.2
                                        font.family:    ScreenTools.normalFontFamily;
                                        color: qgcPal.text
                                    }

                                }

                                //流地址
                                Rectangle {
                                    height: 1
                                    color: qgcPal.text
                                    Layout.fillWidth: true
                                    Layout.leftMargin: -_margins
                                    Layout.rightMargin: -_margins
                                }

                                GridLayout {
                                    id:                         comm1
                                    Layout.alignment:   Qt.AlignHCenter
                                    rows:1
                                    columns:3
                                    columnSpacing:_margins
                                    rowSpacing:_margins

                                    QGCLabel {
                                        text:               qsTr("Video Settings")
                                    }

                                    QGCRadioButton {
                                        id:videoMode1
                                        text: qsTr("Mode1")
                                        checked:QGroundControl.videoManager.videoMode
                                        onClicked: {
                                            if(QGroundControl.videoManager.videoMode){
                                                return;
                                            }

                                            QGroundControl.videoManager.videoMode = checked;
                                            QGroundControl.videoManager.selectIndexFun(1);
                                            QGroundControl.settingsManager.videoSettings.selectVideoSource("RTSP Video Stream");
                                        }
                                    }

                                    QGCRadioButton {
                                        id:videoMode2
                                        text:  qsTr("Mode2")
                                        checked:!QGroundControl.videoManager.videoMode
                                        onClicked:  {
                                            if(!QGroundControl.videoManager.videoMode){
                                                return;
                                            }

                                            QGroundControl.videoManager.videoMode = !QGroundControl.videoManager.videoMode;
                                            videoCombo.currentIndex = 0;
                                            QGroundControl.videoManager.selectIndexFun(2);
                                            _videoSettings.videoSource.rawValue = _videoSettings.udp264VideoSource;

                                        }
                                    }

                                }

                                GridLayout{
                                    id:         videoGrid
                                    columns:    2
                                    visible:    _videoSettings.visible

                                    //new add 202407
                                    QGCLabel {
                                        id:         videoStreamLabel
                                        text:       qsTr("Source")
                                        visible:    !_videoAutoStreamConfig && _videoSettings.videoSource.visible && videoMode2.checked
                                    }
                                    QGCComboBox{
                                        id:videoCombo
                                        Layout.preferredWidth:  _comboFieldWidth
                                        model:  [
                                            qsTr("Video Stream")
                                        ]
                                        visible: videoStreamLabel.visible
                                        currentIndex: 0
                                        onActivated:{

                                            QGroundControl.videoManager.selectIndexFun(index);
                                            QGroundControl.settingsManager.videoSettings.selectVideoSource("UDP h.264 Video Stream");
                                        }
                                    }
                                    QGCLabel {
                                        id:         videoUrlLabel
                                        text:       qsTr("STREAM URL")
                                        visible:    !_videoAutoStreamConfig && videoMode2.checked  //&& (videoCombo.currentIndex === 1)
                                    }
                                    QGCTextField{
                                        id:inputStr
                                        Layout.preferredWidth:  _comboFieldWidth
                                        text:  QGroundControl.videoManager.allVideoStream
                                        showUnits:  false
                                        showHelp:   false
                                        visible:    videoUrlLabel.visible
                                        onEditingFinished:{
                                            if (text.startsWith("\n")) {
                                                text = text.slice("\n".length);
                                            }
                                            if (text.endsWith("\n")) {
                                                text = text.slice(text.length - 1);
                                            }
                                            QGroundControl.videoManager.allVideoStream = text;

                                            if( QGroundControl.videoManager.is264){
                                                QGroundControl.settingsManager.videoSettings.selectVideoSource("UDP h.264 Video Stream");
                                            }else{
                                                QGroundControl.settingsManager.videoSettings.selectVideoSource("UDP h.265 Video Stream");
                                            }

                                        }
                                    }

                                    //------------------------end-----------------------------------
                                    //new add 2024  visible:false
                                    QGCLabel {
                                        id:         videoSourceLabel
                                        text:       qsTr("Source")
                                        visible:    !_videoAutoStreamConfig && _videoSettings.videoSource.visible && videoMode1.checked
                                    }
                                    FactComboBox {
                                        id:                     videoSource
                                        Layout.preferredWidth:  _comboFieldWidth
                                        indexModel:             false
                                        fact:                   _videoSettings.videoSource
                                        visible:                videoSourceLabel.visible
                                    }

                                    QGCLabel {
                                        id:         udpPortLabel
                                        text:       qsTr("UDP Port")
                                        visible:    !_videoAutoStreamConfig && (_isUDP264 || _isUDP265 || _isMPEGTS) && _videoSettings.udpPort.visible && videoMode1.checked
                                    }
                                    FactTextField {
                                        Layout.preferredWidth:  _comboFieldWidth
                                        fact:                   _videoSettings.udpPort
                                        visible:                udpPortLabel.visible
                                    }

                                    QGCLabel {
                                        id:         rtspUrlLabel
                                        text:       qsTr("RTSP URL")
                                        visible:    !_videoAutoStreamConfig && _isRTSP && _videoSettings.rtspUrl.visible && videoMode1.checked
                                    }
                                    FactTextField {
                                        Layout.preferredWidth:  _comboFieldWidth
                                        fact:                   _videoSettings.rtspUrl
                                        visible:                rtspUrlLabel.visible
                                    }
                                    QGCLabel {
                                        id:         tcpUrlLabel
                                        text:       qsTr("TCP URL")
                                        visible:    !_videoAutoStreamConfig && _isTCP && _videoSettings.tcpUrl.visible
                                    }
                                    FactTextField {
                                        Layout.preferredWidth:  _comboFieldWidth
                                        fact:                   _videoSettings.tcpUrl
                                        visible:                tcpUrlLabel.visible
                                    }

                                    QGCLabel {
                                        text:                   qsTr("Aspect Ratio")
                                        visible:                !_videoAutoStreamConfig && _isGst && _videoSettings.aspectRatio.visible //&& videoUrlLabel.visible   //new add 2024
                                    }
                                    FactTextField {
                                        Layout.preferredWidth:  _comboFieldWidth
                                        fact:                   _videoSettings.aspectRatio
                                        visible:                !_videoAutoStreamConfig && _isGst && _videoSettings.aspectRatio.visible //&& videoUrlLabel.visible  // new add 2024
                                    }

                                    QGCLabel {
                                        id:         videoFileFormatLabel
                                        text:       qsTr("File Format")
                                        visible:    _showSaveVideoSettings && _videoSettings.recordingFormat.visible //&& videoUrlLabel.visible  //new add 2024
                                    }
                                    FactComboBox {
                                        Layout.preferredWidth:  _comboFieldWidth
                                        fact:                   _videoSettings.recordingFormat
                                        visible:                videoFileFormatLabel.visible
                                    }

                                    QGCLabel {
                                        id:         maxSavedVideoStorageLabel
                                        text:       qsTr("Max Storage Usage")
                                        visible:    _showSaveVideoSettings && _videoSettings.maxVideoSize.visible && _videoSettings.enableStorageLimit.value
                                    }
                                    FactTextField {
                                        Layout.preferredWidth:  _comboFieldWidth
                                        fact:                   _videoSettings.maxVideoSize
                                        visible:                _showSaveVideoSettings && _videoSettings.enableStorageLimit.value && maxSavedVideoStorageLabel.visible
                                    }

                                    QGCLabel {
                                        id:         videoDecodeLabel
                                        text:       qsTr("Video decode priority")
                                        visible:    forceVideoDecoderComboBox.visible
                                    }
                                    FactComboBox {
                                        id:                     forceVideoDecoderComboBox
                                        Layout.preferredWidth:  _comboFieldWidth
                                        fact:                   _videoSettings.forceVideoDecoder
                                        visible:                fact.visible
                                        indexModel:             false
                                    }

                                    Item { width: 1; height: 1}
                                    FactCheckBox {
                                        text:       qsTr("Disable When Disarmed")
                                        fact:       _videoSettings.disableWhenDisarmed
                                        visible:    !_videoAutoStreamConfig && _isGst && fact.visible
                                    }

                                    Item { width: 1; height: 1}
                                    FactCheckBox {
                                        text:       qsTr("Low Latency Mode")
                                        fact:       _videoSettings.lowLatencyMode
                                        visible:    !_videoAutoStreamConfig && _isGst && fact.visible
                                    }

                                    Item { width: 1; height: 1}
                                    FactCheckBox {
                                        text:       qsTr("Auto-Delete Saved Recordings")
                                        fact:       _videoSettings.enableStorageLimit
                                        visible:    _showSaveVideoSettings && fact.visible
                                    }
                                }



                                Rectangle {
                                    height: 1
                                    color: qgcPal.text
                                    Layout.fillWidth: true
                                    Layout.leftMargin: -_margins
                                    Layout.rightMargin: -_margins
                                }

                                RowLayout {
                                    spacing: ScreenTools.defaultFontPixelWidth
                                    QGCCheckBox {
                                        id:cameraCenterSwitch
                                        text:       qsTr("Crosshair")
                                        checked:QGCCwGimbalController.showCenter
                                        onClicked: {
                                            QGCCwGimbalController.showCenter = checked;
                                        }
                                    }

                                    QGCComboBox{
                                        id:styleDrop
                                        enabled:cameraCenterSwitch.checked
                                        Layout.preferredWidth:_comboFieldWidth*0.5
                                        Layout.leftMargin: _margins
                                        Layout.rightMargin: _margins
                                        model:  [
                                            qsTr("+ Large"),
                                            qsTr("+ Medium"),
                                            qsTr("+ Small"),
                                            qsTr("x Large"),
                                            qsTr("x Medium"),
                                            qsTr("x Small")
                                        ]
                                        currentIndex:QGCCwGimbalController.iconStyle
                                        onActivated:{
                                            QGCCwGimbalController.iconStyle = index;
                                        }
                                    }

                                    QGCCheckBox {
                                        enabled:cameraCenterSwitch.checked
                                        text:       qsTr("Move Button")
                                        checked:QGCCwGimbalController.showMoveBtn
                                        onClicked: {
                                            QGCCwGimbalController.showMoveBtn = checked;
                                        }
                                    }

                                    Rectangle {
                                        id: myButton
                                        width: ScreenTools.defaultFontPixelWidth*8
                                        height: ScreenTools.defaultFontPixelWidth*3.6
                                        enabled:cameraCenterSwitch.checked
//                                        property bool checked: QGCCwGimbalController.showToCenter && (QGCCwGimbalController.iconOffsetY === 0 && QGCCwGimbalController.iconOffsetX === 0) // 选中状态

                                        // 默认背景色
//                                        color: myButton.checked ? _selectedColor  : qgcPal.button
                                         color: myButton.enabled ? qgcPal.button :  "#cdcdcd"  // (QGCCwGimbalController.showToCenter ?  _selectedColor  : qgcPal.button) :  "#cdcdcd"
                                         border.width: 1

                                        // 按钮文本
                                       Text {
                                           id:centTxt
                                           text:qsTr("To Center")
                                           anchors.centerIn: parent
                                           font.pointSize:ScreenTools.defaultFontPointSize
                                           font.family:    ScreenTools.normalFontFamily;
                                           color:  qgcPal.text  //QGCCwGimbalController.showToCenter ? _selectedTextColor : qgcPal.text
                                       }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked:  {
//                                               myButton.checked = !myButton.checked;
                                                if(myButton.color == _selectedColor){
                                                    QGCCwGimbalController.showToCenter = false;
                                                }else{
                                                    QGCCwGimbalController.showToCenter = true;
                                                }

                                            }
                                            onPressed: {
                                                myButton.color = myButton.enabled ? _selectedColor :   "#cdcdcd"

                                                centTxt.color = _selectedTextColor;

                                            }
                                            onReleased: {
                                                myButton.color = myButton.enabled ? qgcPal.button :   "#cdcdcd"

                                                centTxt.color = qgcPal.text;
                                            }

                                        }
                                    }

                                }

                                RowLayout {
                                    spacing: ScreenTools.defaultFontPixelWidth
                                    QGCLabel {
                                        text:       qsTr("Reference Line")
                                    }
                                    QGCComboBox{
                                        Layout.preferredWidth:_comboFieldWidth*0.8
                                        model:  [
                                            qsTr("None"),
                                            qsTr("Nine-square Grid A"),
                                            qsTr("Nine-square Grid B"),
                                            qsTr("Nine-square Grid A+B")
                                        ]
                                        currentIndex:QGCCwGimbalController.showGrid
                                        onActivated:{
                                            QGCCwGimbalController.showGrid = index;
                                        }
                                    }
                                }

                                RowLayout {
                                    visible: false
                                    spacing: ScreenTools.defaultFontPixelWidth
                                    QGCCheckBox {
                                        text:       qsTr("Camera Center")
                                        checked:QGCCwGimbalController.showCenter
                                        onClicked: {
                                            QGCCwGimbalController.showCenter = checked;
                                        }
                                    }
                                }

                                Rectangle {
                                    height: 1
                                    color: qgcPal.text
                                    Layout.fillWidth: true
                                    Layout.leftMargin: -_margins
                                    Layout.rightMargin: -_margins
                                }
                                //温度报警
                                RowLayout{
                                    Text{
                                        text:  qsTr("Temp Alert")
                                        font.pointSize:ScreenTools.mediumFontPointSize*0.8
                                        color: qgcPal.text
                                        font.family:    ScreenTools.normalFontFamily
                                    }

                                    QGCLabel {
                                        id:textAlign
                                        text:       qsTr("H:")
                                    }
                                    QGCTextField{
                                        id:highVal
                                        Layout.preferredWidth:  _valueFieldWidth- ScreenTools.defaultFontPixelWidth*2
                                        text:  QGCCwGimbalController.tempWarnH
                                        showUnits:  false
                                        showHelp:   false
                                        textColor:"#222"
                                        onTextChanged:{
                                            let hValue = parseInt(text);
                                            let lValue = parseInt(lowVal.text);

                                            if(hValue >= lValue){
                                                lowVal.textColor = textColor = "#222";
                                            }else{
//                                                console.log("不能低于最低温度")
                                                textColor = "red";
                                            }
                                        }
                                        onEditingFinished:{
                                            let hValue = parseInt(text);
                                            let lValue = parseInt(lowVal.text);

                                            if(hValue >= lValue){
                                                QGCCwGimbalController.tempWarnH = hValue;
                                                QGCCwGimbalController.tempWarnL = lValue;

                                                if((QGCCwGimbalController.ircamFlags & 0x20)){
                                                    QGCCwGimbalController.tempWarnSwitch(hValue*10,lValue*10,true);
                                                }

                                            }
                                        }

                                    }
                                    Text {
                                        text: "℃"
                                        font.pointSize:ScreenTools.mediumFontPointSize*0.8
                                        font.family:    ScreenTools.normalFontFamily
                                        color: qgcPal.text
                                        //                                   font.bold: true
                                    }
                                    QGCLabel {
                                        text:       qsTr("L:")
                                        Layout.leftMargin: ScreenTools.defaultFontPixelWidth/1.8
                                    }
                                    QGCTextField{
                                        id:lowVal
                                        Layout.preferredWidth:  _valueFieldWidth- ScreenTools.defaultFontPixelWidth*2
                                        text: QGCCwGimbalController.tempWarnL
                                        showUnits:  false
                                        showHelp:   false
                                        textColor:"#222"
                                        onTextChanged:{
                                            let hValue = parseInt(highVal.text);
                                            if(!highVal.text){
                                                hValue = parseInt(QGCCwGimbalController.tempWarnH);
                                            }
                                            let lValue = parseInt(text);

                                            if(lValue <= hValue){
                                                highVal.textColor = textColor = "#222";

                                            }else{
//                                                console.log("不能高于最高温度")
                                                textColor = "red";
                                            }
                                        }
                                        onEditingFinished:{
                                            let hValue = parseInt(highVal.text);
                                            let lValue = parseInt(text);
                                            if(lValue <= hValue){
                                                QGCCwGimbalController.tempWarnH = hValue;
                                                QGCCwGimbalController.tempWarnL = lValue;
                                                if((QGCCwGimbalController.ircamFlags & 0x20)){
                                                    QGCCwGimbalController.tempWarnSwitch(hValue*10,lValue*10,true);
                                                }

                                            }

                                        }
                                    }
                                    Text {
                                        text: "℃"
                                        font.pointSize:ScreenTools.mediumFontPointSize*0.8
                                        font.family:    ScreenTools.normalFontFamily
                                        color: qgcPal.text
                                        //                                   font.bold: true
                                    }
                                }

                                ColumnLayout{
                                    RowLayout{
                                        Text{
                                            text:  qsTr("Isotherm")
                                            font.pointSize:ScreenTools.mediumFontPointSize*0.8
                                            color: qgcPal.text
                                            font.family:    ScreenTools.normalFontFamily
                                        }
                                        QGCLabel {
                                            Layout.leftMargin: ScreenTools.defaultFontPixelWidth*1.5
                                            text:       qsTr("H:")
                                        }
                                        QGCTextField{
                                            id:isothermHigh
                                            Layout.preferredWidth:  _valueFieldWidth - ScreenTools.defaultFontPixelWidth*2
                                            text:  QGCCwGimbalController.isothermH
                                            showUnits:  false
                                            showHelp:   false
                                            onTextChanged:{
                                                let hValue = parseInt(text);
                                                let lValue = parseInt(isothermLow.text);

                                                if(hValue >= lValue){
                                                    isothermLow.textColor = textColor = "#222";
                                                }else{
//                                                    console.log("不能低于最低温度")
                                                    textColor = "red";
                                                }
                                            }
                                            onEditingFinished:{
                                                let hValue = parseInt(text);
                                                let lValue = parseInt(isothermLow.text);

                                                if(hValue >= lValue){
                                                    QGCCwGimbalController.isothermH = hValue;
                                                    QGCCwGimbalController.isothermL = lValue;
                                                    if((QGCCwGimbalController.ircamFlags & 0x10)){
                                                        QGCCwGimbalController.isoThermSwitch(hValue*10,lValue*10,true);
                                                    }

                                                }

                                            }
                                        }
                                        Text {
                                            text: "℃"
                                            font.pointSize:ScreenTools.mediumFontPointSize*0.8
                                            font.family:    ScreenTools.normalFontFamily
                                            color: qgcPal.text
                                            //                                       font.bold: true
                                        }

                                        QGCLabel {
                                            text:       qsTr("L:")
                                            Layout.leftMargin: ScreenTools.defaultFontPixelWidth/1.8
                                        }
                                        QGCTextField{
                                            id:isothermLow
                                            Layout.preferredWidth:  _valueFieldWidth- ScreenTools.defaultFontPixelWidth*2
                                            text:  QGCCwGimbalController.isothermL
                                            showUnits:  false
                                            showHelp:   false
                                            onTextChanged:{
                                                let hValue = parseInt(isothermHigh.text);
                                                if(!isothermHigh.text){
                                                    hValue = parseInt(QGCCwGimbalController.isothermH);
                                                }
                                                let lValue = parseInt(text);

                                                if(lValue <= hValue){
                                                    isothermHigh.textColor = textColor = "#222";
                                                }else{
//                                                    console.log("不能高于最高温度")
                                                    textColor = "red";
                                                }
                                            }
                                            onEditingFinished:{
                                                let hValue = parseInt(isothermHigh.text);
                                                let lValue = parseInt(text);
                                                if(lValue <= hValue){
                                                    QGCCwGimbalController.isothermH = hValue;
                                                    QGCCwGimbalController.isothermL = lValue;
                                                    if((QGCCwGimbalController.ircamFlags & 0x10)){
                                                        QGCCwGimbalController.isoThermSwitch(hValue*10,lValue*10,true);
                                                    }
                                                }
                                            }
                                        }
                                        Text {
                                            text: "℃"
                                            font.pointSize:ScreenTools.mediumFontPointSize*0.8
                                            font.family:    ScreenTools.normalFontFamily
                                            color: qgcPal.text
                                            //                                       font.bold: true
                                        }

                                        Rectangle  {
                                            visible:false
                                            id: switchControl
                                            width: ScreenTools.defaultFontPixelWidth*7
                                            height: ScreenTools.defaultFontPixelWidth*3
                                            property bool isCheckedOn: true
                                            property bool isCheckedOff: false
                                            border.width: 2
                                            border.color:"gray"

                                            Layout.leftMargin: ScreenTools.defaultFontPixelWidth*1.5
                                            Rectangle{
                                                id: bg1
                                                width: parent.width/1.2
                                                height: parent.height
                                                anchors.left: parent.left
                                                color: switchControl.isCheckedOn ? "#fff" : "#9ca0a3"
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "区间内"
                                                    font.bold: true
                                                    font.pointSize: ScreenTools.isMobile ? ScreenTools.mediumFontPointSize*0.7 : ScreenTools.mediumFontPointSize*0.8
                                                    font.family:    ScreenTools.normalFontFamily
                                                    color: switchControl.isCheckedOn ? "black" : "white"
                                                }

                                                MouseArea{
                                                    anchors.fill: parent
                                                    cursorShape: "PointingHandCursor"
                                                    onClicked: {
                                                        switchControl.isCheckedOn = true;
                                                        switchControl.isCheckedOff = false;
                                                        //                                                    QGCCwGimbalController.inOutState(true);
                                                    }
                                                }
                                            }
                                            Rectangle{
                                                id: bg2
                                                anchors.left: bg1.right
                                                width: parent.width/1.2
                                                height: parent.height
                                                color: switchControl.isCheckedOff ? "#fff" : "#9ca0a3"
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "区间外"
                                                    font.bold: true
                                                    font.family:    ScreenTools.normalFontFamily
                                                    font.pointSize: ScreenTools.isMobile ? ScreenTools.mediumFontPointSize*0.7 : ScreenTools.mediumFontPointSize*0.8
                                                    color: switchControl.isCheckedOff ? "black" : "white"
                                                }
                                                MouseArea{
                                                    anchors.fill: parent
                                                    enabled: true
                                                    cursorShape: "PointingHandCursor"
                                                    onClicked: {
                                                        switchControl.isCheckedOff = true;
                                                        switchControl.isCheckedOn = false;
                                                        //                                                    QGCCwGimbalController.inOutState(false);
                                                    }
                                                }
                                            }

                                        }
                                    }

                                }

                                Rectangle {
                                    height: 1
                                    color: qgcPal.text
                                    Layout.fillWidth: true
                                    Layout.leftMargin: -_margins
                                    Layout.rightMargin: -_margins
                                }
                                QGCLabel {
                                    id:         tcpOrUdp
                                    text:       qsTr("UDP/TCP :")
                                }
                                Rectangle{
                                    Layout.topMargin: -ScreenTools.defaultFontPixelWidth
                                    Layout.preferredHeight: commCol.height + ScreenTools.defaultFontPixelWidth*2
                                    Layout.preferredWidth:  commCol.width + ScreenTools.defaultFontPixelWidth*2
                                    color:qgcPal.windowShade
                                    border.color: qgcPal.text
                                    border.width: 1
                                    GridLayout{
                                        id:                         commCol
                                        rows:2
                                        columns: 3
                                        columnSpacing:ScreenTools.defaultFontPixelWidth
                                        rowSpacing:ScreenTools.defaultFontPixelWidth
                                        QGCRadioButton {
                                            Layout.topMargin: ScreenTools.defaultFontPixelWidth/2
                                            Layout.row:1
                                            Layout.column:1
                                            text:               qsTr("UDP")
                                            checked:!QGCCwGimbalController.isTcp
                                            onClicked:     {
                                                QGCCwGimbalController.isTcp = !checked;
                                            }
                                        }

                                        QGCRadioButton {
                                            Layout.row:2
                                            Layout.column:1
                                            id:tcpBtn
                                            checked:QGCCwGimbalController.isTcp
                                            text:  qsTr("TCP")
                                            onClicked:  {
                                                if(inpText.acceptableInput){
                                                    QGCCwGimbalController.isTcp = checked;
                                                    inpText.color = "#000"

                                                }else{
                                                    inpText.color = "#ff0000"
                                                }
                                            }
                                        }

                                        TextField{
                                            Layout.column:2
                                            Layout.row:2
                                            id:inpText
                                            padding: ScreenTools.defaultFontPixelWidth/2
                                            Layout.preferredWidth:_comboFieldWidth //ScreenTools.defaultFontPixelWidth * 16  //ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 14 :
                                            Layout.preferredHeight:ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 4.6 : ScreenTools.defaultFontPixelWidth * 4
                                            text: QGCCwGimbalController.tcpAddr
                                            selectByMouse: true
                                            color: acceptableInput  ? "#000" : "#ff0000"
                                            font {
                                                family: "Microsoft Yahei"
                                                pointSize:ScreenTools.isMobile ? ScreenTools.defaultFontPointSize :ScreenTools.defaultFontPointSize * 1.1 //ScreenTools.defaultFontPixelWidth*1.2
                                            }
                                            validator:RegExpValidator{
                                                regExp: /^(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d{2}|2[0-4]\d|25[0-5])$/
                                            }

                                            onEditingFinished: {
                                                inpText.focus = false;
                                                if(acceptableInput){
                                                    QGCCwGimbalController.tcpAddr = text;
                                                    inpText.color = "#000"
                                                }else{
                                                    inpText.color = "#ff0000"
                                                }
                                            }
                                            onTextChanged: {
                                                if(acceptableInput){
                                                    inpText.color = "#000"
                                                }else{
                                                    inpText.color = "#ff0000"
                                                }
                                            }

                                        }
                                    }

                                }


                                Item { width: 1; height: _margins/2}
                                Rectangle {
                                    height: 1
                                    color: qgcPal.text
                                    Layout.fillWidth: true
                                    Layout.leftMargin: -_margins
                                    Layout.rightMargin: -_margins
                                }
                                QGCLabel {
                                    linkColor:          qgcPal.text
                                    text:"<a href=\"https://www.allxianfei.com\">https://www.allxianfei.com (PC)</a>"
                                    onLinkActivated:    Qt.openUrlExternally(link)
                                    Layout.alignment:   Qt.AlignHCenter
                                }
                                QGCLabel {
                                    text:               qsTr("V2.5.5")
                                    Layout.alignment:   Qt.AlignHCenter
                                }

                            }
                        }
                    }

                }
                //网络设置
                Item {
                    width: SwipeView.view.width
                    implicitHeight: childHeight2.implicitHeight +  _columnSpacing * 2
                    ScrollView {
                        anchors.fill: parent
                        contentHeight: childHeight2.implicitHeight
                        Rectangle{
                            id:childHeight2
                            width: _tabBoxWid
//                            height: parent.height
                            implicitHeight: Math.max((netColumn.height + btnHeight1.height +  _columnSpacing * 4),_root.height)
                            color: qgcPal.windowShade
                            anchors.horizontalCenter: parent.horizontalCenter // 水平居中
                            Column{
                                id:netColumn
                                spacing:  ScreenTools.isMobile ?  _columnSpacing/2 : _columnSpacing
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: _columnSpacing
                                Row {
                                    spacing:    ScreenTools.defaultFontPixelWidth
                                    QGCLabel {
                                        width:              _labelWidth
                                        anchors.baseline:   ipInp1.baseline
                                        text: QGCCwGimbalController.firmwareVer/10 >= 6 ?qsTr("IP") : qsTr("Controller IP")   //GCU版本号大于等于6，改为
                                    }
                                    QGCTextField {
                                        id:     ipInp1
                                        text: QGCCwGimbalController.ipAddr
                                        width:  _valueWidth
                                        inputMethodHints:       Qt.ImhFormattedNumbersOnly
                                        anchors.verticalCenter: parent.verticalCenter
                                        onEditingFinished: {
                                            QGCCwGimbalController.ipAddr = text;
                                        }
                                    }
                                }
                                Row {
                                    spacing:    ScreenTools.defaultFontPixelWidth
                                    QGCLabel {
                                        width:              _labelWidth
                                        anchors.baseline:   ipInp2.baseline
                                        text:               qsTr("Gateway IP")
                                    }
                                    QGCTextField {
                                        id:     ipInp2
                                        text:  QGCCwGimbalController.gatewayIpAddr
                                        width:  _valueWidth
                                        inputMethodHints:       Qt.ImhFormattedNumbersOnly
                                        anchors.verticalCenter: parent.verticalCenter
                                        onEditingFinished: {
                                            QGCCwGimbalController.gatewayIpAddr = text;
                                        }
                                    }
                                }

                                Row {
                                    spacing:    ScreenTools.defaultFontPixelWidth
                                    QGCLabel {
                                        width:              _labelWidth
                                        anchors.baseline:   ipInp3.baseline
                                        text:               qsTr("Subnet Mask")
                                    }
                                    QGCTextField {
                                        id:     ipInp3
                                        text: QGCCwGimbalController.subNetIpAddr
                                        width:  _valueWidth
                                        inputMethodHints:       Qt.ImhFormattedNumbersOnly
                                        anchors.verticalCenter: parent.verticalCenter
                                        onEditingFinished: {
                                            QGCCwGimbalController.subNetIpAddr = text;
                                        }
                                    }
                                }
                                Row {   //何时显示远端Ip???
                                    spacing:    ScreenTools.defaultFontPixelWidth
                                    visible: (QGCCwGimbalController.firmwareVer/10 >= 5) ? false : true // GCU版本号大于等于5,隐藏
                                    QGCLabel {
                                        width:              _labelWidth
                                        anchors.baseline:   ipInp4.baseline
                                        text:               qsTr("Remote IP")
                                    }
                                    QGCTextField {
                                        id:     ipInp4
                                        text:  QGCCwGimbalController.destIp1Addr
                                        width:  _valueWidth
                                        inputMethodHints:       Qt.ImhFormattedNumbersOnly
                                        anchors.verticalCenter: parent.verticalCenter
                                        onEditingFinished: {
                                            QGCCwGimbalController.destIp1Addr = text;
                                        }
                                    }
                                }
                                Row {
                                    spacing:    ScreenTools.defaultFontPixelWidth
                                    visible: (QGCCwGimbalController.firmwareVer/10 >= 6) ? false : true  // GCU版本号大于等于6,隐藏
                                    QGCLabel {
                                        width:              _labelWidth
                                        anchors.baseline:   ipInp5.baseline
                                        text:               qsTr("Camera IP")
                                    }
                                    QGCTextField {
                                        id:     ipInp5
                                        text: QGCCwGimbalController.cameraIpAddr
                                        width:  _valueWidth
                                        inputMethodHints:       Qt.ImhFormattedNumbersOnly
                                        anchors.verticalCenter: parent.verticalCenter
                                        onEditingFinished: {
                                            QGCCwGimbalController.cameraIpAddr = text;
                                        }
                                    }
                                }
                            }
                            Row{
                                id:btnHeight1
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: netColumn.bottom
                                anchors.topMargin: _columnSpacing*2
                                spacing:ScreenTools.defaultFontPixelWidth*3
                                Column {
                                    QGCButton {
                                        text:               qsTr("Reset")
                                        font.family: {
                                               if (Qt.locale().name.startsWith("zh")) {
                                                   return ScreenTools.isMobile ?
                                                          "Noto Sans CJK SC" :
                                                          "Microsoft YaHei"
                                               }
                                               return "Open Sans"
                                        }
                                        onClicked:  {
//                                            console.log("恢复默认")
                                            QGCCwGimbalController.resetParameters(1);
                                            //                                        QGCCwGimbalController.calibrateStatusCode=5
                                        }
                                    }
                                }
                                Column{
                                    QGCButton {
                                        function testEnabled() {
                                            if(!validateIPaddress(ipInp1.text))  return false
                                            if(!validateIPaddress(ipInp2.text)) return false
                                            if(!validateIPaddress(ipInp3.text))  return false
                                            if(!validateIPaddress(ipInp4.text))  return false
                                            if(!validateIPaddress(ipInp5.text)) return false
                                            if(isAllOnesMask(ipInp3.text)) return false
                                            return true
                                        }
                                        enabled:testEnabled()
                                        text:               qsTr("Save")
                                        onClicked:  {
                                            console.log("保存成功")
                                            QGCCwGimbalController.sendSaveParameters();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                //相机
                Item {
                    id:cameraIt
                    width: SwipeView.view.width
                    implicitHeight: {
                           if(QGCCwGimbalController.showCameraSet === 1){
                               return cameraItHei1.implicitHeight +  _columnSpacing * 2
                           } else if(QGCCwGimbalController.showCameraSet === 2){
                               return cameraItHei2.implicitHeight +  _columnSpacing * 2
                           } else {
                               return cameraInfo3.implicitHeight +  _columnSpacing * 2
                           }
                       }
                    //第一种相机显示页面
                    ScrollView {
                        anchors.fill: parent
                        contentHeight: cameraItHei1.implicitHeight
                        visible: QGCCwGimbalController.showCameraSet===1
                        clip: true
                        Rectangle{
//                            visible: QGCCwGimbalController.showCameraSet===1
                            id:cameraItHei1
                            width: _tabBoxWid
//                            height: parent.height
                            implicitHeight: Math.max((childrenRect.height  +  _columnSpacing * 3),_root.height)
                            color: qgcPal.windowShade
                            anchors.horizontalCenter: parent.horizontalCenter // 水平居中
                            Text {
                                text: qsTr("LOGIN")
                                font.pointSize:_defaultFont*1.2
                                anchors{
                                    left: parent.left
                                    leftMargin: ScreenTools.defaultFontPixelWidth
                                    top: parent.top
                                    topMargin: ScreenTools.defaultFontPixelWidth
                                }
                                color: "#009fff"

                            }
                            Column{
                                id:loginCont
                                spacing: ScreenTools.isMobile ?  _columnSpacing/2 : _columnSpacing
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: _columnSpacing
                                Row{
                                    spacing:    ScreenTools.defaultFontPixelWidth
                                    QGCLabel {
                                        width:              _labelWidth
                                        anchors.baseline:   loginIpInp.baseline
                                        text:               qsTr("Camera IP")
                                    }
                                    QGCTextField {
                                        id:     loginIpInp
                                        text: ""
                                        width:  _valueWidth
                                        inputMethodHints:       Qt.ImhFormattedNumbersOnly
                                        anchors.verticalCenter: parent.verticalCenter
                                        onEditingFinished: {
                                            QGCCwGimbalController.inputIpPort = text;
                                        }
                                    }
                                }

                                Row{
                                    visible:!ScreenTools.isMobile
                                    Text {
                                        id: name
                                        text: qsTr("*Login failed, Please check the network and fill in the correct camera IP address")
                                        font.family:ScreenTools.normalFontFamily
                                        color:"red"
                                    }
                                }
                                Column {
                                    visible:ScreenTools.isMobile
                                    Text {
                                        id: name2
                                        text: qsTr("*Login failed, Please check the network")
                                        font.family:ScreenTools.normalFontFamily
                                        color:"red"
                                    }
                                    Text {
                                        id: name3
                                        text: qsTr("and fill in the correct camera IP address")
                                        font.family:ScreenTools.normalFontFamily
                                        color:"red"
                                    }

                                }
                            }

                            Row{
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: loginCont.bottom
                                anchors.topMargin: ScreenTools.defaultFontPixelHeight*3
                                spacing:ScreenTools.defaultFontPixelWidth*3
                                QGCButton {
                                    function testEnabled() {
                                        if(!validateIPaddress(loginIpInp.text))  return false
                                        return true
                                    }
                                    enabled:testEnabled()
                                    text:               qsTr("LOGIN")
                                    onClicked:  {
                                        QGCCwGimbalController.cameraIpLogin(loginIpInp.text);
                                    }
                                }
                            }
                        }
                    }
                    //第二种相机显示页面
                    ScrollView {
                        anchors.fill: parent
                        contentHeight: cameraItHei2.implicitHeight
                        visible: QGCCwGimbalController.showCameraSet===2
                        Rectangle{
//                            visible: QGCCwGimbalController.showCameraSet===2
                            id:cameraItHei2
                            width:_tabBoxWid
//                            height: parent.height
                            implicitHeight:childrenRect.height  +  _columnSpacing * 5
                            color: qgcPal.windowShade
                            anchors.horizontalCenter: parent.horizontalCenter
                            Column{
                                id:camIpBox
                                spacing: ScreenTools.isMobile ?  _columnSpacing/2 : _columnSpacing
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: _columnSpacing
                                Row{
                                    spacing:    ScreenTools.defaultFontPixelWidth
                                    QGCLabel {
                                        width:              _labelWidth
                                        anchors.baseline:   camIpInp1.baseline
                                        text:               qsTr("Camera IP")
                                    }
                                    QGCTextField {
                                        id:     camIpInp1
                                        text:  QGCCwGimbalController.cameraRealIp
                                        width:  _valueWidth
                                        inputMethodHints:       Qt.ImhFormattedNumbersOnly
                                        anchors.verticalCenter: parent.verticalCenter
                                        onTextChanged: saveBtnEnable.enabled = saveBtnEnable.testEnabled()
                                        onEditingFinished: {
                                            QGCCwGimbalController.cameraRealIp = text;
                                        }
                                    }
                                }
                                Row{
                                    spacing:    ScreenTools.defaultFontPixelWidth
                                    QGCLabel {
                                        width:              _labelWidth
                                        anchors.baseline:   camIpInp2.baseline
                                        text:               qsTr("Gateway IP")
                                    }
                                    QGCTextField {
                                        id:     camIpInp2
                                        text:  QGCCwGimbalController.cameraGatewayIp
                                        width:  _valueWidth
                                        inputMethodHints:       Qt.ImhFormattedNumbersOnly
                                        anchors.verticalCenter: parent.verticalCenter
                                        onTextChanged: saveBtnEnable.enabled = saveBtnEnable.testEnabled()
                                        onEditingFinished: {
                                            QGCCwGimbalController.cameraGatewayIp = text;
                                        }
                                    }
                                }
                                Row{   //什么相机不显示？？？
                                    spacing:    ScreenTools.defaultFontPixelWidth
                                    QGCLabel {
                                        width:              _labelWidth
                                        anchors.baseline:   camIpInp3.baseline
                                        text:               qsTr("Subnet Mask")
                                    }
                                    QGCTextField {
                                        id:     camIpInp3
                                        text:  QGCCwGimbalController.cameraNetMask
                                        width:  _valueWidth
                                        inputMethodHints:       Qt.ImhFormattedNumbersOnly
                                        anchors.verticalCenter: parent.verticalCenter
                                        onTextChanged: saveBtnEnable.enabled = saveBtnEnable.testEnabled()
                                        onEditingFinished: {
                                            QGCCwGimbalController.cameraNetMask = text;
                                        }
                                    }
                                }

                            }
                            //RTSP
                            Rectangle{
                                id:streamSetBox
                                width: camIpBox.width + ScreenTools.defaultFontPixelWidth*8
                                height: colHeight.height + _columnSpacing * 2
                                color: qgcPal.windowShade
                                border.width: 1
                                border.color:"#A9A9A9"
                                anchors{
                                    top:camIpBox.bottom
                                    topMargin: _columnSpacing
                                }
                                anchors.horizontalCenter: parent.horizontalCenter

                                Rectangle{
                                    width:rtspTxt.contentWidth + ScreenTools.defaultFontPixelWidth*1.4
                                    height: rtspTxt.contentWidth
                                    color:qgcPal.windowShade
                                    anchors{
                                        top:streamSetBox.top
                                        left:streamSetBox.left
                                        topMargin: -ScreenTools.defaultFontPixelWidth*1.4
                                        leftMargin: ScreenTools.defaultFontPixelWidth*1.4

                                    }
                                    Text{
                                        id:rtspTxt
                                        text:"RTSP"
                                        font.pointSize:_defaultFont
                                        font.family:    ScreenTools.normalFontFamily;
                                        color: qgcPal.text
                                        anchors.centerIn: parent
                                    }
                                }

                                Column{
                                    id:colHeight
                                    spacing:    ScreenTools.isMobile ?  _columnSpacing/2 : _columnSpacing
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: _columnSpacing
                                    Row{
                                        spacing:    ScreenTools.defaultFontPixelWidth
                                        QGCLabel {
                                            width:              _labelWidth + _columnSpacing
                                            anchors.baseline:   ratInp.baseline
                                            text:               qsTr("Bitrate(b/s) (500~6000)")
                                        }
                                        QGCTextField {
                                            id:     ratInp
                                            text: QGCCwGimbalController.cameraBit
                                            width:  _valueWidth
                                            inputMethodHints:       Qt.ImhFormattedNumbersOnly
                                            anchors.verticalCenter: parent.verticalCenter
                                            validator: IntValidator {
                                                bottom:500
                                                top: 6000
                                            }
                                            onTextChanged: {
                                                let num = parseInt(text)
                                                if (isNaN(num) || num < 500 || num > 6000) {
                                                    saveBtnEnable.enabled=false;
                                                }else{
                                                    saveBtnEnable.enabled=true;
                                                }
                                            }
                                            onEditingFinished: {

                                                let value = parseInt(text)
                                                if (value < 500){
                                                    text = "500";
                                                    QGCCwGimbalController.cameraBit = "500";
                                                } else if (value > 6000){
                                                    text = "6000";
                                                    QGCCwGimbalController.cameraBit = "6000";
                                                }else{
                                                    QGCCwGimbalController.cameraBit = text;
                                                }
                                            }
                                        }
                                    }
                                    GridLayout{
                                        columns:    2
                                        QGCLabel {
                                            Layout.preferredWidth: _labelWidth+ScreenTools.defaultFontPixelWidth/2
                                            text:               qsTr("Resolution")
                                        }
                                        QGCComboBox{
                                            id:resolVal
                                            Layout.preferredWidth:_comboFieldWidth
                                            model:  [
                                                qsTr("720P"),
                                                qsTr("1080P")
                                            ]
                                            currentIndex:QGCCwGimbalController.cameraResolution == "1080P" ? 1 : 0
                                            onActivated:{
                                                if(index === 0){
                                                    QGCCwGimbalController.cameraResolution = "720P";
                                                }else{
                                                    QGCCwGimbalController.cameraResolution = "1080P";
                                                }

                                            }
                                        }
                                    }
                                    GridLayout{
                                        columns:    2
                                        visible: false // QGCCwGimbalController.cameraFps !== "none"
                                        QGCLabel {
                                            Layout.preferredWidth: _labelWidth+ScreenTools.defaultFontPixelWidth/2
                                            text:               qsTr("FPS")
                                        }
                                        QGCComboBox{
                                            id:fpsVal
                                            Layout.preferredWidth:_comboFieldWidth
                                            model:  [
                                                qsTr("30"),
                                                qsTr("60")
                                            ]
                                            currentIndex:QGCCwGimbalController.cameraFps == "60" ? 1 : 0
                                            onActivated:{
                                                if(index === 0){
                                                    QGCCwGimbalController.cameraFps = "30";
                                                }else{
                                                    QGCCwGimbalController.cameraFps = "60";
                                                }
                                            }
                                        }
                                    }
                                    GridLayout{
                                        columns:  videoDrop.visible ?  4 : 2
                                        QGCLabel {
                                            Layout.preferredWidth:videoDrop.visible ? _labelWidth/2 : (_labelWidth+ScreenTools.defaultFontPixelWidth/2)
                                            //                                        width:              _labelWidth / 2
                                            //                                        anchors.baseline:   codeDrop.baseline
                                            text:               qsTr("Encode")
                                        }
                                        QGCComboBox{
                                            id:codeDrop
                                            Layout.preferredWidth:videoDrop.visible ? _comboFieldWidth/2 : _comboFieldWidth
                                            model:  [
                                                qsTr("h.264"),
                                                qsTr("h.265")
                                            ]
                                            currentIndex: QGCCwGimbalController.cameraCodeType == "h.264" ? 0 : 1
                                            onActivated:{
                                                if(index === 0){
                                                    QGCCwGimbalController.cameraCodeType = "h.264";
                                                }else{
                                                    QGCCwGimbalController.cameraCodeType = "h.265";
                                                }
                                            }
                                        }

                                        QGCLabel {
                                            visible: videoDrop.visible
                                            Layout.alignment: Qt.AlignLeft
                                            Layout.leftMargin: _labelWidth/4
                                            Layout.preferredWidth: _labelWidth/1.7
                                            text:               qsTr("Video Quality")
                                        }
                                        QGCComboBox{
                                            visible: QGCCwGimbalController.cameraVQuality !== -1
                                            id:videoDrop
                                            Layout.preferredWidth:_comboFieldWidth/2
                                            model:  [
                                                qsTr("high"),
                                                qsTr("medium"),
                                                qsTr("low")
                                            ]
                                            currentIndex: QGCCwGimbalController.cameraVQuality
                                            onActivated:{
                                                QGCCwGimbalController.cameraVQuality = index;
                                            }
                                        }
                                    }

                                }
                            }

                            Row{
                                id:saveBtnHeight
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors{
                                    top:streamSetBox.bottom
                                    topMargin: _columnSpacing
                                }
                                QGCButton {
                                    id:saveBtnEnable
                                    function testEnabled() {
                                        let val = parseInt(ratInp.text);
                                        if(!validateIPaddress(camIpInp1.text)) { return false}
                                        if(!validateIPaddress(camIpInp2.text))  {return false}
                                        if(!validateIPaddress(camIpInp3.text)) { return false}
                                        if(isAllOnesMask(camIpInp3.text)) return false
                                        if((val<500 || val>6000)) {return false}
                                        return true
                                    }
                                    enabled:testEnabled()
                                    text:               qsTr("Save")
                                    onClicked:  {    //第二种相机
//                                        console.log(testEnabled())
//                                        console.log(validateIPaddress(camIpInp1.text))
//                                        if(!testEnabled()){
//                                            return
//                                        }

                                        let config = {
                                            "Eth0": camIpInp1.text,
                                            "TrackFrameDelay": videoDrop.currentIndex === 0 ? "28" : (videoDrop.currentIndex === 1 ? "33" : "39"),
                                            "StreamFps": fpsVal.currentIndex === 0 ? "30" : "60",
                                            "StreamType": codeDrop.currentIndex === 0 ? "h.264" : "h.265",
                                            "Resolution": resolVal.currentIndex === 0 ? "720P" : "1080P",
                                            "Bitrate": ratInp.text,
                                            "Eth0Gateway": camIpInp2.text,
                                            "Eth0NetMask": camIpInp3.text
                                        };

                                        QGCCwGimbalController.saveChangeParm(config);
                                    }
                                }

                            }

                            Rectangle{
                                width: _columnSpacing*10
                                height: _columnSpacing*5
                                anchors.bottom: saveBtnHeight.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: QGCCwGimbalController.saveState
                                z: QGroundControl.zOrderTopMost
                                border.width: 1
                                border.color: "#A9A9A9"
                                color: qgcPal.windowShade
                                Column {
                                    id: contentCol
                                    anchors.centerIn: parent
                                    spacing: _columnSpacing  // 子元素间距
                                    width: parent.width
                                    Text {
                                        text: qsTr("Setting Successful")
                                        color: qgcPal.text
                                        font.family:    ScreenTools.normalFontFamily;
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        font.pointSize: ScreenTools.defaultFontPointSize*1.2
                                    }
                                    QGCButton{
                                        text: qsTr("OK")
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        onClicked:{
                                            QGCCwGimbalController.saveState = false;
                                        }
                                    }

                                }
                            }


                        }
                    }
                    //第三种相机显示页面
                    ScrollView {
                        anchors.fill: parent
                        contentHeight: cameraInfo3.implicitHeight
                        visible: QGCCwGimbalController.showCameraSet===3
                        Rectangle{
//                            visible: QGCCwGimbalController.showCameraSet===3
                            id:cameraInfo3
                            width: _tabBoxWid
//                            height: parent.height
                            implicitHeight: Math.max((dvrSetBox.implicitHeight +  _columnSpacing * (QGCCwGimbalController.cameraConfs.length + 2)),_root.height)
                            color: qgcPal.windowShade
                            anchors.horizontalCenter: parent.horizontalCenter

                            Column{
                                id:dvrSetBox
                                spacing: ScreenTools.isMobile ?  _columnSpacing/2 : _columnSpacing
                                width: parent.width
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: _columnSpacing
                                Repeater{
                                    model:QGCCwGimbalController.cameraConfs
                                    delegate: Column {
                                        spacing: ScreenTools.isMobile ?  _columnSpacing/2 : _columnSpacing
//                                        visible: modelData.modifyis
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        Rectangle{
                                            width: camIpBox.width + ScreenTools.defaultFontPixelWidth*8
                                            height:  childrenRect.height + _columnSpacing/2
                                            color: qgcPal.windowShade
                                            border.width: 1
                                            border.color:"#A9A9A9"
                                            anchors.horizontalCenter: parent.horizontalCenter

                                            Rectangle{
                                                width:resTxt.contentWidth + ScreenTools.defaultFontPixelWidth*1.4
                                                height: resTxt.contentWidth
                                                color:qgcPal.windowShade
                                                anchors{
                                                    top:parent.top
                                                    left:parent.left
                                                    topMargin: modelData.label === "dvr" ? -ScreenTools.defaultFontPixelWidth*3.2 : -ScreenTools.defaultFontPixelWidth*1.7// ( modelData.label === "dvr" ? -ScreenTools.defaultFontPixelWidth*3.2 : -ScreenTools.defaultFontPixelWidth*1.4)
                                                    leftMargin: ScreenTools.defaultFontPixelWidth*1.4

                                                }
                                                Text{
                                                    id:resTxt
                                                    text:(modelData.label === "dvr" ? "Video Storage" : modelData.label)
                                                    font.capitalization: Font.AllUppercase
                                                    font.pointSize:_defaultFont
                                                    font.family:    ScreenTools.normalFontFamily;
                                                    color: qgcPal.text
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            property var paramIndex: modelData.configIndex
                                            Column {
                                                width: parent.width-_columnSpacing
                                                anchors.top: parent.top
                                                anchors.topMargin: _columnSpacing
                                                spacing: _columnSpacing/2
                                                Repeater {
                                                    model: modelData.parameters
                                                    RowLayout {
                                                        width: parent.width
                                                        spacing: _columnSpacing/2

                                                        Label {
                                                            text: modelData.chineseName + (modelData.type === "range" ? (" (" + modelData.min + "~" + modelData.max + ")") : "")
                                                            font.pointSize:_defaultFont
                                                            Layout.preferredWidth: _labelWidth + _columnSpacing
                                                            Layout.leftMargin: _columnSpacing
                                                            color: qgcPal.text
                                                        }

                                                        Loader {
                                                            sourceComponent: {
                                                                if (modelData.type === "array"){
                                                                    return comboBoxComponent
                                                                }

                                                                else if (modelData.type === "range")
                                                                    return rangeComponent
                                                                return undefined
                                                            }

                                                            property var paramData: modelData

                                                            Layout.fillWidth: true
                                                            Layout.preferredHeight: _columnSpacing*1.2
                                                        }


//                                                        Item {
//                                                           Layout.preferredWidth: _columnSpacing * 2  // Space for both icons
//                                                           Layout.preferredHeight: _columnSpacing
//                                                           Layout.alignment: Qt.AlignRight

//                                                           Row {
//                                                               spacing: 2
//                                                               anchors.right: parent.right

//                                                               // Success icon
//                                                               Image {
//                                                                   id: successIcon
//                                                                   width: _columnSpacing * 0.8
//                                                                   height: width
//                                                                   source: "qrc:/qmlimages/check.svg"
//                                                                   visible: modelData.saveStatus === "success"  // You'll need to add this property to your model
//                                                               }

//                                                               // Failure icon
//                                                               Image {
//                                                                   id: failureIcon
//                                                                   width: _columnSpacing * 0.8
//                                                                   height: width
//                                                                   source: "qrc:/qmlimages/x.svg"  // Replace with your failure icon path
//                                                                   visible: modelData.saveStatus === "failed"  // You'll need to add this property to your model
//                                                               }
//                                                           }

//                                                        }


                                                    }
                                                }
                                            }
                                        }


                                    }
                                }
                            }

                            Row{
                                id:saveBtnHeight2
                                height:_columnSpacing * 2
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors{
                                    top:dvrSetBox.bottom
                                    topMargin: _columnSpacing
                                }
                                QGCButton {
                                    id:saveConfBtnEnable
                                    text:               qsTr("Save")
                                    onClicked:  {
                                        QGCCwGimbalController.saveCameraConfs();
                                    }
                                }

                            }

                            Rectangle{
                                width: _columnSpacing*10
                                height: _columnSpacing*5
                                anchors.bottom: saveBtnHeight2.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: QGCCwGimbalController.saveState
                                z: QGroundControl.zOrderTopMost
                                border.width: 1
                                border.color: "#A9A9A9"
                                color: qgcPal.windowShade
                                Column {
                                    anchors.centerIn: parent
                                    spacing: _columnSpacing  // 子元素间距
                                    width: parent.width
                                    Text {
                                        text: qsTr("Setting Successful")
                                        color: qgcPal.text
                                        font.family:    ScreenTools.normalFontFamily;
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        font.pointSize: ScreenTools.defaultFontPointSize*1.2
                                    }
                                    QGCButton{
                                        text: qsTr("OK")
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        onClicked:{
                                            QGCCwGimbalController.saveState = false;
                                        }
                                    }

                                }
                            }
                        }
                    }
                }

                //S.BUS
                Item {
                    width: SwipeView.view.width
                    implicitHeight: columnWid.implicitHeight + _columnSpacing * 2

                    ScrollView {
                        anchors.fill: parent
                        contentHeight: columnWid.implicitHeight
                        Rectangle{
                            id:columnWid
                            width: _tabBoxWid
//                            height: parent.height
                            implicitHeight:childrenRect.height  +  _columnSpacing * 2
                            color: qgcPal.windowShade
                            anchors.horizontalCenter: parent.horizontalCenter // 水平居中
                            GridLayout{
                                id:setWidth
                                Layout.preferredWidth: _rowWidths
                                columns: 2
                                columnSpacing: 0
                                rowSpacing:0
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: _columnSpacing
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth:_rowCol1 //_root.columnWidths[0]
                                    Layout.preferredHeight: _tableHeight
                                    color: _rowColor
                                    Text { text: qsTr("Function"); font.pointSize:_defaultFont ;font.family:    ScreenTools.normalFontFamily;anchors.centerIn: parent;color: qgcPal.text }
                                }
                                GridLayout{
                                    id:setChildWidth
                                    Layout.fillWidth: true
                                    columns: 4
                                    columnSpacing: 0
                                    Layout.preferredWidth: _rowCol2
                                    Layout.preferredHeight: _tableHeight
                                    //                                color: _rowColor
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: _colW1 //_root.columnWidths[1]
                                        Layout.preferredHeight: _tableHeight
                                        color: _rowColor
                                        Text { text: qsTr("Channel"); font.pointSize:_defaultFont ;font.family:    ScreenTools.normalFontFamily;anchors.centerIn: parent;color: qgcPal.text }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: _colW2 //_root.columnWidths[2]
                                        Layout.preferredHeight: _tableHeight
                                        color: _rowColor
                                        Text { text: qsTr("Rev");font.pointSize:_defaultFont ;font.family:    ScreenTools.normalFontFamily; anchors.centerIn: parent;color: qgcPal.text }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: _colW3 // _root.columnWidths[3]
                                        Layout.preferredHeight: _tableHeight
                                        color: _rowColor
                                        Text { text: qsTr("Val");font.pointSize:_defaultFont ;font.family:    ScreenTools.normalFontFamily; anchors.centerIn: parent ;color: qgcPal.text}
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: _colW4 // _root.columnWidths[4]
                                        Layout.preferredHeight: _tableHeight

                                        color: _rowColor
                                        Text { text: qsTr("Definition");font.pointSize:_defaultFont ;font.family:    ScreenTools.normalFontFamily; anchors.centerIn: parent ;color: qgcPal.text}
                                    }
                                }
                            }

                            GridLayout{
                                id:setWidth2
                                Layout.preferredWidth:_rowWidths //_root._widths
                                columns: 2
                                columnSpacing: 0
                                rowSpacing:0
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: _columnSpacing + _tableHeight
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.preferredWidth:_rowCol1//setWidth2.Layout.preferredWidth*0.15 //_root.columnWidths[0] // Math.round( _root._widths*0.15) //_root.columnWidths[0] //Math.round( parent.Layout.preferredWidth*0.1)//columnWidths[0] //parent.Layout.preferredWidth*0.2
                                    Layout.preferredHeight:120
                                    Layout.row: 1
                                    Layout.column: 0
                                    Layout.rowSpan: 3
                                    color: qgcPal.windowShade
                                    Text{
                                        anchors.centerIn: parent;
                                        text:qsTr("Mode")
                                        font.pointSize:_defaultFont
                                        font.family:    ScreenTools.normalFontFamily
                                        //                                    font.pointSize:_dataShowValueSize
                                        color:qgcPal.text
                                    }
                                }
                                TableModule{
                                    id:setChildWidth2
                                    Layout.fillWidth: true
                                    //                                Layout.alignment: Qt.AlignRight
                                    rectWidth:_rowCol2 // Math.round(_root._widths*0.85) //_root.columnWidths[5] // Math.round(parent.Layout.preferredWidth*0.9 )//columnWidths[5] //parent.Layout.preferredWidth*0.2
                                    rectHeight:_rectHeight
                                    columnWidth1:_colW1 // _root.columnWidths[1]
                                    columnWidth2:_colW2 //_root.columnWidths[2]
                                    columnWidth3:_colW3 //_root.columnWidths[3]
                                    columnWidth4:_colW4 //_root.columnWidths[4]
                                    bgColor:"transparent"
                                    dropCheckedIndex:QGCCwGimbalController.sbusMap[0] === 255 ?  0 : QGCCwGimbalController.sbusMap[0]+1
                                    channelVal:QGCCwGimbalController.sbusData[0] === 0 ? "" : QGCCwGimbalController.sbusData[0]
                                    isChecked:QGCCwGimbalController.getSbusChecked(0)
                                    txtFir:qsTr("Follow")
                                    txtSec:qsTr("Lock")
                                    txtThi:qsTr("Mavlink")
                                    onDropCheckedChange:{
                                        if(checkIndex === 0) {
                                            //                                        QGCCwGimbalController.sbusMap[0] = 255;
                                            QGCCwGimbalController.setSbusMapValue(0, 255)
                                        }else{
                                            //                                        QGCCwGimbalController.sbusMap[0] = checkIndex - 1;
                                            QGCCwGimbalController.setSbusMapValue(0, checkIndex - 1)
                                        }
                                    }
                                    onCheckBoxClick:{
//                                        if (checked !== QGCCwGimbalController.getSbusChecked(0)) {
                                            QGCCwGimbalController.setSbusChecked(0, checked)
//                                        }
                                    }
                                }
                                TableModule{
                                    //                                Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignRight
                                    rectWidth:_rowCol2 //Math.round(parent.Layout.preferredWidth*0.85) //columnWidths[5] //parent.Layout.preferredWidth*0.2
                                    rectHeight:_rectHeight
                                    columnWidth1:_colW1 // _root.columnWidths[1]
                                    columnWidth2:_colW2 //_root.columnWidths[2]
                                    columnWidth3:_colW3 //_root.columnWidths[3]
                                    columnWidth4:_colW4 //_root.columnWidths[4]
                                    bgColor:"transparent"
                                    dropCheckedIndex:QGCCwGimbalController.sbusMap[10] === 255 ?  0 : QGCCwGimbalController.sbusMap[10]+1
                                    channelVal:QGCCwGimbalController.sbusData[10] === 0 ? "" : QGCCwGimbalController.sbusData[10]
                                    isChecked:QGCCwGimbalController.getSbusChecked(10)
                                    txtFir:qsTr("Downward")
                                    txtSec:qsTr("Lock")
                                    txtThi:qsTr("Gaze")
                                    onDropCheckedChange:{
                                        if(checkIndex === 0) {
                                            QGCCwGimbalController.setSbusMapValue(10, 255)
                                        }else{
                                            QGCCwGimbalController.setSbusMapValue(10, checkIndex - 1)
                                        }
                                    }
                                    onCheckBoxClick:{
//                                        console.log(checked)
//                                        if (checked !== QGCCwGimbalController.getSbusChecked(10)) {
                                            QGCCwGimbalController.setSbusChecked(10, checked)
//                                        }
                                    }
                                }
                                TableModule{
                                    //                                Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignRight
                                    rectWidth:_rowCol2 //Math.round(parent.Layout.preferredWidth*0.85) //columnWidths[5] //parent.Layout.preferredWidth*0.2
                                    rectHeight:_rectHeight
                                    columnWidth1:_colW1 // _root.columnWidths[1]
                                    columnWidth2:_colW2 //_root.columnWidths[2]
                                    columnWidth3:_colW3 //_root.columnWidths[3]
                                    columnWidth4:_colW4 //_root.columnWidths[4]
                                    bgColor:"transparent"
                                    dropCheckedIndex:QGCCwGimbalController.sbusMap[11] === 255 ?  0 : QGCCwGimbalController.sbusMap[11]+1
                                    channelVal:QGCCwGimbalController.sbusData[11] === 0 ? "" : QGCCwGimbalController.sbusData[11]
                                    isChecked:QGCCwGimbalController.getSbusChecked(11)
                                    txtFir:qsTr("None")
                                    //                                txtSec:"空"
                                    txtThi:qsTr("Reset ")
                                    onDropCheckedChange:{

                                        if(checkIndex === 0) {
                                            QGCCwGimbalController.setSbusMapValue(11, 255)
                                        }else{
                                            QGCCwGimbalController.setSbusMapValue(11, checkIndex - 1)
                                        }
                                    }
                                    onCheckBoxClick:{
//                                        console.log(checked)
//                                        if (checked !== QGCCwGimbalController.getSbusChecked(11)) {
                                            QGCCwGimbalController.setSbusChecked(11, checked)
//                                        }
                                    }
                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.preferredWidth:_rowCol1
                                    Layout.preferredHeight:_rectHeight
                                    color: _rowColor
                                    Text{
                                        anchors.centerIn: parent;
                                        text:qsTr("Track")
                                        font.pointSize:_defaultFont
                                        font.family:    ScreenTools.normalFontFamily
                                        color:qgcPal.text
                                    }
                                }
                                TableModule{
                                    Layout.alignment: Qt.AlignRight
                                    rectWidth:_rowCol2
                                    rectHeight:_rectHeight
                                    columnWidth1:_colW1
                                    columnWidth2:_colW2
                                    columnWidth3:_colW3
                                    columnWidth4:_colW4
                                    bgColor:_rowColor
                                    dropCheckedIndex:QGCCwGimbalController.sbusMap[3] === 255 ?  0 : QGCCwGimbalController.sbusMap[3]+1
                                    channelVal:QGCCwGimbalController.sbusData[3] === 0 ? "" : QGCCwGimbalController.sbusData[3]
                                    isChecked:QGCCwGimbalController.getSbusChecked(3)
                                    txtFir:qsTr("Exit")
                                    //                                txtSec:""
                                    txtThi:qsTr("Track")
                                    onDropCheckedChange:{

                                        if(checkIndex === 0) {
                                            QGCCwGimbalController.setSbusMapValue(3, 255)
                                        }else{
                                            QGCCwGimbalController.setSbusMapValue(3, checkIndex - 1)
                                        }
                                    }
                                    onCheckBoxClick:{
//                                        console.log(checked)
//                                        if (checked !== QGCCwGimbalController.getSbusChecked(3)) {
                                            QGCCwGimbalController.setSbusChecked(3, checked)
//                                        }
                                    }
                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.preferredWidth:_rowCol1
                                    Layout.preferredHeight:_rectHeight
                                    color: qgcPal.windowShade
                                    Text{
                                        anchors.centerIn: parent;
                                        text:qsTr("Pitch")
                                        font.pointSize:_defaultFont
                                        font.family:    ScreenTools.normalFontFamily
                                        color:qgcPal.text
                                    }
                                }
                                TableModule{
                                    Layout.alignment: Qt.AlignRight
                                    rectWidth:_rowCol2
                                    rectHeight:_rectHeight
                                    columnWidth1:_colW1
                                    columnWidth2:_colW2
                                    columnWidth3:_colW3
                                    columnWidth4:_colW4
                                    bgColor:"transparent"
                                    dropCheckedIndex:QGCCwGimbalController.sbusMap[1] === 255 ?  0 : QGCCwGimbalController.sbusMap[1]+1
                                    channelVal:QGCCwGimbalController.sbusData[1] === 0 ? "" : QGCCwGimbalController.sbusData[1]
                                    isChecked:QGCCwGimbalController.getSbusChecked(1)
                                    //                                txtFir:""
                                    //                                txtSec:""
                                    //                                txtThi:""
                                    onDropCheckedChange:{

                                        if(checkIndex === 0) {
                                            QGCCwGimbalController.setSbusMapValue(1, 255)
                                        }else{
                                            QGCCwGimbalController.setSbusMapValue(1, checkIndex - 1)
                                        }
                                    }
                                    onCheckBoxClick:{
//                                        console.log(checked)
//                                        if (checked !== QGCCwGimbalController.getSbusChecked(1)) {
                                            QGCCwGimbalController.setSbusChecked(1, checked)
//                                        }
                                    }
                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.preferredWidth:_rowCol1
                                    Layout.preferredHeight:_rectHeight
                                    color: _rowColor
                                    Text{
                                        anchors.centerIn: parent;
                                        text:qsTr("Yaw")
                                        font.pointSize:_defaultFont
                                        font.family:    ScreenTools.normalFontFamily
                                        color:qgcPal.text
                                    }
                                }
                                TableModule{
                                    Layout.alignment: Qt.AlignRight
                                    rectWidth:_rowCol2
                                    rectHeight:_rectHeight
                                    columnWidth1:_colW1
                                    columnWidth2:_colW2
                                    columnWidth3:_colW3
                                    columnWidth4:_colW4
                                    bgColor:_rowColor
                                    dropCheckedIndex:QGCCwGimbalController.sbusMap[2] === 255 ?  0 : QGCCwGimbalController.sbusMap[2]+1
                                    channelVal:QGCCwGimbalController.sbusData[2] === 0 ? "" : QGCCwGimbalController.sbusData[2]
                                    isChecked:QGCCwGimbalController.getSbusChecked(2)
                                    //                                txtFir:"退出"
                                    //                                txtSec:""
                                    //                                txtThi:"跟踪"
                                    onDropCheckedChange:{

                                        if(checkIndex === 0) {
                                            QGCCwGimbalController.setSbusMapValue(2, 255)
                                        }else{
                                            QGCCwGimbalController.setSbusMapValue(2, checkIndex - 1)
                                        }
                                    }
                                    onCheckBoxClick:{
//                                        console.log(checked)
//                                        if (checked !== QGCCwGimbalController.getSbusChecked(2)) {
                                            QGCCwGimbalController.setSbusChecked(2, checked)
//                                        }
                                    }
                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.preferredWidth:_rowCol1
                                    Layout.preferredHeight:_rectHeight
                                    color: qgcPal.windowShade
                                    Text{
                                        anchors.centerIn: parent;
                                        text:qsTr("Zoom")
                                        font.pointSize:_defaultFont
                                        font.family:    ScreenTools.normalFontFamily
                                        color:qgcPal.text
                                    }
                                }
                                TableModule{
                                    Layout.alignment: Qt.AlignRight
                                    rectWidth:_rowCol2
                                    rectHeight:_rectHeight
                                    columnWidth1:_colW1
                                    columnWidth2:_colW2
                                    columnWidth3:_colW3
                                    columnWidth4:_colW4
                                    bgColor:"transparent"
                                    dropCheckedIndex:QGCCwGimbalController.sbusMap[4] === 255 ?  0 : QGCCwGimbalController.sbusMap[4]+1
                                    channelVal: QGCCwGimbalController.sbusData[4] === 0 ? "" : QGCCwGimbalController.sbusData[4]
                                    isChecked:QGCCwGimbalController.getSbusChecked(4)
                                    txtFir:qsTr("Zoom Out")
                                    txtSec:qsTr("Stop")
                                    txtThi:qsTr("Zoom In")
                                    onDropCheckedChange:{
                                        //                                    if(checkIndex === 0) {
                                        //                                        QGCCwGimbalController.sbusMap[6] = 255;
                                        //                                    }else{
                                        //                                        QGCCwGimbalController.sbusMap[6] = checkIndex - 1;
                                        //                                    }
                                        if(checkIndex === 0) {
                                            QGCCwGimbalController.setSbusMapValue(4, 255)
                                        }else{
                                            QGCCwGimbalController.setSbusMapValue(4, checkIndex - 1)
                                        }
                                    }
                                    onCheckBoxClick:{
//                                        console.log(checked)
//                                        if (checked !== QGCCwGimbalController.getSbusChecked(4)) {
                                            QGCCwGimbalController.setSbusChecked(4, checked)
//                                        }
                                    }
                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.preferredWidth:_rowCol1
                                    Layout.preferredHeight:_rectHeight
                                    color: _rowColor
                                    Text{
                                        anchors.centerIn: parent;
                                        text:qsTr("Pic&Rec")
                                        font.pointSize:_defaultFont
                                        font.family:    ScreenTools.normalFontFamily
                                        color:qgcPal.text
                                    }
                                }
                                TableModule{
                                    Layout.alignment: Qt.AlignRight
                                    rectWidth:_rowCol2
                                    rectHeight:_rectHeight
                                    columnWidth1:_colW1
                                    columnWidth2:_colW2
                                    columnWidth3:_colW3
                                    columnWidth4:_colW4
                                    bgColor:_rowColor
                                    dropCheckedIndex:QGCCwGimbalController.sbusMap[6] === 255 ?  0 : QGCCwGimbalController.sbusMap[6]+1
                                    channelVal:QGCCwGimbalController.sbusData[6] === 0 ? "" : QGCCwGimbalController.sbusData[6]
                                    isChecked:QGCCwGimbalController.getSbusChecked(6)
                                    txtFir:qsTr("Video")
                                    txtSec:qsTr("None")
                                    txtThi:qsTr("Photo")
                                    onDropCheckedChange:{
                                        //                                    if(checkIndex === 0) {
                                        //                                        QGCCwGimbalController.sbusMap[7] = 255;
                                        //                                    }else{
                                        //                                        QGCCwGimbalController.sbusMap[7] = checkIndex - 1;
                                        //                                    }
                                        if(checkIndex === 0) {
                                            QGCCwGimbalController.setSbusMapValue(6, 255)
                                        }else{
                                            QGCCwGimbalController.setSbusMapValue(6, checkIndex - 1)
                                        }
                                    }
                                    onCheckBoxClick:{
//                                        console.log(checked)
//                                        if (checked !== QGCCwGimbalController.getSbusChecked(6)) {
                                            QGCCwGimbalController.setSbusChecked(6, checked)
//                                        }
                                    }
                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.preferredWidth:_rowCol1
                                    Layout.preferredHeight:_rectHeight
                                    color: qgcPal.windowShade
                                    Text{
                                        anchors.centerIn: parent;
                                        text:qsTr("VideoSwitch")
                                        font.pointSize:_defaultFont
                                        font.family: {
                                               if (Qt.locale().name.startsWith("zh")) {
                                                   return ScreenTools.isMobile ?
                                                          "Noto Sans CJK SC" :
                                                          "Microsoft YaHei"
                                               }
                                               return "Open Sans"
                                        }
                                        color:qgcPal.text
                                    }
                                }
                                TableModule{
                                    Layout.alignment: Qt.AlignRight
                                    rectWidth:_rowCol2
                                    rectHeight:_rectHeight
                                    columnWidth1:_colW1
                                    columnWidth2:_colW2
                                    columnWidth3:_colW3
                                    columnWidth4:_colW4
                                    bgColor:"transparent"
                                    dropCheckedIndex:QGCCwGimbalController.sbusMap[7] === 255 ?  0 : QGCCwGimbalController.sbusMap[7]+1
                                    channelVal:QGCCwGimbalController.sbusData[7] === 0 ? "" : QGCCwGimbalController.sbusData[7]
                                    isChecked:QGCCwGimbalController.getSbusChecked(7)
                                    txtFir:qsTr("Palette")
                                    txtSec:qsTr("None")
                                    txtThi:qsTr("PIP")
                                    onDropCheckedChange:{

                                        if(checkIndex === 0) {
                                            QGCCwGimbalController.setSbusMapValue(7, 255)
                                        }else{
                                            QGCCwGimbalController.setSbusMapValue(7, checkIndex - 1)
                                        }
                                    }
                                    onCheckBoxClick:{
//                                        console.log(checked)
//                                        if (checked !== QGCCwGimbalController.getSbusChecked(7)) {
                                            QGCCwGimbalController.setSbusChecked(7, checked)
//                                        }
                                    }
                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.preferredWidth:_rowCol1
                                    Layout.preferredHeight:_rectHeight
                                    color: _rowColor
                                    Text{
                                        anchors.centerIn: parent;
                                        text:qsTr("IRCUT")
                                        font.pointSize:_defaultFont
                                        font.family:    ScreenTools.normalFontFamily
                                        color:qgcPal.text
                                    }
                                }
                                TableModule{
                                    Layout.alignment: Qt.AlignRight
                                    rectWidth:_rowCol2
                                    rectHeight:_rectHeight
                                    columnWidth1:_colW1
                                    columnWidth2:_colW2
                                    columnWidth3:_colW3
                                    columnWidth4:_colW4
                                    bgColor:_rowColor
                                    dropCheckedIndex:QGCCwGimbalController.sbusMap[9] === 255 ?  0 : QGCCwGimbalController.sbusMap[9]+1
                                    channelVal:QGCCwGimbalController.sbusData[9] === 0 ? "" : QGCCwGimbalController.sbusData[9]
                                    isChecked:QGCCwGimbalController.getSbusChecked(9)
                                    txtFir:qsTr("Off")
                                    //                                txtSec:"空"
                                    txtThi:qsTr("On")
                                    onDropCheckedChange:{
                                        if(checkIndex === 0) {
                                            QGCCwGimbalController.setSbusMapValue(9, 255)
                                        }else{
                                            QGCCwGimbalController.setSbusMapValue(9, checkIndex - 1)
                                        }
                                    }
                                    onCheckBoxClick:{
//                                        console.log(checked)
//                                        if (checked !== QGCCwGimbalController.getSbusChecked(9)) {
                                            QGCCwGimbalController.setSbusChecked(9, checked)
//                                        }
                                    }
                                }
                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.preferredWidth:_rowCol1
                                    Layout.preferredHeight:_rectHeight
                                    color: qgcPal.windowShade
                                    Text{
                                        anchors.centerIn: parent;
                                        text:qsTr("Lamp")
                                        font.family:    ScreenTools.normalFontFamily
                                        font.pointSize:_defaultFont
                                        color:qgcPal.text
                                    }
                                }
                                TableModule{
                                    Layout.alignment: Qt.AlignRight
                                    rectWidth:_rowCol2
                                    rectHeight:_rectHeight
                                    columnWidth1:_colW1
                                    columnWidth2:_colW2
                                    columnWidth3:_colW3
                                    columnWidth4:_colW4
                                    bgColor:"transparent"
                                    dropCheckedIndex:QGCCwGimbalController.sbusMap[8] === 255 ?  0 : QGCCwGimbalController.sbusMap[8]+1
                                    channelVal:QGCCwGimbalController.sbusData[8] === 0 ? "" : QGCCwGimbalController.sbusData[8]
                                    isChecked:QGCCwGimbalController.getSbusChecked(8)
                                    txtFir:qsTr("Off")
                                    //                                txtSec:"空"
                                    txtThi:qsTr("On")
                                    onDropCheckedChange:{
                                        if(checkIndex === 0) {
                                            QGCCwGimbalController.setSbusMapValue(8, 255)
                                        }else{
                                            QGCCwGimbalController.setSbusMapValue(8, checkIndex - 1)
                                        }
                                    }
                                    onCheckBoxClick:{
//                                        if (checked !== QGCCwGimbalController.getSbusChecked(8)) {
                                            QGCCwGimbalController.setSbusChecked(8, checked)
//                                        }
                                    }
                                }

                                Rectangle{
                                    Layout.fillWidth: true
                                    Layout.preferredWidth:_rowCol1
                                    Layout.preferredHeight:_rectHeight
                                    color: _rowColor
                                    Text{
                                        anchors.centerIn: parent;
                                        text:qsTr("Range")
                                        font.family:    ScreenTools.normalFontFamily
                                        font.pointSize:_defaultFont
                                        color:qgcPal.text
                                    }
                                }
                                TableModule{
                                    Layout.alignment: Qt.AlignRight
                                    rectWidth:_rowCol2
                                    rectHeight:_rectHeight
                                    columnWidth1:_colW1
                                    columnWidth2:_colW2
                                    columnWidth3:_colW3
                                    columnWidth4:_colW4
                                    bgColor:_rowColor
                                    dropCheckedIndex:QGCCwGimbalController.sbusMap[12] === 255 ?  0 : QGCCwGimbalController.sbusMap[12]+1
                                    channelVal:QGCCwGimbalController.sbusData[12] === 0 ? "" : QGCCwGimbalController.sbusData[12]
                                    isChecked:QGCCwGimbalController.getSbusChecked(12)
                                    txtFir:qsTr("Off")
                                    //                                txtSec:"空"
                                    txtThi:qsTr("On")
                                    onDropCheckedChange:{
                                        if(checkIndex === 0) {
                                            QGCCwGimbalController.setSbusMapValue(12, 255)
                                        }else{
                                            QGCCwGimbalController.setSbusMapValue(12, checkIndex - 1)
                                        }
                                    }
                                    onCheckBoxClick:{
//                                        if (checked !== QGCCwGimbalController.getSbusChecked(12)) {
                                            QGCCwGimbalController.setSbusChecked(12, checked)
//                                        }
                                    }
                                }

                            }

                            Row{
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: setWidth2.bottom
                                anchors.topMargin: _columnSpacing
                                spacing:ScreenTools.defaultFontPixelWidth*3
                                Column {
                                    QGCButton {
                                        text:               qsTr("Reset")
                                        font.family: {
                                               if (Qt.locale().name.startsWith("zh")) {
                                                   return ScreenTools.isMobile ?
                                                          "Noto Sans CJK SC" :
                                                          "Microsoft YaHei"
                                               }
                                               return "Open Sans"
                                        }
                                        onClicked:  {
                                            QGCCwGimbalController.resetParameters(2);
                                            //                                        QGCCwGimbalController.calibrateStatusCode=5
                                        }
                                    }
                                }
                                Column{
                                    QGCButton {

                                        text:               qsTr("Save")
                                        onClicked:  {
                                            console.log("保存成功")
                                            QGCCwGimbalController.sendSaveParameters();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                // 校准
                Item {
                    width: SwipeView.view.width
                    implicitHeight:childHeight7.implicitHeight + _columnSpacing * 2
                    ScrollView {
                        anchors.fill: parent
                        contentHeight: childHeight7.implicitHeight
                        clip: true
                        Rectangle{
                            id:childHeight7
                            width: _tabBoxWid
                            implicitHeight: Math.max((childrenRect.height  +  _columnSpacing * 2),_root.height)
                            color: qgcPal.windowShade
                            anchors.horizontalCenter: parent.horizontalCenter
                            Rectangle{
                                anchors.top: parent.top
                                anchors.topMargin:_columnSpacing
                                width: columnBox.width + (_columnSpacing * 2)
                                height:columnBox.height + _columnSpacing
                                color: qgcPal.windowShade
                                anchors.horizontalCenter: parent.horizontalCenter
                                ColumnLayout{
                                    id:columnBox
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: ScreenTools.isMobile ? _columnSpacing/2 : _columnSpacing
                                    width: childrenRect.width // 自动宽度
                                    RowLayout{
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredHeight: icon.height // 固定高度
                                        Image{
                                            //                                            Layout.alignment: Qt.AlignHCenter
                                            id: icon
                                            smooth: true
                                            mipmap: true
                                            antialiasing: true
                                            source: "qrc:/qml/QGCCwGimbal/Controls/CalibrationWarn.png"
                                            height:ScreenTools.defaultFontPixelWidth*3
                                            fillMode: Image.PreserveAspectFit
                                            sourceSize.height: height
                                        }
                                    }
                                    RowLayout{
                                        visible:!ScreenTools.isMobile
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredHeight: textItem.implicitHeight > 0 ? textItem.implicitHeight : 10
                                        Text {
                                            id:textItem
                                            font.pointSize:_defaultFont
                                            font.family:ScreenTools.normalFontFamily
                                            color: qgcPal.text
                                            text: qsTr("Before calibration,please ensure that the pod is stationary (no need to return to center) until the calibration is completed")
                                        }
                                    }
                                    RowLayout {
                                        visible:ScreenTools.isMobile
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredHeight: columnContainer.implicitHeight // 固定高度
                                        Layout.preferredWidth: _tabBoxWid*0.8
                                        ColumnLayout  {
                                            id: columnContainer
                                            width: parent.width
                                            Text {
                                                id:textItem2
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignHCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                font.pointSize:_defaultFont
                                                font.family:ScreenTools.normalFontFamily
                                                color: qgcPal.text
                                                text: qsTr("Before calibration,please ensure that the pod is stationary")
                                                wrapMode: Text.WordWrap
                                            }
                                            Text {
                                                id:textItem3
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignHCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                font.pointSize:_defaultFont
                                                font.family:ScreenTools.normalFontFamily
                                                color: qgcPal.text
                                                text: qsTr("(no need to return to center) until the calibration is completed")
                                                wrapMode: Text.WordWrap
                                            }
                                        }

                                    }
                                    RowLayout{
                                        id:visLoading
                                        Layout.topMargin:ScreenTools.isMobile ? _columnSpacing/4 : _columnSpacing*1.8
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredHeight: visible ? implicitHeight : 0 // 关键修改
                                        visible : (QGCCwGimbalController.calibrateStatusCode === 1) ? true : false   //  || QGCCwGimbalController.calibrateStatusCode === 0
                                        AnimatedImage{
                                            Layout.alignment: Qt.AlignHCenter
                                            source: "qrc:/qml/QGCCwGimbal/Controls/Loading.gif"
//                                            sourceSize.width: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 3.2 : ScreenTools.defaultFontPixelWidth * 3.2
//                                            sourceSize.height: sourceSize.width

//                                            width: ScreenTools.defaultFontPixelWidth * 3.2 //sourceSize.width
//                                            height: width
                                            // 关键设置：保持宽高比
                                            fillMode: Image.PreserveAspectFit
                                            smooth: true
                                            mipmap: true
                                            antialiasing: true
                                        }
                                    }

                                    RowLayout{
                                        Layout.topMargin: ScreenTools.isMobile ? _columnSpacing/4 : _columnSpacing*1.8
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredHeight: visible ? implicitHeight : 0 // 关键修改
                                        visible : QGCCwGimbalController.calibrateStatusCode === 2 ? true : false
                                        Image{
                                            //                                            anchors.centerIn: parent
                                            Layout.alignment: Qt.AlignHCenter
                                            smooth: true
                                            mipmap: true
                                            antialiasing: true
                                            source: "qrc:/qml/QGCCwGimbal/Controls/SuccessIcon.png"
                                            height:ScreenTools.defaultFontPixelWidth*3.2
                                            fillMode: Image.PreserveAspectFit
                                            sourceSize.height: height
                                        }
                                    }
                                    RowLayout{
                                        Layout.topMargin: ScreenTools.isMobile ? _columnSpacing/4 : _columnSpacing*1.8
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredHeight: visible ? implicitHeight : 0 // 关键修改
                                        visible : QGCCwGimbalController.calibrateStatusCode === 3 ? true : false
                                        Image{
                                            //                                            anchors.centerIn: parent
                                            Layout.alignment: Qt.AlignHCenter
                                            smooth: true
                                            mipmap: true
                                            antialiasing: true
                                            source: "qrc:/qml/QGCCwGimbal/Controls/FailIcon.png"
                                            height:ScreenTools.defaultFontPixelWidth*3.2
                                            fillMode: Image.PreserveAspectFit
                                            sourceSize.height: height
                                        }
                                    }

                                    RowLayout{
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredHeight: textResult.implicitHeight // 固定高度
                                        Text {
                                            id:textResult
                                            //                                                anchors.centerIn: parent
                                            font.pointSize:ScreenTools.defaultFontPointSize*1.2
                                            font.family:ScreenTools.normalFontFamily
                                            color: qgcPal.text //QGCCwGimbalController.calibrateStatusCode === 2 ? "#009fff" : (QGCCwGimbalController.calibrateStatusCode === 3 ? "red" : "#000")
                                            text: (QGCCwGimbalController.calibrateStatusCode === 2) ? qsTr("Calibration Successful") : (QGCCwGimbalController.calibrateStatusCode === 3 ? qsTr("Calibration Failed") :( visLoading.visible ? qsTr("Calibrating...") : ""))
                                        }
                                        //                                        }
                                    }

                                    RowLayout{
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.topMargin: _columnSpacing
                                        Layout.preferredHeight: calibrateButton.height // 固定高度
                                        QGCButton {
                                            id:calibrateButton
                                            enabled:!visLoading.visible
                                            text:               qsTr("Calib")
                                            //                                            Layout.alignment:   Qt.AlignHCenter
                                            onClicked:  {
                                               QGCCwGimbalController.calibrateFun();

                                            }
                                        }

                                    }

                                }
                            }

                        }
                    }
                }
                //载机数据
                Item {
                    width: SwipeView.view.width
                    implicitHeight: childHeight8.implicitHeight + _columnSpacing * 2
                    ScrollView {
                        anchors.fill: parent
                        contentHeight: childHeight8.implicitHeight
                        Rectangle{
                            id:childHeight8
                            width:_tabBoxWid
//                            height: parent.height
                            implicitHeight: Math.max(( childrenRect.height +  _columnSpacing * 2),_root.height)
                            color: qgcPal.windowShade
                            anchors.horizontalCenter: parent.horizontalCenter // 水平居中
                            Column{
                                spacing:  ScreenTools.isMobile ?  _columnSpacing/4 : _columnSpacing/2
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: _columnSpacing
                                Rectangle{
                                    width:_root.width*0.7
                                    height:_tableHeight
                                    color: _rowColor
                                    Text{
                                        anchors.centerIn: parent;
                                        text:qsTr("GNSS")
                                        font.pointSize:_defaultFont
                                        font.family:    ScreenTools.normalFontFamily;
                                        color:qgcPal.text
                                    }
                                }
                                Rectangle{
                                    width:_root.width*0.7
                                    height:_tableHeight
                                    color: qgcPal.windowShade
                                    Text{
                                        anchors.centerIn: parent;
                                        text:QGCCwGimbalController.gpsState === 0 ? qsTr("UNFIXED") : (QGCCwGimbalController.gpsState === 1 ? qsTr("FIXED") : qsTr("Unknown"))
                                        font.pointSize:_dataShowValueSize
                                        font.family:    ScreenTools.normalFontFamily;
                                        color:qgcPal.text
                                    }
                                }
                                Row{
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: _rowColor
                                        Text{
                                            anchors.centerIn: parent;
                                            text:qsTr("Roll")
                                            font.pointSize:_defaultFont
                                            font.family:    ScreenTools.normalFontFamily;
                                            color:qgcPal.text
                                        }
                                    }
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: _rowColor
                                        Text{
                                            anchors.centerIn: parent;
                                            text:qsTr("Pitch")
                                            font.pointSize:_defaultFont
                                            font.family:    ScreenTools.normalFontFamily;
                                            color:qgcPal.text
                                        }
                                    }
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: _rowColor
                                        Text{
                                            anchors.centerIn: parent;
                                            text:qsTr("Yaw")
                                            font.pointSize:_defaultFont
                                            font.family:    ScreenTools.normalFontFamily;
                                            color:qgcPal.text
                                        }
                                    }
                                }
                                Row{
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: qgcPal.windowShade
                                        Text{
                                            anchors.centerIn: parent;
                                            text:QGCCwGimbalController.carrierRoll
                                            font.pointSize:_dataShowValueSize
                                            color:qgcPal.text
                                        }
                                    }
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: qgcPal.windowShade
                                        Text{
                                            anchors.centerIn: parent;
                                            text:QGCCwGimbalController.carrierPitch
                                            font.pointSize:_dataShowValueSize
                                            color:qgcPal.text
                                        }
                                    }
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: qgcPal.windowShade
                                        Text{
                                            anchors.centerIn: parent;
                                            text:QGCCwGimbalController.carrierYaw
                                            font.pointSize:_dataShowValueSize
                                            color:qgcPal.text
                                        }
                                    }
                                }

                                Row{
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: _rowColor
                                        Text{
                                            anchors.centerIn: parent;
                                            text:qsTr("Acc_N")
                                            font.pointSize:_defaultFont
                                            font.family:    ScreenTools.normalFontFamily;
                                            color:qgcPal.text
                                        }
                                    }
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: _rowColor
                                        Text{
                                            anchors.centerIn: parent;
                                            text:qsTr("Acc_E")
                                            font.pointSize:_defaultFont
                                            font.family:    ScreenTools.normalFontFamily;
                                            color:qgcPal.text
                                        }
                                    }
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: _rowColor
                                        Text{
                                            anchors.centerIn: parent;
                                            text:qsTr("Acc_U")
                                            font.pointSize:_defaultFont
                                            font.family:    ScreenTools.normalFontFamily;
                                            color:qgcPal.text
                                        }
                                    }
                                }
                                Row{
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: qgcPal.windowShade
                                        Text{
                                            anchors.centerIn: parent;
                                            text:((QGCCwGimbalController.carrierAccN/100)+ Number.EPSILON).toFixed(2)
                                            font.pointSize:_dataShowValueSize
                                            color:qgcPal.text
                                        }
                                    }
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: qgcPal.windowShade
                                        Text{
                                            anchors.centerIn: parent;
                                            text:((QGCCwGimbalController.carrierAccE/100)+ Number.EPSILON).toFixed(2)
                                            font.pointSize:_dataShowValueSize
                                            color:qgcPal.text
                                        }
                                    }
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: qgcPal.windowShade
                                        Text{
                                            anchors.centerIn: parent;
                                            text:((QGCCwGimbalController.carrierAccU/100)+ Number.EPSILON).toFixed(2)
                                            font.pointSize:_dataShowValueSize
                                            color:qgcPal.text
                                        }
                                    }
                                }

                                Row{
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: _rowColor
                                        Text{
                                            anchors.centerIn: parent;
                                            text:qsTr("Camera Roll")
                                            font.pointSize:_defaultFont
                                            font.family:    ScreenTools.normalFontFamily;
                                            color:qgcPal.text
                                        }
                                    }
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: _rowColor
                                        Text{
                                            anchors.centerIn: parent;
                                            text:qsTr("Camera Pitch")
                                            font.pointSize:_defaultFont
                                            font.family:    ScreenTools.normalFontFamily;
                                            color:qgcPal.text
                                        }
                                    }
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: _rowColor
                                        Text{
                                            anchors.centerIn: parent;
                                            text:qsTr("Camera Yaw")
                                            font.pointSize:_defaultFont
                                            font.family:    ScreenTools.normalFontFamily;
                                            color:qgcPal.text
                                        }
                                    }
                                }
                                Row{
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: qgcPal.windowShade
                                        Text{
                                            anchors.centerIn: parent;
                                            text:QGCCwGimbalController.roll
                                            font.pointSize:_dataShowValueSize
                                            color:qgcPal.text
                                        }
                                    }
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: qgcPal.windowShade
                                        Text{
                                            anchors.centerIn: parent;
                                            text:QGCCwGimbalController.pitch
                                            font.pointSize:_dataShowValueSize
                                            color:qgcPal.text
                                        }
                                    }
                                    Rectangle{
                                        width:_root.width*0.7/3
                                        height:_tableHeight
                                        color: qgcPal.windowShade
                                        Text{
                                            anchors.centerIn: parent;
                                            text:QGCCwGimbalController.yaw
                                            font.pointSize:_dataShowValueSize
                                            color:qgcPal.text
                                        }
                                    }
                                }

                            }

                        }

                    }
                }

                //高级设置
                Item {
                    visible: btn7.visible
                    width: SwipeView.view.width
                    implicitHeight:childHeight9.implicitHeight + _columnSpacing * 2
                    ScrollView {
                        anchors.fill: parent
                        contentHeight: childHeight9.implicitHeight
                        Rectangle{
                            id:childHeight9
                            width: _tabBoxWid
//                            height: parent.height
                            implicitHeight: Math.max((childrenRect.height +  _columnSpacing * 2),_root.height)
                            color: qgcPal.windowShade
                            anchors.horizontalCenter: parent.horizontalCenter // 水平居中

                            Column{
                                id:advancedSet
                                spacing:    ScreenTools.isMobile ? _columnSpacing/2 : _columnSpacing
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: _columnSpacing

                                GridLayout{
                                    columns:    2
                                    QGCLabel {
                                        Layout.preferredWidth:              _labelWidth
                                        text: qsTr("OSD")
                                        font.pointSize:_defaultFont
                                    }
                                    Rectangle{
                                        Layout.preferredWidth:  _valueWidth
                                        height: _switchBtnHe
                                        SwitchModule{
                                            isOn: (QGCCwGimbalController.osdState === 1) ? true : false
                                            onText:qsTr("OPEN")
                                            offText:qsTr("OFF")
                                            onOnOffClick:{
                                                if(isOn){
                                                    QGCCwGimbalController.osdSwitch(1);
                                                }else{
                                                    QGCCwGimbalController.osdSwitch(0);
                                                }
                                            }
                                        }

                                    }
                                }

                                GridLayout{
                                    columns:    2
                                    visible: QGCCwGimbalController.timeZoneAvailable
                                    QGCLabel {
                                        Layout.preferredWidth:              _labelWidth
                                        text: qsTr("OSD Time Zone")
                                        font.pointSize:_defaultFont
                                    }
                                    QGCComboBox{
                                        id:osdSelect
                                        Layout.preferredWidth:_valueWidth
                                        textRole: "text"
                                        model: ListModel {
                                            id:tzModel
                                            ListElement { text: "UTC-12:00"; offset:-12 }
                                            ListElement { text: "UTC-11:00"; offset:-11 }
                                            ListElement { text: "UTC-10:00"; offset:-10 }
                                            ListElement { text: "UTC-09:00"; offset:-9 }
                                            ListElement { text: "UTC-08:00"; offset:-8 }
                                            ListElement { text: "UTC-07:00"; offset:-7 }
                                            ListElement { text: "UTC-06:00"; offset:-6 }
                                            ListElement { text: "UTC-05:00"; offset:-5 }
                                            ListElement { text: "UTC-04:00"; offset:-4 }
                                            ListElement { text: "UTC-03:00"; offset:-3 }
                                            ListElement { text: "UTC-02:00"; offset:-2 }
                                            ListElement { text: "UTC-01:00"; offset:-1 }
                                            ListElement { text: "UTC±00:00"; offset:0 }
                                            ListElement { text: "UTC+01:00"; offset:1 }
                                            ListElement { text: "UTC+02:00"; offset:2 }
                                            ListElement { text: "UTC+03:00"; offset:3 }
                                            ListElement { text: "UTC+04:00"; offset:4 }
                                            ListElement { text: "UTC+05:00"; offset:5 }
                                            ListElement { text: "UTC+06:00"; offset:6 }
                                            ListElement { text: "UTC+07:00"; offset:7 }
                                            ListElement { text: "UTC+08:00"; offset:8 }
                                            ListElement { text: "UTC+09:00"; offset:9 }
                                            ListElement { text: "UTC+10:00"; offset:10 }
                                            ListElement { text: "UTC+11:00"; offset:11 }
                                            ListElement { text: "UTC+12:00"; offset:12 }
                                            ListElement { text: "UTC+13:00"; offset:13 }
                                            ListElement { text: "UTC+14:00"; offset:14 }
                                        }

                                        currentIndex: {
                                            // 每次 myClass.timezoneOffset 变化时重新计算
                                            for (let i = 0; i < tzModel.count; ++i) {
                                                if (tzModel.get(i).offset === QGCCwGimbalController.timeZoneVal ) {
                                                    return i;
                                                }
                                            }

                                            return 0; // 默认选项
                                        }


                                        //                                    property int currentOffset: QGCCwGimbalController.timeZone
                                        //                                    onCurrentOffsetChanged: {
                                        //                                       for (var i = 0; i < tzModel.count; ++i) {
                                        //                                           if (tzModel.get(i).offset === currentOffset) {
                                        //                                               currentIndex = i;
                                        //                                               return;
                                        //                                           }
                                        //                                       }
                                        //                                       currentIndex = 0; // 默认选项
                                        //                                    }
                                        onActivated:{
                                            //不设置值的话,应该直接发命令,遥测包1s读取一次
                                            let val = tzModel.get(index).offset;
                                            osdSelect.currentIndex = index;
                                            QGCCwGimbalController.timeZone = val;
                                            QGCCwGimbalController.userConfigFun(0x20,0,0,0,0,0,val);

                                        }
                                    }
                                }

                                GridLayout{
                                    columns:    2
                                    visible: QGCCwGimbalController.osdDataAvailable
                                    QGCLabel {
                                        Layout.preferredWidth:              _labelWidth
                                        text: qsTr("OSD Coordinate")
                                        font.pointSize:_defaultFont
                                    }
                                    Rectangle{
                                        Layout.preferredWidth:  _valueWidth
                                        height: _switchBtnHe
                                        SwitchModule{
                                            isOn:(QGCCwGimbalController.osdDataMean === 1) ? true : false
                                            onText:qsTr("Target")
                                            offText:qsTr("Carrier")
                                            onOnOffClick:{
                                                if(isOn){
                                                    QGCCwGimbalController.userConfigFun(0x04,0,0,0x01,0,0,0);
                                                }else{
                                                    QGCCwGimbalController.userConfigFun(0x04,0,0,0x00,0,0,0);
                                                }
                                            }
                                        }

                                    }
                                }
                                GridLayout{
                                    columns:    2
                                    visible: false// 现在默认自动倒置  QGCCwGimbalController.imageInversAvailable
                                    QGCLabel {
                                        Layout.preferredWidth:              _labelWidth
                                        text: qsTr("Image Reverse")
                                        font.pointSize:_defaultFont
                                    }
                                    Rectangle{
                                        Layout.preferredWidth:  _valueWidth
                                        height: _switchBtnHe
                                        SwitchModule{
                                            isOn:(QGCCwGimbalController.imageInvers === 1) ? false : true
                                            onText:qsTr("AUTO")
                                            offText:qsTr("OFF")
                                            onOnOffClick:{
                                                if(isOn){
                                                    QGCCwGimbalController.userConfigFun(0x02,0,0x00,0,0,0,0);
                                                }else{
                                                    QGCCwGimbalController.userConfigFun(0x02,0,0x01,0,0,0,0);
                                                }
                                            }
                                        }

                                    }
                                }
                                GridLayout{
                                    columns:    2
                                    visible: false //QGCCwGimbalController.trackZoomAvailable
                                    QGCLabel {
                                        Layout.preferredWidth:              _labelWidth
                                        text: qsTr("Target Adaptive Zoom")
                                        font.pointSize:_defaultFont
                                    }
                                    Rectangle{
                                        Layout.preferredWidth:  _valueWidth
                                        height: _switchBtnHe
                                        SwitchModule{
                                            isOn:(QGCCwGimbalController.trackZoomSta === 1) ? true : false
                                            onText:qsTr("OPEN")
                                            offText:qsTr("OFF")
                                            onOnOffClick:{
                                                if(isOn){
                                                    QGCCwGimbalController.userConfigFun(0x10,0,0,0,0,0x01,0);
                                                }else{
                                                    QGCCwGimbalController.userConfigFun(0x10,0,0,0,0,0x00,0);
                                                }
                                            }
                                        }

                                    }
                                }

                                GridLayout{
                                    columns:    2
                                    visible: false //QGCCwGimbalController.autoTrackAvailable
                                    QGCLabel {
                                        Layout.preferredWidth:              _labelWidth
                                        text: qsTr("Tracking on Detecting")
                                        font.pointSize:_defaultFont
                                    }
                                    Rectangle{
                                        Layout.preferredWidth:  _valueWidth
                                        height: _switchBtnHe
                                        SwitchModule{
                                            isOn:(QGCCwGimbalController.tracSta === 1) ? false : true
                                            onText:qsTr("OPEN")
                                            offText:qsTr("OFF")
                                            onOnOffClick:{
                                                if(isOn){
                                                    QGCCwGimbalController.userConfigFun(0x01,0x00,0,0,0,0,0);
                                                }else{
                                                    QGCCwGimbalController.userConfigFun(0x01,0x01,0,0,0,0,0);
                                                }
                                            }
                                        }

                                    }
                                }

                                GridLayout{
                                    columns:    2
                                    visible: QGCCwGimbalController.recognizeAvailable
                                    QGCLabel {
                                        Layout.preferredWidth:              _labelWidth
                                        text: qsTr("Target Detection")
                                        font.pointSize:_defaultFont
                                    }
                                    Rectangle{
                                        Layout.preferredWidth:  _valueWidth
                                        height: _switchBtnHe
                                        SwitchModule{
                                            isOn:(QGCCwGimbalController.recognizeSta === 1) ? true : false
                                            onText:qsTr("OPEN")
                                            offText:qsTr("OFF")
                                            onOnOffClick:{
                                                if(isOn){
                                                    QGCCwGimbalController.userConfigFun(0x08,0,0,0,0x01,0,0);
                                                }else{
                                                    QGCCwGimbalController.userConfigFun(0x08,0,0,0,0x00,0,0);
                                                    QGCCwGimbalController.trackBtnState = false;
                                                }
                                            }
                                        }

                                    }
                                }

                            }

                        }
                    }
                }




                Component {
                    id: comboBoxComponent
                    QGCComboBox{
                        Layout.preferredWidth:_comboFieldWidth
                        model: paramData.options
                        currentIndex:model.indexOf(paramData.value)

                        onActivated:{

                            let val = model[currentIndex].replace("x", ",");


                            QGCCwGimbalController.updateCameraConfs(
                               paramData.configIndex,
                               paramData.paramName,
                               val  //model[currentIndex] //
                            )

                        }
                    }

                }

                Component {
                    id: rangeComponent
                    QGCTextField {
                        text: paramData.value
                        width:  _valueWidth
                        inputMethodHints:       Qt.ImhFormattedNumbersOnly
                        anchors.verticalCenter: parent.verticalCenter
                        validator: IntValidator {
                            bottom:paramData.min
                            top: paramData.max
                        }
                        onTextChanged: {
                            let num = parseInt(text)
                            if (isNaN(num) || num < paramData.min || num > paramData.max) {
                               saveConfBtnEnable.enabled=false;
                            }else{
                                saveConfBtnEnable.enabled=true;
                            }
                        }
                        onEditingFinished: {
                            let value = parseInt(text)
                            if (value <  paramData.min){
                                text =  paramData.min;
                            }
                            if (value > paramData.max){
                                text = paramData.max;
                            }

//                            console.log("New text:", text)

                            QGCCwGimbalController.updateCameraConfs(
                                paramData.configIndex,
                                paramData.paramName,
                                text
                            )

                        }
                    }

                }
            }

        }

    }
}
