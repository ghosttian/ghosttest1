//
//  SSCMTimer.h
//  QQMSFContact
//
//  Created by wstt on 12-8-20.
//
//

#import <Foundation/Foundation.h>
#import "SSCMDef.h"

//#define M_SSCM_NVT_INTERVAL 5

@protocol SSCMTimerDelegate <NSObject>
@required
- (void) SSCMTimerOut;
@end

@interface SSCMTimer : NSObject
{
    long    _TB;
    long    _TBn;
    long    _startTB;
    long    _totalTB;
    long    _difTB;
    int     _NVT;   //Net Vacuum Time:真空时长  真空：链路上没有数据
    int     _SNVT;  //累计真空时长
    NSTimer *_NVTimer;
    int     _eventOfNVTimer;

    NET_TYPE _networkType;
    
    //鱼翅相关参数
    int _SFiNVTInterval;
    int _SFiMNVT;
    int _SFiMSNVT;
}
@property(nonatomic,assign) id<SSCMTimerDelegate> delegate;

@property(nonatomic,assign) int NVT;
@property(nonatomic,assign) int SNVT;

// 启动定时器，输入网络类型，用于监控对应的网口流量 并设置回调
- (void) setSSCMConnectTimeOut:(NET_TYPE)netType delegate:(id<SSCMTimerDelegate>)delegate;

// 取消定时器
- (void) cancelSSCMConnectTimer;

- (double) getPkgKB;
- (double) getTotalKB;


@end
