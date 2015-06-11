//
//  SSCMTimer.m
//  QQMSFContact
//
//  Created by wstt on 12-8-20.
//
//

#import "SSCMTimer.h"
#import "Utils.h"
#import "SSCMParamEngine.h"

@implementation SSCMTimer

@synthesize delegate = _delegate;
@synthesize NVT = _NVT;
@synthesize SNVT = _SNVT;

- (void) initParam
{
    _TB      = 0;
    _TBn     = 0;
    _NVT     = 0;
    _SNVT    = 0;
    _difTB   = 0;
    _startTB = 0;
    _eventOfNVTimer = 0; // 0表示正常，1表示MNVT超时，2表示网络切换
    
    _SFiNVTInterval = [[SSCMParamEngine getInstance] getSFiNVTInterval];
    _SFiMNVT    = [[SSCMParamEngine getInstance] getSFiMNVT]; // 最大真空时间120s
    _SFiMSNVT   = [[SSCMParamEngine getInstance] getSFiMSNVT];
    
}

- (id) init
{
    self = [super init];
    if (self) {
        _totalTB = 0;
        [self initParam];
    }
    
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    
    if (nil != _NVTimer) {
        [_NVTimer invalidate];
        _NVTimer = nil;
    }
}

- (void) NVTimerProc
{
    _TBn = [Utils getOutOctets:_networkType];
    _difTB = _TBn - _TB;
    _TB = _TBn;

    if (_difTB > [[SSCMParamEngine getInstance] getSFiNVTThreshold]) {
        _NVT = 0;
    } else {
        _NVT  += _SFiNVTInterval;
        _SNVT += _SFiNVTInterval;
        if ((_NVT >= _SFiMNVT) || (_SNVT >= _SFiMSNVT)) {
            if (_delegate && [_delegate respondsToSelector:@selector(SSCMTimerOut)])
            {
                [_delegate SSCMTimerOut];
            }
            _eventOfNVTimer = 1; // 表示超时
            [self cancelSSCMConnectTimer];
        }
    }
#ifdef DEBUG_CONSOLE
    NSString *str = [NSString stringWithFormat:@"difTB:%lu\nNVT:%d|MNVT:%d|SNVT:%d|MSNVT:%d", _difTB, _NVT, _SFiMNVT, _SNVT, _SFiMSNVT];
    BHDebug_setOutput(@"SSCMTimer", str);
//    BHDebug_addLog(@"Timer--%@", str);
#endif
}

- (void) setSSCMConnectTimeOut:(NET_TYPE)netType delegate:(id<SSCMTimerDelegate>)delegate
{
    [self cancelSSCMConnectTimer];
    if (_NVTimer == nil) {
        _NVTimer = [NSTimer scheduledTimerWithTimeInterval:_SFiNVTInterval target:self selector:@selector(NVTimerProc) userInfo:nil repeats:YES];
        [self initParam];
        _networkType = netType;
        _TB          = [Utils getOutOctets:netType];
        _startTB     = _TB;
        if (_totalTB == 0) {
            _totalTB = _TB;
        }
#ifdef DEBUG_CONSOLE
        NSString *str = [NSString stringWithFormat:@"difTB:%lu\nNVT:%d|MNVT:%d|SNVT:%d|MSNVT:%d", _difTB, _NVT, _SFiMNVT, _SNVT, _SFiMSNVT];
        BHDebug_setOutput(@"SSCMTimer", str);
#endif
    }
    
    _delegate = delegate;
}

- (void) cancelSSCMConnectTimer
{
    if (nil != _NVTimer) {
        [_NVTimer invalidate];
        _NVTimer = nil;
    }
}

- (double) getPkgKB
{
    long difTB = [Utils getOutOctets:_networkType] - _startTB;
    return difTB/1024.0;
}

- (double) getTotalKB
{
    long difTB = [Utils getOutOctets:_networkType] - _totalTB;
    return difTB/1024.0;
}

@end
