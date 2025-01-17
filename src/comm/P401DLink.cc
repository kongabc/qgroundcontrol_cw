/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include <QTimer>
#include <QList>
#include <QDebug>
#include <QMutexLocker>
#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include "P401DLink.h"
#include "LinkManager.h"
#include "QGC.h"
#include <QHostInfo>
#include <QSignalSpy>

P401DLink::P401DLink(SharedLinkConfigurationPtr& config)
    : LinkInterface(config)
    , _P401DConfig(qobject_cast<P401DConfiguration*>(config.get()))
    , _socket(nullptr)
    , _P401DIsConnected(false)
{
    int ret_comm , ret_helper;
    bb_slot_e slotcomm = BB_SLOT_0;
    int slot_helper = 0;
    int port = 1;
    Q_ASSERT(_P401DConfig);
    
    //初始化AR8030Comm，准备连接P401D链路
    ret_comm = AR8030Comm_init(&comm,slotcomm,port);
    if (ret_comm)
    {
        qDebug() << "Can not init AR8030Comm";
    }

    //初始化AR8030Helper，准备获取P401D信号强度
    ret_helper = AR8030Helper_init(&pAR8030Helper, slot_helper, port);
    if (ret_helper)
    {
        qDebug() << "Can not init AR8030Comm";
    }

    _readTimer.start(_gcsReadMSecs);
    connect(&_readTimer, &QTimer::timeout, this, &P401DLink::_readBytes);
    
    _signalTimer.start(_gcsSignalMSecs);
    connect(&_signalTimer, &QTimer::timeout, this, &P401DLink::AR8030Helper_get1V1Info);
}

P401DLink::~P401DLink()
{
    disconnect();
    AR8030Comm_release((AR8030Comm*) comm);
    AR8030Helper_release((AR8030Helper*) pAR8030Helper);
}

int P401DLink::AR8030Comm_init(AR8030Comm** comm,bb_slot_e slot,int port){
    (*comm) = (AR8030Comm*)malloc(sizeof(AR8030Comm));
    (*comm)->bb_handle = NULL;
    (*comm)->slot = slot;
    (*comm)->port = port;
    (*comm)->bb_skt_fd = 0;
    return 0;
}
int P401DLink::AR8030Comm_release(AR8030Comm* comm){
    if (comm == NULL){
        return -1;
    }
    free(comm);
    comm = NULL;
    return 0;
}

void P401DLink::_writeBytes(const QByteArray data)
{
    if (comm == NULL) {
        qWarning() << "Error _writeBytes P401DLink";
        return;
    }

    emit bytesSent(this, data);

    QMutexLocker locker(&_writeProtectMutex);
    uint32_t wri_size = data.size();
    if (wri_size == 0) {
        return;
    }

    if (wribuf == NULL) {
        qWarning() << "Memory allocation failed in _writeBytes";
        return;
    }

    memcpy(wribuf, data.data(), wri_size);
    int result = bb_socket_write(comm->bb_skt_fd, wribuf, wri_size, wri_timeout);

    if (result < 0) {
        qWarning() << "Failed to write bytes in _writeBytes";
        return;
    }
}

void P401DLink::_readBytes()
{
    QMutexLocker locker(&_readProtectMutex);
    int ret = bb_socket_read(comm->bb_skt_fd, revbuf, buffer_size, rev_timeout);
    if (ret > 0) {
        QByteArray databuffer = QByteArray::fromRawData((const char*)revbuf, ret);
        if (!databuffer.isEmpty()) {
            emit bytesReceived(this, databuffer);
        }
    }
}

void P401DLink::disconnect(void)    //AR8030Comm_socket_close
{
    //释放P401D链路的指针
    if (comm == NULL){
        qWarning() << "Error disconnect P401DLink";
        return ;
    }
    if (comm->bb_skt_fd >= 0){
        bb_socket_close(comm->bb_skt_fd);
        comm->bb_skt_fd = 0;
    }
    if (comm->bb_handle){
        bb_dev_close(comm->bb_handle);
        comm->bb_handle = NULL;
    }
    if (comm->phost){
        bb_host_disconnect(comm->phost);
        comm->phost = NULL;
    }

    //释放P401D信号强度的指针
    if (pAR8030Helper == NULL || pAR8030Helper->bb_handle == NULL){
        qWarning() << "Error disconnect pAR8030Helper";
        return ;
    }
    if (pAR8030Helper->pair_status){
        pthread_join(pAR8030Helper->pair_thread,NULL);
    }
    if (pAR8030Helper->bb_handle){
        bb_dev_close(pAR8030Helper->bb_handle);
        pAR8030Helper->bb_handle = NULL;
    }
    if (pAR8030Helper->dbg_bb_handle){
        bb_dev_close(pAR8030Helper->dbg_bb_handle);
        pAR8030Helper->dbg_bb_handle = NULL;
    }
    if (pAR8030Helper->phost){
        bb_host_disconnect(pAR8030Helper->phost);
        pAR8030Helper->phost = NULL;
    }

    _P401DIsConnected = false;

    QObject::disconnect(&_readTimer, &QTimer::timeout, this, &P401DLink::_readBytes);
    QObject::disconnect(&_signalTimer, &QTimer::timeout, this, &P401DLink::AR8030Helper_get1V1Info);
    emit disconnected();
}

bool P401DLink::_connect(void)
{
    int ret_comm = _hardwareConnect();

    if (ret_comm == 0)
    {
        int ret_helper = AR8030Helper_connectToDaemon();
        if (ret_helper)
        {
            qDebug() << "Can not init AR8030Helper";
        }
    }
    return ret_comm;
}

bool P401DLink::_hardwareConnect()  //AR8030Comm_socket_open
{
    int s32Ret = bb_host_connect(&comm->phost,"127.0.0.1",BB_PORT_DEFAULT);
    if(s32Ret != 0){
        // LOGE("bb connect error,ret=%d",s32Ret);
        comm->phost = NULL;
        return -1;
    }

    bb_dev_t** devs=NULL;
    /* get dev list of the 8030 */
    int dev_num = bb_dev_getlist(comm->phost,&devs);
    if (dev_num <= 0) {
        // LOGE("Get no device!");
        bb_host_disconnect(comm->phost);
        comm->phost = NULL;
        return -1;
    }

    /* Open the dev 8030 */
    comm->bb_handle = bb_dev_open(devs[0]);
    if (!comm->bb_handle) {
        // LOGE("bb_dev_open error");
        bb_dev_freelist(devs);
        comm->bb_handle = NULL;
        bb_host_disconnect(comm->phost);
        comm->phost = NULL;
        return -1;
    }
    bb_dev_freelist(devs);
    // LOGD("Build connection with 8030 success!\n");

    bb_sock_opt_t sock_data_buf_size;

    sock_data_buf_size.rx_buf_size=128;
    sock_data_buf_size.tx_buf_size=128;

    comm->bb_skt_fd = bb_socket_open(comm->bb_handle,
                                     comm->slot,
                                     comm->port,
                                     BB_SOCK_FLAG_RX | BB_SOCK_FLAG_TX,
                                     &sock_data_buf_size);
    if (comm->bb_skt_fd < 0) {
        // LOGD("bb_socket_open error");
        bb_dev_close(comm->bb_handle);
        comm->bb_handle = NULL;
        bb_host_disconnect(comm->phost);
        comm->phost = NULL;
        comm->bb_skt_fd = 0;
        return -1;
    }

    _P401DIsConnected = true;
    emit connected();
    return 0;
}

/**
 * @brief Check if connection is active.
 *
 * @return True if link is connected, false otherwise.
 **/
bool P401DLink::isConnected() const
{
    return _P401DIsConnected;
}

//--------------------------------------------------------------------------
//-- P401D信号强度获取
int P401DLink::AR8030Helper_init(AR8030Helper** pAR8030Helper,int isAp,int slot)
{
    (*pAR8030Helper) = (AR8030Helper*)malloc(sizeof(AR8030Helper));
    (*pAR8030Helper)->bb_handle = NULL;
    (*pAR8030Helper)->phost = NULL;
    (*pAR8030Helper)->dbg_bb_handle = NULL;
    (*pAR8030Helper)->is_ap = isAp;
    (*pAR8030Helper)->slot = slot;

    pthread_mutex_init(&(*pAR8030Helper)->pair_lock,NULL);
    (*pAR8030Helper)->pair_thread = 0;
    (*pAR8030Helper)->pair_status = 0;

    pthread_mutex_init(&(*pAR8030Helper)->ota_lock,NULL);
    (*pAR8030Helper)->ota_thread = 0;
    (*pAR8030Helper)->ota_status = 0;

    return 0;
}

int P401DLink::AR8030Helper_connectToDaemon()
{
    int s32Ret = bb_host_connect(&pAR8030Helper->phost,"127.0.0.1",BB_PORT_DEFAULT);

    if(s32Ret != 0){
        qDebug()<<"bb connect error,ret = "<< s32Ret;
        pAR8030Helper->phost = NULL;
        //bb_deinit();
        return ERE_NO_INIT;
    }
    bb_dev_t** devs=NULL;
    /* get dev list of the 8030 */
    int dev_num = bb_dev_getlist(pAR8030Helper->phost,&devs);
    if (dev_num <= 0) {
        qDebug()<<"Get no device!";
        bb_host_disconnect(pAR8030Helper->phost);
        pAR8030Helper->phost = NULL;
        return ERE_NO_INIT;
    }

    /* Open the dev 8030 */
    pAR8030Helper->bb_handle = bb_dev_open(devs[0]);
    if (!pAR8030Helper->bb_handle) {
        qDebug()<<"bb_dev_open error";
        bb_dev_freelist(devs);
        pAR8030Helper->bb_handle = NULL;
        bb_host_disconnect(pAR8030Helper->phost);
        pAR8030Helper->phost = NULL;
        //bb_deinit();
        return ERE_NO_INIT;
    }

    bb_dev_freelist(devs);

    qDebug()<<"Build connection with 8030 success!";
    return 0;
}

int P401DLink::AR8030Helper_get1V1Info()
{
    if (pAR8030Helper == NULL || pAR8030Helper->bb_handle == NULL){
        return ERE_NO_INIT;
    }
    if (pAR8030Helper->pair_status != 0){
        return ERE_PAIR;
    }
    if (pAR8030Helper->ota_status != 0){
        return ERE_OTA;
    }
    bb_get_1v1_info_in_t in;
    in.frame_num = 0;
    int ret = bb_ioctl(pAR8030Helper->bb_handle, BB_GET_1V1_INFO, &in, &helper_out);
    
    P401DSignalRSSI();

    return ret;
}

int P401DLink::ConstrainInt(int value, int min, int max)
{

    return std::max(min, std::min(value, max));
}

int P401DLink::P401DSignalRSSI()
{
    int p401d_snr = 10 * log10(helper_out.self.snr / 36.0);

    // SNR数组
    std::vector<int> snrArr = {0, 2, 4, 7, 9, 12, 14, 18};
    int arrSize = snrArr.size();

    // 如果 p401d_snr 不在 [0, 100] 之间，设为 0
    if (p401d_snr < 0 || p401d_snr > 100) {
        p401d_snr = 0;
    }

    // 如果 p401d_snr 小于数组的最大值
    if (p401d_snr < snrArr[arrSize - 1]) {
        // 遍历数组
        for (int i = 0; i < arrSize; ++i) {
            int value = snrArr[i];
            if (value >= p401d_snr) {
                if (i == 0) {
                    apSignal = GetFilterValue(0);
                } else {
                    double one = 100.0 / arrSize;
                    double offset = (i - 1) * one;
                    int minSnr = snrArr[i - 1];
                    int maxSnr = value;
                    int constrainedSNR = ConstrainInt(p401d_snr, minSnr, maxSnr);
                    double value0 = ((double)(constrainedSNR - minSnr) / (maxSnr - minSnr)) * one + offset;
                    apSignal = GetFilterValue((int)value0);
                }
                break;
            }
        }
    }else
    {
        apSignal = GetFilterValue(100);
    }
    emit p401dRSSIChanged(apSignal);
    
    return apSignal;
}

int P401DLink::AR8030Helper_release(AR8030Helper* pAR8030Helper)
{
    if (pAR8030Helper == NULL){
        return 0;
    }
    pthread_mutex_destroy(&pAR8030Helper->pair_lock);
    pthread_mutex_destroy(&pAR8030Helper->ota_lock);
    free(pAR8030Helper);
    return 0;
}

int P401DLink::GetFilterValue(int value) {
    // std::vector<int> filterBuff;    // 用 std::vector 来模拟动态大小的缓冲区
    static int maxFilterNum = 5;
    std::vector<int> filterBuff(maxFilterNum, 0);
    int filterBuffSize = 0;
    int filterBuffIndex = 0;
    int filterSum = 0;

    // 如果索引超过最大数量，重新从头开始
    if (filterBuffIndex >= maxFilterNum) {
        filterBuffIndex = 0;
    }

    // 更新滤波器缓冲区
    if (filterBuffSize >= maxFilterNum) {
        filterBuff[filterBuffIndex++] = value;  // 如果缓冲区满了，替换当前索引的数据
    } else {
        filterBuff[filterBuffIndex++] = value;  // 如果缓冲区未满，直接插入新数据
        filterBuffSize++;
    }

    // 计算滤波器的值
    for (int i = 0; i < filterBuffSize; ++i) {
        filterSum += filterBuff[i];
    }

    // 返回滤波值
    return filterSum / filterBuffSize;
}
//--------------------------------------------------------------------------
//-- P401DConfiguration


P401DConfiguration::P401DConfiguration(const QString& name) : LinkConfiguration(name)
{

}

P401DConfiguration::P401DConfiguration(P401DConfiguration* source) : LinkConfiguration(source)
{
    
}

void P401DConfiguration::saveSettings(QSettings& settings, const QString& root)
{
    settings.beginGroup(root);
    settings.setValue("port", (int)_port);
    settings.setValue("host", address().toString());
    settings.endGroup();
}

void P401DConfiguration::loadSettings(QSettings& settings, const QString& root)
{
    settings.beginGroup(root);
    settings.endGroup();
}
