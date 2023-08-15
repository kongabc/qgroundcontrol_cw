Rectangle{
	id:zoomRect
	width:  ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth*3.8 : ScreenTools.defaultFontPixelWidth*2.6
	height:ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth*16 :ScreenTools.defaultFontPixelWidth*15
	anchors.bottom: photoVideoControl.bottom
	anchors.left:photoVideoControl.left
	anchors.leftMargin: -ScreenTools.defaultFontPixelWidth*5
	color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0,0,0,0.35)
	radius: ScreenTools.defaultFontPixelWidth / 2
	Item{
		id:headerColumn
		height:ScreenTools.defaultFontPixelWidth*1.5
		width: zoomRect.width
		anchors.top: parent.top
		anchors.topMargin: ScreenTools.isMobile ? 4:2
		Label {
			anchors.centerIn: parent
			color: "#fff"
			font.bold: true
			font.pointSize: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth : ScreenTools.defaultFontPixelWidth*1.8
			text:"+"
		}
	}
	Item{
		id:bottomColumn
		height: ScreenTools.defaultFontPixelWidth*1.5
		width: zoomRect.width
		anchors.bottom: parent.bottom
		anchors.bottomMargin: ScreenTools.isMobile ? 2:1
		Label {
			color: "#fff"
			anchors.centerIn: parent
			font.bold: true
			font.pointSize: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth*1.4 : ScreenTools.defaultFontPixelWidth*1.8
			text:"-"
		}
	}

	Timer{
		id:timerSend
		interval:10
		repeat: true
		onTriggered: {
			circleRect.color = "#FFF291"
			if(circleRect.y > Math.round(zoomRect.height/2 - circleRect.height/2)){
				QGCCwGimbalController.videoZoom(-1);
			}else if(circleRect.y < zoomRect.height/2){
				QGCCwGimbalController.videoZoom(1);
			}else{
				QGCCwGimbalController.videoZoom(0);
			}
		}
	}

	Rectangle{
		id:circleRect
		width:ScreenTools.isMobile ? Math.round(ScreenTools.defaultFontPixelWidth*4) : Math.round(ScreenTools.defaultFontPixelWidth*2.8)
		height: width
		radius:width/2
		color: "#fff"
		y: (zoomRect.height-circleRect.height)/2
		x:(zoomRect.width-circleRect.width)/2
		MouseArea{
			anchors.fill: parent
			cursorShape: "PointingHandCursor"
			hoverEnabled: true
			onEntered:
			{
				circleRect.color = "#FFF291"
			}
			onExited:
			{
				circleRect.color = "#FFF"
			}
		}
	}
	MouseArea{
		id:dragArea
		anchors.fill: parent
		anchors.leftMargin: -ScreenTools.defaultFontPixelWidth*1.2
		anchors.rightMargin:-ScreenTools.defaultFontPixelWidth*1.2
		onPressed: {
			if(mouse.y > 0 && mouse.y < zoomRect.height){
				timerSend.start()
				if(mouse.y < circleRect.height){
					circleRect.y =0// Math.round(circleRect.height/2)
				}else{
					circleRect.y = Math.round(mouse.y-circleRect.height)
				}
				isStartMove = true
			}
		}

		onPositionChanged:{
			if(isStartMove){

				if(mouse.y >0 && mouse.y < zoomRect.height ){
					if(mouse.y < circleRect.height){
						circleRect.y = 0
					}else{
						circleRect.y = Math.round(mouse.y-circleRect.height)
					}
				}
			}
		}
		onReleased: {
			isStartMove = false
			timerSend.stop()
			circleRect.color = "#FFF"
			circleRect.y = Math.round(zoomRect.height-circleRect.height)/2
			QGCCwGimbalController.videoZoom(0);
		}
	}
}