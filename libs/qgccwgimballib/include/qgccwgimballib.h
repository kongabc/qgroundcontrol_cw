#ifndef QGCCWGIMBALLIB_H
#define QGCCWGIMBALLIB_H

#include <QObject>
#include <QUdpSocket>
#include <QTcpSocket>
#include <stdint.h>
#include <QTimer>
#include <QElapsedTimer>
#include <QList>


class QGCCwGimbalLibPrivate;

class QGCCwGimbalLib : public QObject
{
    Q_OBJECT

public:
   QGCCwGimbalLib(QObject* parent);
   ~QGCCwGimbalLib();

   Q_PROPERTY(bool remoteValid READ remoteValidValue NOTIFY remoteValidChanged)

   Q_PROPERTY(QString mode READ modeValueStr NOTIFY modeChanged)
   Q_PROPERTY(quint8  modeRaw READ modeRawValue NOTIFY modeChanged)

   Q_PROPERTY(quint8  calibrateStatusCode READ calibrateStatusCodeValue NOTIFY calibrateStatusCodeChanged)

   Q_PROPERTY(bool  lampAvailable READ lampAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  trackAvailable READ trackAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  paletteAvailable READ paletteAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  rangeAvailable READ rangeAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  pipSwitchAvailable READ pipSwitchAvailable NOTIFY functionChanged)

   Q_PROPERTY(quint32  btnState READ btnStateValue NOTIFY btnStateChanged) //valueChanged)
   Q_PROPERTY(quint8  flags READ flagsValue NOTIFY valueChanged)
   Q_PROPERTY(QString  pitch READ pitchValueStr NOTIFY valueChanged)
   Q_PROPERTY(QString  yaw READ yawValueStr NOTIFY valueChanged)

   Q_PROPERTY(QString  lazerDis READ lazerDisValueStr NOTIFY valueChanged)

   Q_PROPERTY(QString  longitude READ longitudeValueStr NOTIFY valueChanged)
   Q_PROPERTY(QString  latitude READ latitudeValueStr NOTIFY valueChanged)
   Q_PROPERTY(QString  altitude READ altitudeValueStr NOTIFY valueChanged)

   // Thermal Camera
   Q_PROPERTY(quint8  ircamFlags READ ircamFlagsValue NOTIFY valueChanged)

   Q_PROPERTY(bool  irCamAvailable READ irCamAvailableValue NOTIFY functionChanged)

   // Param
   Q_PROPERTY(bool trackBtnState READ trackBtnStateValue WRITE setTrackBtnStateValue NOTIFY trackBtnStateChanged)
   Q_PROPERTY(bool showCenter READ showCenterValue WRITE setShowCenterValue NOTIFY paramShowCenterChanged)
   Q_PROPERTY(QString tcpAddr READ tcpAddrValue WRITE setTcpAddrValue NOTIFY paramChanged)
   Q_PROPERTY(bool isTcp READ isTcpValue WRITE setIsTcpValue NOTIFY paramChanged)

//   Q_PROPERTY(bool  isAreaTemp READ isAreaTempValue WRITE setIsAreaTempValue NOTIFY isAreaTempValueChanged)

   Q_PROPERTY(bool  isPointTemp READ isPointTempValue WRITE setIsPointTempValue NOTIFY isPointTempValueChanged)

   Q_PROPERTY(qint16  tempWarnH READ tempWarnHValue WRITE setTempWarnHValue NOTIFY tempValueChanged)
   Q_PROPERTY(qint16  tempWarnL READ tempWarnLValue WRITE setTempWarnLValue NOTIFY tempValueChanged)

   Q_PROPERTY(qint16  isothermH READ isothermHValue WRITE setIsothermHValue NOTIFY tempValueChanged)
   Q_PROPERTY(qint16  isothermL READ isothermLValue WRITE setIsothermLValue NOTIFY tempValueChanged)

   bool remoteValidValue() const;

   QString modeValueStr() const;
   quint8 modeRawValue() const;
   quint8 calibrateStatusCodeValue() const;

   bool lampAvailable() const;
   bool trackAvailable() const;
   bool paletteAvailable() const;
   bool rangeAvailable() const;
   bool pipSwitchAvailable() const;

   quint32 btnStateValue() const;

   quint8 flagsValue() const;
   QString pitchValueStr() const;
   QString yawValueStr() const;
   QString lazerDisValueStr() const;
   QString longitudeValueStr() const;
   QString latitudeValueStr() const;
   QString altitudeValueStr() const;

   quint8 ircamFlagsValue() const;

   bool irCamAvailableValue() const;

   // param
   bool trackBtnStateValue() const;
   bool showCenterValue() const;
   QString tcpAddrValue() const;
   bool isTcpValue() const;
//   bool isAreaTempValue() const;
   bool isPointTempValue() const;
   qint16 tempWarnHValue() const;
   qint16 tempWarnLValue() const;
   qint16 isothermHValue() const;
   qint16 isothermLValue() const;

   void setTrackBtnStateValue(bool trackBtnState);
   void setShowCenterValue(bool showCenter);
   void setTcpAddrValue(QString tcpAddr);
   void setIsTcpValue(bool isTcp);
//   void setIsAreaTempValue(bool isAreaTemp);
   void setIsPointTempValue(bool isPointTemp);
   void setTempWarnHValue(qint16 tempWarnH);
   void setTempWarnLValue(qint16 tempWarnL);
   void setIsothermHValue(qint16 isothermH);
   void setIsothermLValue(qint16 isothermL);

   Q_INVOKABLE void modeSwitch(quint8 modeSelect); //0x01-云台空间定向模式，0x02-俯拍模式，0x03-追踪模式(废弃，使 用框选追踪功能)，0x04-凝视模式，0x00-指向跟随模式(俯仰稳定)，其他值 默认指向跟随模式。
   Q_INVOKABLE void ircutSwitch(void);
   Q_INVOKABLE void lampSwitch(void);
   Q_INVOKABLE void trackObject(void);
   Q_INVOKABLE void paletteSwitch(void);
   Q_INVOKABLE void picInPicSwitch(void);
   Q_INVOKABLE void rangeSwitch(void);

   Q_INVOKABLE void videoTrack(quint8 x1,quint8 y1,quint8 x2,quint8 y2,quint8 videoTrackCmd);
   Q_INVOKABLE void videoPointTranslation(quint16 x,quint16 y);
   Q_INVOKABLE void joyControl(quint8 signal_valid, qint16 phi_signal, qint16 the_signal,qint16 psi_signal);

   Q_INVOKABLE void takePhoto(void);
   Q_INVOKABLE void takeRecording(void);
   Q_INVOKABLE void videoZoom(int zoomNum);
   Q_INVOKABLE void toCenter(void); //回中
   Q_INVOKABLE void  calibrateFun(void); //校准

   Q_INVOKABLE void areaTempShow(quint8 x1,quint8 y1,quint8 x2,quint8 y2,quint8 cmd);
   Q_INVOKABLE void spotTempSwitch(quint16 x,quint16 y,quint8 cmd);
   Q_INVOKABLE void tempWarnSwitch(qint16 tempWarnH,qint16 tempWarnL,bool isChangeState);
   Q_INVOKABLE void isoThermSwitch(qint16 isothermH,qint16 isothermL,bool isChangeState);

signals:
   void remoteValidChanged();
   void modeChanged(void);
   void calibrateStatusCodeChanged(void);
   void functionChanged();
   void btnStateChanged(void);
   void valueChanged(void);

   void trackBtnStateChanged(bool trackBtnState);
   void paramShowCenterChanged(bool showCenter);
   void paramChanged();
   void tempValueChanged();
   void isPointTempValueChanged();
//   void isAreaTempValueChanged();

public slots:
   void _sysTimerUpdate(void);
   void _calibrateTimerUpdate(void);
   void _readUdpDatagrams(void);

   void _readTcpDatagrams(void);
   void _tcpConnected(void);
   void _tcpDisconnected(void);
   void _tcpErrorOccurred(QAbstractSocket::SocketError);

private:
   typedef struct
   {
       uint8_t cmd;
       uint8_t reverse[7];
   } GIMBAL_CMDCTRL;

   void _processStream(void);
   void _processGimbalPackage(QByteArray ba);

   void _processGimbalType(void);

   void _sendCmdGimbalPackage(GIMBAL_CMDCTRL *cmdCtrl);

   void _tcpSendReqMsgGimbalPackage(void);

   QGCCwGimbalLibPrivate* dataPtr;

};

#endif // QGCCWGIMBALLIB_H
