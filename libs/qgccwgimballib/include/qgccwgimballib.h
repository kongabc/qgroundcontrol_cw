#ifndef QGCCWGIMBALLIB_H
#define QGCCWGIMBALLIB_H

#include <QObject>
#include <QUdpSocket>
#include <QTcpSocket>
//#include <QThread>
#include <QEventLoop>
#include <QNetworkAccessManager>
#include <QUrl>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QUrlQuery>
#include <QVariantList>
#include <QTimer>
#include <QElapsedTimer>
#include <QList>
#include <stdint.h>



class QGCCwGimbalLibPrivate;
class ConfigTemplate ;
class QGCCwGimbalLib : public QObject
{
    Q_OBJECT

public:
   QGCCwGimbalLib(QObject* parent);
   ~QGCCwGimbalLib();

//   static QGCCwGimbalLib* instance();

   Q_PROPERTY(bool remoteValid READ remoteValidValue NOTIFY remoteValidChanged)

   Q_PROPERTY(QString mode READ modeValueStr NOTIFY modeChanged)
   Q_PROPERTY(quint8  modeRaw READ modeRawValue NOTIFY modeChanged)

   Q_PROPERTY(QString devideType READ devideTypeValue NOTIFY receiveValueChanged)
   Q_PROPERTY(quint16 firmwareVer READ firmwareVerValue NOTIFY receiveValueChanged)
   Q_PROPERTY(quint16 hardwareVer READ hardwareVerValue NOTIFY receiveValueChanged)
   Q_PROPERTY(QVariantList sbusMap READ sbusMapValue WRITE setSbusMapAddr NOTIFY receiveValueChanged)
   Q_PROPERTY(quint32  sbusInverse READ sbusInverseValue WRITE setSbusInverseAddr NOTIFY receiveValueChanged)
   Q_PROPERTY(QString ipAddr READ ipAddrValue WRITE setIpAddr NOTIFY receiveValueChanged)
   Q_PROPERTY(quint8  masklen READ masklenValue WRITE setMasklenIpAddr NOTIFY receiveValueChanged)
   Q_PROPERTY(QString gatewayIpAddr READ gatewayIpAddrValue WRITE setGatewayIpAddr NOTIFY receiveValueChanged)
   Q_PROPERTY(QString subNetIpAddr READ subNetIpAddrValue WRITE setSubNetIpAddr NOTIFY receiveValueChanged)
   Q_PROPERTY(QString destIp1Addr READ destIp1AddrValue WRITE setDestIp1Addr NOTIFY receiveValueChanged)

   Q_PROPERTY(QString cameraIpAddr READ cameraIpAddrValue WRITE setCameraIpAddr NOTIFY receiveValueChanged)
   Q_PROPERTY(quint8  cameraStreamType READ cameraStreamTypeValue WRITE setCameraStreamType NOTIFY receiveValueChanged)
   Q_PROPERTY(QString cameraStream READ cameraStreamValue WRITE setCameraStream NOTIFY receiveStreamChanged)

   Q_PROPERTY(bool isRunTele2Timer READ isRunTele2Timer WRITE setIsRunTele2Timer NOTIFY isRunTele2TimerChanged)
   Q_PROPERTY(QVariantList sbusData READ sbusDataValue NOTIFY receiveValueChanged)

   //camera setting
   Q_PROPERTY(QString cameraRealIp READ cameraRealIpValue WRITE setCameraRealIp NOTIFY cameraValueChanged)
   Q_PROPERTY(QString cameraGatewayIp READ cameraGatewayIpValue WRITE setCameraGatewayIp NOTIFY cameraValueChanged)
   Q_PROPERTY(QString cameraNetMask READ cameraNetMaskValue WRITE setCameraNetMask NOTIFY cameraValueChanged)
   Q_PROPERTY(QString cameraBit READ cameraBitValue WRITE setCameraBit NOTIFY cameraValueChanged)
   Q_PROPERTY(int cameraMinBit READ cameraMinBitValue NOTIFY cameraValueChanged)
   Q_PROPERTY(int cameraMaxBit READ cameraMaxBitValue NOTIFY cameraValueChanged)
   Q_PROPERTY(QString cameraResolution READ cameraResolutionValue WRITE setCameraResolution NOTIFY cameraValueChanged)
   Q_PROPERTY(QString cameraFps READ cameraFpsValue WRITE setCameraFps NOTIFY cameraValueChanged)
   Q_PROPERTY(QString cameraCodeType READ cameraCodeTypeValue WRITE setCameraCodeType NOTIFY cameraValueChanged)
   Q_PROPERTY(int cameraVQuality READ cameraVQualityValue WRITE setCameraVQuality NOTIFY cameraValueChanged)

   Q_PROPERTY(int showCameraSet READ showCameraSetValue WRITE setShowCameraSet NOTIFY showValueChanged)
   Q_PROPERTY(QString inputIpPort READ inputIpPortValue WRITE setInputIpPort NOTIFY inputIpPortValueChanged)

   Q_PROPERTY(QVariantList cameraConfs READ cameraConfsValue NOTIFY cameraConfsChanged)

   Q_PROPERTY(int timeZoneVal READ timeZoneValue WRITE setTimeZone NOTIFY valueChanged)   // WRITE setTimeZone
   Q_PROPERTY(quint8 flags2 READ flags2Value NOTIFY valueChanged)
   Q_PROPERTY(quint8 flags3 READ flags3Value NOTIFY valueChanged)
   Q_PROPERTY(quint8 ispEffect READ ispEffectValue NOTIFY valueChanged)
   Q_PROPERTY(quint8 osdState READ osdStateValue NOTIFY valueChanged)
   Q_PROPERTY(quint8 osdDataMean READ osdDataMeanValue NOTIFY valueChanged)
   Q_PROPERTY(quint8 imageInvers READ imageInversValue NOTIFY valueChanged)
   Q_PROPERTY(quint8 tracSta READ tracStaValue NOTIFY valueChanged)
   Q_PROPERTY(quint8 trackZoomSta READ trackZoomStaValue NOTIFY valueChanged)
   Q_PROPERTY(quint8 recognizeSta READ recognizeStaValue NOTIFY valueChanged)


   Q_PROPERTY(quint8  calibrateStatusCode READ calibrateStatusCodeValue WRITE setCalStatusCodeValue NOTIFY calibrateStatusCodeChanged)

   Q_PROPERTY(bool  lampAvailable READ lampAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  trackAvailable READ trackAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  paletteAvailable READ paletteAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  iRCutAvailable READ iRCutAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  rangeAvailable READ rangeAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  pipSwitchAvailable READ pipSwitchAvailable NOTIFY functionChanged)

   Q_PROPERTY(bool  trackZoomAvailable READ trackZoomAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  autoTrackAvailable READ autoTrackAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  recognizeAvailable READ recognizeAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  osdDataAvailable READ osdDataAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  timeZoneAvailable READ timeZoneAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  imageInversAvailable READ imageInversAvailable NOTIFY functionChanged)


   Q_PROPERTY(quint32  btnState READ btnStateValue NOTIFY btnStateChanged) //valueChanged)
   Q_PROPERTY(quint8  flags READ flagsValue NOTIFY valueChanged)
   Q_PROPERTY(QString  roll READ rollValueStr NOTIFY valueChanged)
   Q_PROPERTY(QString  pitch READ pitchValueStr NOTIFY valueChanged)
   Q_PROPERTY(QString  yaw READ yawValueStr NOTIFY valueChanged)

   Q_PROPERTY(QString  lazerDis READ lazerDisValueStr NOTIFY valueChanged)

   Q_PROPERTY(QString  longitude READ longitudeValueStr NOTIFY valueChanged)
   Q_PROPERTY(QString  latitude READ latitudeValueStr NOTIFY valueChanged)
   Q_PROPERTY(QString  altitude READ altitudeValueStr NOTIFY valueChanged)

//   Q_PROPERTY(QVariantList coordinates READ coordinatesValue NOTIFY coordinatesChanged)

   Q_PROPERTY(quint16  zoomvalue READ zoomvalueValue NOTIFY valueChanged)
   Q_PROPERTY(quint16  zoomvalue2 READ zoomvalue2Value NOTIFY valueChanged)

   Q_PROPERTY(quint8  gpsState READ gpsStateValue NOTIFY valueChanged)
   Q_PROPERTY(QString  carrierRoll READ carrierRollValueStr NOTIFY valueChanged)
   Q_PROPERTY(QString  carrierPitch READ carrierPitchValueStr NOTIFY valueChanged)
   Q_PROPERTY(QString  carrierYaw READ carrierYawValueStr NOTIFY valueChanged)

   Q_PROPERTY(qint16  carrierAccN READ carrierAccNValueStr NOTIFY valueChanged)
   Q_PROPERTY(qint16  carrierAccE READ carrierAccEValueStr NOTIFY valueChanged)
   Q_PROPERTY(qint16  carrierAccU READ carrierAccUValueStr NOTIFY valueChanged)

   Q_PROPERTY(qint16  cpuTemp READ cpuTempValue NOTIFY valueChanged)
   Q_PROPERTY(float  sdRemainCapacity READ sdRemainCapacityValue NOTIFY valueChanged)
   Q_PROPERTY(quint32  recTime READ recTimeValue NOTIFY valueChanged)


   // Thermal Camera
   Q_PROPERTY(quint8  ircamFlags READ ircamFlagsValue NOTIFY valueChanged)

   Q_PROPERTY(bool  irCamAvailable READ irCamAvailableValue NOTIFY functionChanged)

   // Param
   Q_PROPERTY(bool trackBtnState READ trackBtnStateValue WRITE setTrackBtnStateValue NOTIFY trackBtnStateChanged)
   Q_PROPERTY(bool showCenter READ showCenterValue WRITE setShowCenterValue NOTIFY paramShowCenterChanged)
   Q_PROPERTY(QString tcpAddr READ tcpAddrValue WRITE setTcpAddrValue NOTIFY paramChanged)
   Q_PROPERTY(bool isTcp READ isTcpValue WRITE setIsTcpValue NOTIFY paramChanged)

   Q_PROPERTY(int iconStyle READ iconStyleValue WRITE setIconStyleValue NOTIFY paramIconStyleChanged)
   Q_PROPERTY(bool showMoveBtn READ showMoveBtnValue WRITE setShowMoveBtnValue NOTIFY paramShowMoveBtnChanged)
   Q_PROPERTY(bool showToCenter READ showToCenterValue WRITE setToCenterValue NOTIFY paramToCenterChanged)
   Q_PROPERTY(int showGrid READ showGridValue WRITE setShowGridValue NOTIFY paramShowGridChanged)

   Q_PROPERTY(int iconOffsetX READ iconOffsetX WRITE setIconOffsetX NOTIFY iconOffsetChanged)
   Q_PROPERTY(int iconOffsetY READ iconOffsetY WRITE setIconOffsetY NOTIFY iconOffsetChanged)


   Q_PROPERTY(bool  isPointTemp READ isPointTempValue WRITE setIsPointTempValue NOTIFY isPointTempValueChanged)

   Q_PROPERTY(qint16  tempWarnH READ tempWarnHValue WRITE setTempWarnHValue NOTIFY tempValueChanged)
   Q_PROPERTY(qint16  tempWarnL READ tempWarnLValue WRITE setTempWarnLValue NOTIFY tempValueChanged)

   Q_PROPERTY(qint16  isothermH READ isothermHValue WRITE setIsothermHValue NOTIFY tempValueChanged)
   Q_PROPERTY(qint16  isothermL READ isothermLValue WRITE setIsothermLValue NOTIFY tempValueChanged)

   Q_PROPERTY(bool saveState READ saveStateValue WRITE setSaveStateValue NOTIFY saveStateChanged)




   QString devideTypeValue() const;
   quint16 firmwareVerValue() const;
   quint16 hardwareVerValue() const;
   QVariantList sbusMapValue() const;
   QVariantList sbusDataValue() const;
   quint32 sbusInverseValue() const;
   QString ipAddrValue() const;
   quint8 masklenValue() const;
   QString gatewayIpAddrValue() const;
   QString subNetIpAddrValue() const;
   QString destIp1AddrValue() const;
   QString cameraIpAddrValue() const;
   quint8 cameraStreamTypeValue() const;
   QString cameraStreamValue() const;
   QString cameraRealIpValue() const;
   QString cameraGatewayIpValue() const;
   QString cameraNetMaskValue() const;
   QString cameraBitValue() const;
   int cameraMinBitValue() const;
   int cameraMaxBitValue() const;
   QString cameraResolutionValue() const;
   QString cameraFpsValue() const;
   QString cameraCodeTypeValue() const;
   int cameraVQualityValue() const;
   QString inputIpPortValue() const;
   int showCameraSetValue() const;

   QVariantList cameraConfsValue() const;

   int timeZoneValue() const;
   quint8 flags2Value() const;
   quint8 flags3Value() const;
   quint8 ispEffectValue() const;
   quint8 osdDataMeanValue() const;
   quint8 osdStateValue() const;
   quint8 imageInversValue() const;
   quint8 tracStaValue() const;
   quint8 trackZoomStaValue() const;
   quint8 recognizeStaValue() const;

   bool isRunTele2Timer() const;
   bool remoteValidValue() const;

   QString modeValueStr() const;
   quint8 modeRawValue() const;
   quint8 calibrateStatusCodeValue() const;

   bool lampAvailable() const;
   bool trackAvailable() const;
   bool paletteAvailable() const;
   bool iRCutAvailable() const;
   bool rangeAvailable() const;
   bool pipSwitchAvailable() const;
   bool trackZoomAvailable() const;
   bool autoTrackAvailable() const;
   bool recognizeAvailable() const;
   bool osdDataAvailable() const;
   bool timeZoneAvailable() const;
   bool imageInversAvailable() const;

   quint32 btnStateValue() const;

   quint8 flagsValue() const;
   QString rollValueStr() const;
   QString pitchValueStr() const;
   QString yawValueStr() const;
   QString lazerDisValueStr() const;
   QString longitudeValueStr() const;
   QString latitudeValueStr() const;
   QString altitudeValueStr() const;

//   QVariantList coordinatesValue() const;

   quint16 zoomvalueValue() const;
   quint16 zoomvalue2Value() const;


   quint8 gpsStateValue() const;
   QString carrierRollValueStr() const;
   QString carrierPitchValueStr() const;
   QString carrierYawValueStr() const;

   qint16 carrierAccNValueStr() const;
   qint16 carrierAccEValueStr() const;
   qint16 carrierAccUValueStr() const;

   qint16 cpuTempValue() const;
   float sdRemainCapacityValue() const;
   quint32 recTimeValue() const;
   quint8 ircamFlagsValue() const;

   bool irCamAvailableValue() const;

   bool saveStateValue() const;

   // param
   void setSbusMapAddr(QVariantList sbusMap);
   void setSbusInverseAddr(quint32 sbusInverse);
   void setIpAddr(QString ipAddr);
   void setMasklenIpAddr(quint8 masklen);
   void setGatewayIpAddr(QString gatewayIpAddr);
   void setSubNetIpAddr(QString subNetIpAddr);
   void setDestIp1Addr(QString destIp1Addr);
   void setCameraIpAddr(QString cameraIpAddr);
   void setCameraStreamType(quint8 cameraStreamType);
   void setCameraStream(QString stream);
   void setCameraRealIp(QString cameraRealIp);
   void setCameraGatewayIp(QString cameraGatewayIp);
   void setCameraNetMask(QString cameraNetMask);
   void setCameraBit(QString bit);
   void setCameraResolution(QString resolution);
   void setCameraFps(QString fps);
   void setCameraCodeType(QString type);
   void setCameraVQuality(int quality);
   void setInputIpPort(QString ipPort);
   void setShowCameraSet(int showNum);

   void setIsRunTele2Timer(bool isRun);

   void setTimeZone(int tz);
   void setCalStatusCodeValue(quint8 calibrateStatusCode);

   bool trackBtnStateValue() const;
   bool showCenterValue() const;
   QString tcpAddrValue() const;
   bool isTcpValue() const;
   int iconStyleValue() const;
   bool showMoveBtnValue() const;
   bool showToCenterValue() const;
   int showGridValue() const;
   int iconOffsetX() const;
   int iconOffsetY() const;

   bool isPointTempValue() const;
   qint16 tempWarnHValue() const;
   qint16 tempWarnLValue() const;
   qint16 isothermHValue() const;
   qint16 isothermLValue() const;

   void setTrackBtnStateValue(bool trackBtnState);
   void setShowCenterValue(bool showCenter);
   void setTcpAddrValue(QString tcpAddr);
   void setIsTcpValue(bool isTcp);
   void setIconStyleValue(int styValue);
   void setShowMoveBtnValue(bool isShow);
   void setToCenterValue(bool toCenter);
   void setShowGridValue(int showGrid);

   void setIconOffsetX(int x);
   void setIconOffsetY(int y);

   void loadIconOffsets();
   void saveIconOffsets();
   void saveCurrentOffset();
   void saveImmediately();


//   void setVideoModeValue(bool videoMode);
//   void setIsAreaTempValue(bool isAreaTemp);
   void setIsPointTempValue(bool isPointTemp);
   void setTempWarnHValue(qint16 tempWarnH);
   void setTempWarnLValue(qint16 tempWarnL);
   void setIsothermHValue(qint16 isothermH);
   void setIsothermLValue(qint16 isothermL);

   void setSaveStateValue(bool state);

//   Q_INVOKABLE bool videoModeChange(void);
   Q_INVOKABLE bool getSbusChecked(int index) const;
   Q_INVOKABLE void setSbusChecked(int index,bool state);
   Q_INVOKABLE void setSbusMapValue(int index,quint32 value);
   Q_INVOKABLE void sendSaveParameters();
   Q_INVOKABLE void resetParameters(int setIndex);
   Q_INVOKABLE void resetNoSaveData();

   Q_INVOKABLE void modeSwitch(quint8 modeSelect); //0x01-云台空间定向模式，0x02-俯拍模式，0x03-追踪模式(废弃，使 用框选追踪功能)，0x04-凝视模式，0x00-指向跟随模式(俯仰稳定)，其他值 默认指向跟随模式。
   Q_INVOKABLE void ircutSwitch(quint8 ircutCmd);
   Q_INVOKABLE void lampSwitch(quint8 lampCmd);
   Q_INVOKABLE void trackObject(void);
   Q_INVOKABLE void paletteSwitch(void);
   Q_INVOKABLE void picInPicSwitch(void);
   Q_INVOKABLE void rangeSwitch(void);
   Q_INVOKABLE void ispSwitch(quint8 ispCmd);
   Q_INVOKABLE QString formatFloat(const char* s,float val);
   Q_INVOKABLE QString formatFloat(QString format, float val);

   Q_INVOKABLE void videoTrack(quint8 x1,quint8 y1,quint8 x2,quint8 y2,quint8 videoTrackCmd);
   Q_INVOKABLE void videoPointTranslation(quint16 x,quint16 y);
   Q_INVOKABLE void joyControl(quint8 signal_valid, qint16 phi_signal, qint16 the_signal,qint16 psi_signal);

   Q_INVOKABLE void takePhoto(void);
   Q_INVOKABLE void takeRecording(void);
   Q_INVOKABLE void videoZoom(int zoomNum);
   Q_INVOKABLE void toCenter(void);
   Q_INVOKABLE void calibrateFun(void);

   Q_INVOKABLE void osdSwitch(int cmdInd);
   Q_INVOKABLE void userConfigFun(quint8 v,quint8 p1,quint8 p2,quint8 p3,quint8 p4,quint8 p5,qint8 p6);

   Q_INVOKABLE void areaTempShow(quint8 x1,quint8 y1,quint8 x2,quint8 y2,quint8 cmd);
   Q_INVOKABLE void spotTempSwitch(quint16 x,quint16 y,quint8 cmd);
   Q_INVOKABLE void tempWarnSwitch(qint16 tempWarnH,qint16 tempWarnL,bool isChangeState);
   Q_INVOKABLE void isoThermSwitch(qint16 isothermH,qint16 isothermL,bool isChangeState);

   Q_INVOKABLE void startRequest(const QString &ip, const QString &port = "8554");
   Q_INVOKABLE void requestJson();
   Q_INVOKABLE void requestFallback();
   Q_INVOKABLE void saveChangeParm(const QVariantMap &configData);
   Q_INVOKABLE void cameraIpLogin(const QString &ip);
   Q_INVOKABLE void updateCameraConfs(int configIndex, const QString &paramName, const QVariant &value);
   Q_INVOKABLE void setCameraConfs();
   Q_INVOKABLE void saveCameraConfs();
   Q_INVOKABLE void saveResState();
   Q_INVOKABLE void reqCameraConf();

   Q_INVOKABLE void reloadOffset();

//   Q_INVOKABLE void addCoordinate(double latitude, double longitude, double altitude = 0.0, const QString &info = "");



signals:
   void receiveValueChanged();
   void receiveStreamChanged();
   void remoteValidChanged();
   void modeChanged(void);
   void isRunTele2TimerChanged(bool isRun);
   void calibrateStatusCodeChanged(void);
   void functionChanged();
   void btnStateChanged(void);
   void valueChanged(void);
   void cameraValueChanged();
   void inputIpPortValueChanged();
   void showValueChanged();

//   void coordinatesChanged();
//   void newCoordinateReceived(double latitude, double longitude, double altitude, const QString &source = "gimbal");

   void cameraConfsChanged();

   void trackBtnStateChanged(bool trackBtnState);
   void paramShowCenterChanged(bool showCenter);
   void paramIconStyleChanged();
   void paramShowMoveBtnChanged();
   void paramToCenterChanged(bool toCenter);
   void paramShowGridChanged();
   void iconOffsetChanged();


   void paramChanged();
   void tempValueChanged();
   void isPointTempValueChanged();
//   void isAreaTempValueChanged();
   void saveStateChanged();

   void jsonDataReady(const QVariantMap &data);
   void fallbackDataReady(const QString &data);
   void requestFailed();

public slots:
   void _sysTimerUpdate(void);
   void _sysTele3TimerUpdate(void);
   void _calibrateTimerUpdate(void);
   void _readUdpDatagrams(void);
   void _tele2TimerUpdate(void);
   void _tcpReconnect(void);

   void _readTcpDatagrams(void);
   void _tcpConnected(void);
   void _tcpDisconnected(void);
   void _tcpErrorOccurred(QAbstractSocket::SocketError error);
   void _tcpStateChanged(QAbstractSocket::SocketState state);

   void _handleFirstRes();
   void _handleSecondRes();
   void _handleValResponse();

private:
   typedef struct
   {
       uint8_t cmd;
       uint8_t reverse[7];
   } GIMBAL_CMDCTRL;
   typedef struct
   {
       uint16_t index;
       uint8_t reverse[7];
   } GIMBAL_REQCTRL;

   void _processStream(void);
   void _processGimbalPackage(QByteArray ba);
   void _processGimbalType(void);

   void _sendCmdGimbalPackage(GIMBAL_CMDCTRL *cmdCtrl);
   void _sendReqGimbalPackage(GIMBAL_REQCTRL *indexCtrl);
   void _sendParam1Package();
   void _sendParam2Package();
//   void _sendTele2Package(GIMBAL_REQCTRL *indexCtrl);

   void _tcpSendReqMsgGimbalPackage(void);

   QString ipToString(uint8_t *ipArr) const;
   //将QString转为uint8_t[4]
   void _parseIpAddr(QString inputIpAddr,uint8_t ip[4]);
   // 将 uint8_t[4] 转换为32位整数
   uint32_t _subnetMaskToUint32(const uint8_t mask[4]);
   // 验证掩码是否合法
   bool _isValidSubnetMask(uint32_t mask);
   // 计算掩码位数
   int _calculatePrefixLength(uint32_t mask);

   void processIpAddress(const QString &ip,const QString &key0,const QString &key1,const QString &key2,const QString &key3,QUrlQuery &postData);

   void requestCurrentConfs();
   void parseConfsTemplates(const QByteArray &data);
   void parseCurrentConfs(const QByteArray &data);

   QNetworkAccessManager *netManager;
   QNetworkReply *firstReply = nullptr;
   QNetworkReply *secondReply = nullptr;
   QNetworkReply *thirReply = nullptr;

   QGCCwGimbalLibPrivate* dataPtr;

//   static QGCCwGimbalLib* s_instance;

};


#endif // QGCCWGIMBALLIB_H
