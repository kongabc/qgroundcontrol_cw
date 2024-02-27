/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick              2.3
import QtLocation           5.3
import QtPositioning        5.3
import QtGraphicalEffects   1.0

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0

//new add 3
import QGCCwQml.QGCCwGimbalController 1.0
/// Marker for displaying a vehicle location on the map
MapQuickItem {
    property var    vehicle                                                         /// Vehicle object, undefined for ADSB vehicle
    property var    map
    property double altitude:       Number.NaN                                      ///< NAN to not show
    property string callsign:       ""                                              ///< Vehicle callsign
    property double heading:        vehicle ? vehicle.heading.value : Number.NaN    ///< Vehicle heading, NAN for none
    property real   size:           _adsbVehicle ? _adsbSize : _uavSize             /// Size for icon
    property bool   alert:          false                                           /// Collision alert

    anchorPoint.x:  vehicleItem.width  / 2
    anchorPoint.y:  vehicleItem.height / 2
    visible:        coordinate.isValid

    property var    _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property bool   _adsbVehicle:   vehicle ? false : true
    property real   _uavSize:       ScreenTools.defaultFontPixelHeight * 5
    property real   _adsbSize:      ScreenTools.defaultFontPixelHeight * 2.5
    property var    _map:           map
    property bool   _multiVehicle:  QGroundControl.multiVehicleManager.vehicles.count > 1

    sourceItem: Item {
        id:         vehicleItem
        width:      vehicleIcon.width
        height:     vehicleIcon.height
        opacity:    _adsbVehicle || vehicle === _activeVehicle ? 1.0 : 0.5

        Rectangle {
            id:                 vehicleShadow
            anchors.fill:       vehicleIcon
            color:              Qt.rgba(1,1,1,1)
            radius:             width * 0.5
            visible:            false
        }
        DropShadow {
            anchors.fill:       vehicleShadow
            visible:            vehicleIcon.visible && _adsbVehicle
            horizontalOffset:   4
            verticalOffset:     4
            radius:             32.0
            samples:            65
            color:              Qt.rgba(0.94,0.91,0,0.5)
            source:             vehicleShadow
        }
        Image {
            id:                 vehicleIcon
            source:             _adsbVehicle ? (alert ? "/qmlimages/AlertAircraft.svg" : "/qmlimages/AwarenessAircraft.svg") : vehicle.vehicleImageOpaque
            mipmap:             true
            width:              size
            sourceSize.width:   size
            fillMode:           Image.PreserveAspectFit
            transform: Rotation {
                origin.x:       vehicleIcon.width  / 2
                origin.y:       vehicleIcon.height / 2
                angle:          isNaN(heading) ? 0 : heading
            }
            z: QGroundControl.zOrderVehicles
        }
        //new add 3
//        Image {
//            id:                 cameraIcon
//            source:             "/qmlimages/CameraRan.svg"
//            opacity: 0.6
//            mipmap:             true
//            sourceSize.width:   pipMode ? ScreenTools.defaultFontPixelHeight*2 : ScreenTools.defaultFontPixelHeight * 4.6
//            fillMode:           Image.PreserveAspectFit
//            anchors.top: vehicleIcon.top
//            anchors.topMargin:pipMode ? -ScreenTools.defaultFontPixelHeight*1.5 : -(ScreenTools.defaultFontPixelHeight*3)
//            anchors.left: vehicleIcon.left
//            anchors.leftMargin: pipMode ? -ScreenTools.defaultFontPixelHeight*0.5 :-(ScreenTools.defaultFontPixelHeight*0.84)
//            transform: Rotation {
//                origin.x:      cameraIcon.width/2
//                origin.y:      cameraIcon.height
//                angle:        isNaN(QGCCwGimbalController.yaw) ? 0 : QGCCwGimbalController.yaw
//            }
//        }


        QGCMapLabel {
            id:                         vehicleLabel
            anchors.top:                parent.bottom
            anchors.horizontalCenter:   parent.horizontalCenter
            map:                        _map
            text:                       vehicleLabelText
            font.pointSize:             _adsbVehicle ? ScreenTools.defaultFontPointSize : ScreenTools.smallFontPointSize
            visible:                    _adsbVehicle ? !isNaN(altitude) : _multiVehicle
            property string vehicleLabelText: visible ?
                                                  (_adsbVehicle ?
                                                       QGroundControl.unitsConversion.metersToAppSettingsHorizontalDistanceUnits(altitude).toFixed(0) + " " + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString + "\n" + callsign :
                                                       (_multiVehicle ? qsTr("Vehicle %1").arg(vehicle.id) : "")) :
                                                  ""

        }
    }
}
