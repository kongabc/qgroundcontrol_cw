import QtQuick.Window 2.15
import QGCCwQml.QGCCwGimbalController 1.0

Item {
	
    property bool   isLeftBtn: false
    property bool   isPressed: false
    property int startX: 0
    property int startY: 0
    property int disX: 0
    property int disY: 0
	
   Timer{
        id:timerClick
        interval:300
        repeat: false
        onTriggered: {
            if(isPressed){
                videoStartMove.start();
            }
        }
    }
    Timer{
        id:videoStartMove
        interval:50
        repeat: true
        onTriggered:{
            QGCCwGimbalController.joyControl(1,0,-disY*1.6,disX*1.6)
        }
    }
    Timer{
        id:timerSecondClick
        interval:100
        repeat: false
    }
	
    MouseArea {
        cursorShape: "PointingHandCursor"
        acceptedButtons:Qt.LeftButton | Qt.RightButton
			
		onClicked: {
            if(timerSecondClick.running){
                return
            }
             const rootW = _root.width;
             const rootH = _root.height;

             const lis = videoStreaming.children;
             const videoW = lis[1].getWidth();
             const videoH = lis[1].getHeight();

             var dw = (rootW-videoW)/2
             if(mouse.button === Qt.LeftButton){
                 if(QGCCwGimbalController.isTrack && QGCCwGimbalController.trackAvailable){

                     if((mouseX > dw) && (mouseX < rootW-dw)) {
                         var x = (mouseX-dw)*100/videoW
                         var y = mouseY*100 /videoH
                         var x1 = x-5
                         var y1 = y-5
                         var x2 = x+5
                         var y2 = y+5
                         if(x1<0) { x1=0 }
                         if(y1<0) { y1=0 }
                         if(x2>100) { x2=100 }
                         if(y2>100) { y2=100 }
                         QGCCwGimbalController.videoTrack(x1,y1,x2,y2,0x02);
                     }

                 }else{
                     if((mouseX > dw) && (mouseX < rootW-dw)) {
                         var mx = (mouseX-dw)*10000/videoW
                         var my = mouseY*10000 /videoH
                         QGCCwGimbalController.videoPointTranslation(mx,my);
                     }
                 }

             }else if(mouse.button  === Qt.RightButton){
                 QGCCwGimbalController.videoTrack("","","","",0x00);
             }
        }
		onPressed: {
            startX=0
            startY=0
            disX= 0
            disY=0
            if(mouse.button === Qt.LeftButton){
                timerClick.start()
                isPressed = true
                isLeftBtn = true
                startX = mouseX
                startY = mouseY
            }
        }
		onPositionChanged:{
            if(isPressed){
                if(QGCCwGimbalController.modeRaw === 3){
                    return
                }
                if(isLeftBtn){
                    disX = mouse.x-startX
                    disY = mouse.y-startY
                }
            }
        }
		onReleased: {
            isLeftBtn = false;
            isPressed = false;
            startX=0
            startY=0
            disX=0
            disY=0
            if(videoStartMove.running){
                videoStartMove.stop()
                QGCCwGimbalController.joyControl(1,0,0,0)

                timerSecondClick.start()
            }
        }
    


    }
}





