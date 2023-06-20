import QtQuick.Window 2.15
import QGCCwQml.QGCCwGimbalController 1.0

Item {

    MouseArea {
        cursorShape: "PointingHandCursor"
        acceptedButtons:Qt.LeftButton | Qt.RightButton

        onClicked: {
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

            }else if(mouse.button === Qt.RightButton){

                QGCCwGimbalController.videoTrack("","","","",0x00);

            }

        }

    }
}





