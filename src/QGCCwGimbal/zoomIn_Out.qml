Rectangle{
	id:zoomRect
	width:  ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth*3.8 : ScreenTools.defaultFontPixelWidth*2.6
	height:ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth*17.4 :ScreenTools.defaultFontPixelWidth*14.2
	anchors.bottom: photoVideoControl.bottom
	anchors.left:photoVideoControl.left
	anchors.leftMargin: -ScreenTools.defaultFontPixelWidth*4.2 // new add 2
	color: ScreenTools.isMobile ? Qt.rgba(1,1,1,0.4) : Qt.rgba(0,0,0,0.35)
	radius: ScreenTools.defaultFontPixelWidth / 2
	visible: photoVideoControl.visible
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

	Rectangle{
		id:circleRect
		width:zoomRect.width
		height: width
		radius:width/2
		color: "#fff"
		y: (zoomRect.height-circleRect.height)/2

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
		onPressed: {
			if(mouse.y < zoomRect.height/2){
				if(lastState !== 1){
				   lastState=1
				   QGCCwGimbalController.videoZoom(1);
				}
			}else if( mouse.y > zoomRect.height/2){
				if(lastState !== -1){
				   lastState=-1
				   QGCCwGimbalController.videoZoom(-1);
				}
			}

			if(mouse.y<circleRect.height/2){
				circleRect.y = 0
			}else if(mouse.y>zoomRect.height-circleRect.height/2){
				circleRect.y = zoomRect.height-circleRect.height
			}else{
				circleRect.y = mouse.y - circleRect.height/2
			}

		}

		onPositionChanged:{
			if( mouse.y < zoomRect.height/2){
				if(lastState !== 1){
					lastState=1
					QGCCwGimbalController.videoZoom(1);
				}

			} else if( mouse.y > zoomRect.height/2){
				if(lastState !== -1){
					lastState=-1
					QGCCwGimbalController.videoZoom(-1);
				}
			}

			if(mouse.y<circleRect.height/2){
				circleRect.y = 0
			}else if(mouse.y>zoomRect.height-circleRect.height/2){
				circleRect.y = zoomRect.height-circleRect.height
			}else{
				circleRect.y = mouse.y - circleRect.height/2
			}
		}
		onReleased: {
			circleRect.color = "#FFF"
			circleRect.y = (zoomRect.height-circleRect.height)/2
			lastState=0
			QGCCwGimbalController.videoZoom(0);
		}
	}
}