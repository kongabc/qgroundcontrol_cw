/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include <QString>
#include <QTimer>
#include <QThread>
#include <QList>
#include <QMap>
#include <QMutex>
#include <QMutexLocker>
#include <QHostAddress>
#include <LinkInterface.h>
#include "QGCConfig.h"
#include "bb_api.h"

// Even though QAbstractSocket::SocketError is used in a signal by Qt, Qt doesn't declare it as a meta type.
// This in turn causes debug output to be kicked out about not being able to queue the signal. We declare it
// as a meta type to silence that.
#include <QMetaType>
#include <QTcpSocket>

#include "QGCConfig.h"
#include "LinkConfiguration.h"
#include "LinkInterface.h"

//#define TCPLINK_READWRITE_DEBUG   // Use to debug data reads/writes

class LinkManager;

class P401DConfiguration : public LinkConfiguration
{
    Q_OBJECT

public:

    // Q_PROPERTY(quint16 port READ port WRITE setPort NOTIFY portChanged)
    // Q_PROPERTY(QString host READ host WRITE setHost NOTIFY hostChanged)

    P401DConfiguration(const QString& name);
    P401DConfiguration(P401DConfiguration* source);

    quint16             port        (void) const                    { return _port; }
    const QHostAddress& address     (void)                          { return _address; }
    const QString       host        (void)                          { return _address.toString(); }
    //LinkConfiguration overrides
    LinkType    type                (void) override                                         { return LinkConfiguration::TypeP401D; }
    void        loadSettings        (QSettings& settings, const QString& root) override;
    void        saveSettings        (QSettings& settings, const QString& root) override;
    QString     settingsURL         (void) override                                         { return "P401DSettings.qml"; }
    QString     settingsTitle       (void) override                                         { return "P401D Link Settings"; }

signals:
    void portChanged(void);
    void hostChanged(void);

private:
    QHostAddress    _address;
    quint16         _port;
};

class P401DLink : public LinkInterface
{
    Q_OBJECT

public:
    P401DLink(SharedLinkConfigurationPtr& config);
    virtual ~P401DLink();

    QTcpSocket* getSocket           (void) { return _socket; }
    void        signalBytesWritten  (void);

//对P401D进行连接
    typedef struct{
        bb_host_t* phost;
        bb_dev_handle_t *bb_handle;
        bb_slot_e slot;
        int port;
        int bb_skt_fd;
    } AR8030Comm;

    int AR8030Comm_init(AR8030Comm** comm,bb_slot_e slot,int port);
    int AR8030Comm_release(AR8030Comm* comm);
    int AR8030Comm_socket_open(AR8030Comm* comm);
    int AR8030Comm_socket_close(AR8030Comm* comm);
    // void _writeBytes(const QByteArray data) override;

    /**
     * 读取数据
     * @param comm
     * @param buffer
     * @param buffer_len
     * @return 有效数据长度
     */
    int AR8030Comm_socket_read(AR8030Comm* comm,uint8_t *buffer,uint32_t buffer_len,int timeout);

    /**
     * 发送数据
     * @param comm
     * @param buffer
     * @param buffer_len
     * @return 成功/失败
     */
    int AR8030Comm_socket_write(AR8030Comm* comm,uint8_t *buffer,uint32_t buffer_len,int timeout);

//获取P401D信号强度
    typedef struct{
    bb_host_t* phost;
    bb_dev_handle_t *bb_handle;
    int slot;
    int is_ap;
    pthread_mutex_t pair_lock;
    pthread_t pair_thread;
    int pair_status; // 1 配对中，0:空闲

    pthread_mutex_t ota_lock;
    pthread_t ota_thread;
    int ota_status;//0：空闲。1: 遥控器端升级中。2：天空端升级中

    bb_dev_handle_t *dbg_bb_handle; //debug日志
    } AR8030Helper;  //P401D信号强度结构体

    typedef enum
    {
        ERE_NO_INIT=-1, //表示未初始化或为连接到daemon
        ERE_PAIR=-3, //表示正在配对中，无法使用该方法
        ERE_NO_PAIR=-4, //停止配对方法中使用（表示未进行配对）
        ERE_OTA=-5,//表示正在OTA升级中，无法使用该方法
    } ERR_CODE;

    int AR8030Helper_init(AR8030Helper** pAR8030Helper,int isAp,int slot);

    int AR8030Helper_connectToDaemon();

    int AR8030Helper_get1V1Info();

    int AR8030Helper_release(AR8030Helper* pAR8030Helper);

    int ConstrainInt(int value, int min, int max);

    int GetFilterValue(int value);

    int P401DSignalRSSI();

    // LinkInterface overrides
    bool isConnected(void) const override;
    void disconnect (void) override;

signals:

public slots:
    void _readBytes(void);
private slots:
    void _writeBytes(const QByteArray data) override;
private:
    // LinkInterface overrides
    bool _connect(void) override;

    bool _hardwareConnect   (void);
#ifdef TCPLINK_READWRITE_DEBUG
    void _writeDebugBytes   (const QByteArray data);
#endif

    P401DConfiguration* _P401DConfig;
    QTcpSocket*       _socket;
    bool              _P401DIsConnected;

    quint64 _bitsSentTotal;
    quint64 _bitsSentCurrent;
    quint64 _bitsSentMax;
    quint64 _bitsReceivedTotal;
    quint64 _bitsReceivedCurrent;
    quint64 _bitsReceivedMax;
    quint64 _connectionStartTime;
    QMutex  _readProtectMutex;
    QMutex  _writeProtectMutex;
    QTimer  _readTimer;
    QTimer  _signalTimer;

    static const int _gcsReadMSecs = 20;  //读取Mavlink消息间隔
    static const int _gcsSignalMSecs = 800;  //读取信号强度返回消息间隔

    AR8030Comm* comm = NULL;
    AR8030Helper* pAR8030Helper = NULL;
    bb_get_1v1_info_out_t helper_out;
    int apSignal = 0;  // 初始化信号值

    const size_t buffer_size = 128;
    uint8_t *revbuf = (uint8_t *)malloc(buffer_size);
    uint8_t *wribuf = (uint8_t *)malloc(buffer_size);
    int rev_timeout = 10;
    int wri_timeout = 10;
};

