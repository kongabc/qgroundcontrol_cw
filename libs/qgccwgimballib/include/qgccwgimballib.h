#ifndef QGCCWGIMBALLIB_H
#define QGCCWGIMBALLIB_H

#include <QObject>
#include <QUdpSocket>
#include <stdint.h>
#include <QTimer>
#include <QList>

class QGCCwGimbalLibPrivate;

class QGCCwGimbalLib : public QObject
{
    Q_OBJECT

public:
   QGCCwGimbalLib(QObject* parent);
   ~QGCCwGimbalLib();

   Q_PROPERTY(bool  remoteValid READ remoteValidValue NOTIFY remoteValidChanged)

   Q_PROPERTY(QString  mode READ modeValueStr NOTIFY modeChanged)
   Q_PROPERTY(quint8  modeRaw READ modeRawValue NOTIFY modeChanged)

   Q_PROPERTY(bool  lampAvailable READ lampAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  trackAvailable READ trackAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  paletteAvailable READ paletteAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  rangeAvailable READ rangeAvailable NOTIFY functionChanged)
   Q_PROPERTY(bool  pipinPipSwitchAvailable READ pipinPipSwitchAvailable NOTIFY functionChanged)

   Q_PROPERTY(quint32  btnState READ btnStateValue NOTIFY btnStateChanged)
   Q_PROPERTY(quint8  flags READ flagsValue NOTIFY valueChanged)
   Q_PROPERTY(QString  pitch READ pitchValueStr NOTIFY valueChanged)
   Q_PROPERTY(QString  yaw READ yawValueStr NOTIFY valueChanged)

   Q_PROPERTY(QString  lazerDis READ lazerDisValueStr NOTIFY valueChanged)

   Q_PROPERTY(QString  longitude READ longitudeValueStr NOTIFY valueChanged)
   Q_PROPERTY(QString  latitude READ latitudeValueStr NOTIFY valueChanged)
   Q_PROPERTY(QString  altitude READ altitudeValueStr NOTIFY valueChanged)
   Q_PROPERTY(bool  isTrack READ isTrackValue NOTIFY isTrackChanged)

   bool isTrackValue() const;

   bool remoteValidValue() const;

   QString modeValueStr() const;
   quint8 modeRawValue() const;
   bool lampAvailable() const;
   bool trackAvailable() const;
   bool paletteAvailable() const;
   bool rangeAvailable() const;
   bool pipinPipSwitchAvailable() const;

   quint32 btnStateValue() const;

   quint8 flagsValue() const;


   QString pitchValueStr() const;
   QString yawValueStr() const;

   QString lazerDisValueStr() const;

   QString longitudeValueStr() const;
   QString latitudeValueStr() const;
   QString altitudeValueStr() const;

   Q_INVOKABLE void takePhoto(void);
   Q_INVOKABLE void takeRecording(void);
   Q_INVOKABLE void videoZoom(int zoomNum);

   Q_INVOKABLE void modeSwitch(quint8 modeSelect); //0x01-云台空间定向模式，0x02-俯拍模式，0x03-追踪模式(废弃，使 用框选追踪功能)，0x04-凝视模式，0x00-指向跟随模式(俯仰稳定)，其他值 默认指向跟随模式。
   Q_INVOKABLE void ircutSwitch(void);
   Q_INVOKABLE void lampSwitch(void);
   Q_INVOKABLE void trackObject(void);
   Q_INVOKABLE void paletteSwitch(void);
   Q_INVOKABLE void picInPicSwitch(void);
   Q_INVOKABLE void rangeSwitch(void);
   Q_INVOKABLE void videoTrack(quint8 x1,quint8 y1,quint8 x2,quint8 y2,quint8 videoTrackCmd);
   Q_INVOKABLE void videoPointTranslation(quint16 x,quint16 y);

   Q_INVOKABLE void trackSwitch(bool isTrack);

   Q_INVOKABLE void joyControl(quint8 signal_valid, qint16 phi_signal, qint16 the_signal,qint16 psi_signal);

signals:
   void remoteValidChanged(void);
   void modeChanged(void);
   void btnStateChanged(void);
   void valueChanged(void);
   void functionChanged();

   void isTrackChanged(void);

public slots:
   void _readUdpDatagrams(void);
   void _sysTimerUpdate(void);

private:
   typedef struct
   {
       uint8_t cmd;
       uint8_t reverse[7];
   } GIMBAL_CMDCTRL;

   void _processUdpStream(void);
   void _processGimbalPackage(QByteArray ba);

   void _processGimbalType(void);

   void _sendCmdGimbalPackage(GIMBAL_CMDCTRL *cmdCtrl);

   QGCCwGimbalLibPrivate* dataPtr;


};

#endif // QGCCWGIMBALLIB_H
