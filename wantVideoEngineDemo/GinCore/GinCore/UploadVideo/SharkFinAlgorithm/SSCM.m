//
//  SSCM.m
//  QQMSFContact
//
//  Created by wstt on 12-8-20.
//
//

#import "SSCM.h"
#import "SSCMParamEngine.h"

@implementation SSCM

@synthesize networkType = _networkType;
@synthesize Sn = _Sn;

- (id) init
{
    self = [super init];
    if (self) {
        [self initParam];
    }
    return self;
}

- (void) initParam
{
    _initFlag    = true;
    _switchFlag  = NO;
    _confirmNum  = 0;
    _state       = SSCM_STATE_QUICK_START;
    
    _S1 = 0;
    _Sn = 0;
    _So = 0;
    _V1 = 0;
    _Vn = 0;
    _Vo = 0;
    _T  = 0;
    
    _slope       = 0;
    _unStableNum = 0;
    
    _networkType     = TYPE_WIFI;
    _SFiStableUsn = [[SSCMParamEngine getInstance] getSFiStableUsn];
    _SFiSlowRate = [[SSCMParamEngine getInstance] getSFiSlowRate];
    _SFiQuikeRate = [[SSCMParamEngine getInstance] getSFiQuickRate];
    _SFiSlopePoi = [[SSCMParamEngine getInstance] getSFiSlopePoi];
    
    _pkgCnt = 0;
    _pkgMaxCnt = 0;
    _uploadRangeLen = 0;
    _rangeErrCnt = 0;
}

- (NSUInteger) getPkgInitSizeByNetType:(NSUInteger)netType fileSize:(NSUInteger)fileSize
{
    switch (netType) {
		case TYPE_WIFI:
            _S1 = [[SSCMParamEngine getInstance] getSFiWifiSz];
			break;
		case TYPE_WWAN:
            _S1 = [[SSCMParamEngine getInstance] getSFiWWANSz];
			break;
		default:
			_S1 = 3 * 1024;
            break;
    }
    
    _networkType = netType;
    _pkgMaxCnt = (int) (3 * fileSize/_S1);
#ifdef DEBUG_CONSOLE
    BHDebug_addLog(@"_pkgMaxCnt:%d", _pkgMaxCnt);
#endif
    
    if (fileSize < [[SSCMParamEngine getInstance] getSFiSmallPic])
    {
        _S1 *= [[SSCMParamEngine getInstance] getSFiSmallMulity];
    }
    
    int tempLastFileSize = (int) (fileSize - _S1);
    if (tempLastFileSize <= (_S1 / 2))
    {
        _S1 = (int) fileSize;
    }


    return _S1;
}

- (NSUInteger) getWifiPkgSize:(NSUInteger)fileSize transferedSize:(NSUInteger)transferedSize
{
    _Vn = (float) (_Sn / _T);
    
    // 意味着首片
    if (_Vo == 0) {
        _slope = 1;
        _V1 = _Vn;
    } else {
        _slope = (float) (((_Vn - _Vo) / _V1) / ((_Sn - _So) / (_S1 + 0.00)));
    }

    if (_slope >= _SFiSlopePoi) {
        _So = _Sn;
        _Vo = _Vn;
        _Sn = (int) (_SFiQuikeRate * _So);
    }

    int tempLastFileSize = (int) (fileSize - transferedSize - _Sn);
    if (tempLastFileSize <= (_Sn / 2)) {
        _Sn = (int) (fileSize - transferedSize);
    }
    
    return _Sn;
}

- (NSUInteger) getWWANPkgSize:(NSUInteger)fileSize transferedSize:(NSUInteger)transferedSize
{
    _Vn = (float) (_Sn / _T);
    
    if (_state != SSCM_STATE_STABLE) {
        // 意味着首片
        if (_Vo == 0) {
            _slope = 1;
            _V1 = _Vn;
        } else {
            _slope = (float) (((_Vn - _Vo) / _V1) / ((_Sn - _So) / (_S1 + 0.00)));
        }
    }

    switch (_state) {
		case SSCM_STATE_QUICK_START:
            if (_slope < _SFiSlopePoi) {
                if (_switchFlag == YES) {
                    _state      = SSCM_STATE_SLOW_START;
                    _switchFlag = NO;
                    _confirmNum = 0;
                    _Sn = (int) (_SFiSlowRate * _So);
                        
                } else {
                    _confirmNum++;
                    if (_confirmNum >= [[SSCMParamEngine getInstance] getSFiConfirmNum]) {
                        _switchFlag = YES;
                    }

                }
            } else {
                _state      = SSCM_STATE_QUICK_START;
                _switchFlag = NO;
                _confirmNum = 0;
                _So = _Sn;
                _Vo = _Vn;
                _Sn = (int) (_SFiQuikeRate * _So);
            }

			break;
		case SSCM_STATE_SLOW_START:
            if (_slope < _SFiSlopePoi) {
                if (_switchFlag == YES) {
                    _state      = SSCM_STATE_STABLE;
                    _switchFlag = NO;
                    _confirmNum = 0;
                    _Vstable    = _Vn; // Stable状态下的速率的基准值
                    _Vo = 0;  // Stable态下无用处,归0
                    _So = 0;  // Stable态下无用处,归0
                } else {
                    _confirmNum++;
                    if (_confirmNum >= [[SSCMParamEngine getInstance] getSFiConfirmNum]) {
                        _switchFlag = YES;
                    }

                }
                
            } else {
                _state = SSCM_STATE_SLOW_START;
                _switchFlag = NO;
                _confirmNum = 0;
                _So = _Sn;
                _Sn = (int) (_SFiSlowRate * _So);
                _Vo = _Vn;
            }
			break;
		case SSCM_STATE_STABLE:
            if (abs(_Vn - _Vstable) > 0.2 * _Vstable) {
				_unStableNum++;
            } else {
				_unStableNum = 0;
            }
            
			if (_unStableNum < _SFiStableUsn) {
				_state = SSCM_STATE_STABLE;
			}
			/*
			 * 由于一旦速率出现较大波动，很难得知新的网络状况下，
			 * 当前的固定分片大小到底位于slowStart、quickStart还是stable区;
			 * 所以直接退回到初始的quickstart状态重新探测
			 */
			else {
                _state = SSCM_STATE_QUICK_START;
				_unStableNum = 0;
				_Sn = _S1;
				_Vo = 0;
				_So = 0;
			}
			break;
    }
    
    int tempLastFileSize = (int) (fileSize - transferedSize - _Sn);
    if (tempLastFileSize <= (_Sn / 2)) {
        _Sn = (int) (fileSize - transferedSize);
    }
    
    if (_Sn > [[SSCMParamEngine getInstance] getSFiWWANMax]) {
        _Sn = [[SSCMParamEngine getInstance] getSFiWWANMax];
    }

    return _Sn;
}

- (NSUInteger) getPkgSizeByNetType:(NSUInteger)netType fileSize:(NSUInteger)fileSize transferedSize:(NSUInteger)transferedSize
{
#ifdef DEBUG_CONSOLE
    BHDebug_addLog(@"====pkg start===");
#endif
    _pkgCnt++;
    if (true == _initFlag) {
        _Sn = [self getPkgInitSizeByNetType:netType fileSize:fileSize];
        // 确认算出的初始分片大小是合法大小
        _Sn = (_Sn+transferedSize > fileSize) ? (fileSize-transferedSize) : _Sn;
        _initFlag = false;
        return _Sn;
    }
    
    if (_networkType == TYPE_WIFI) {
        _Sn = [self getWifiPkgSize:fileSize transferedSize:transferedSize];
    } else {
        _Sn = [self getWWANPkgSize:fileSize transferedSize:transferedSize];
    }
    
    return _Sn;
}

- (void) setPkgSendT:(NSTimeInterval)pkgSendT
{
#ifdef DEBUG_CONSOLE
    float avg = (float) (_Sn / pkgSendT /1024);
    NSString *str = [NSString stringWithFormat:@"%uKB %.2fKB/S", _Sn/1024, avg];
    BHDebug_setOutput(@"PkgInfo", str);
    BHDebug_addLog(@"Pkg:%uKB AvgSpeed:%.2fKB/S T:%.2f", _Sn/1024, avg, pkgSendT);
    //first pkg
    if (_T == 0) {
        NSString *str1 = [NSString stringWithFormat:@"%.2fKB %@", _S1/1024.0, str];
        BHDebug_setOutput(@"_S1", str1);
    }
#endif
    _T = pkgSendT;
}

- (void) setRangeLen:(unsigned int)rangeLen
{
    if (_uploadRangeLen >= rangeLen) {
        _rangeErrCnt++;
    }
    
    _uploadRangeLen = rangeLen;
}

- (BOOL) isValid
{
#ifdef DEBUG_CONSOLE
    BHDebug_addLog(@"_rangeErrCnt:%u _pkgCnt:%u _pkgMaxCnt:%u", _rangeErrCnt, _pkgCnt, _pkgMaxCnt);
#endif
    if (_rangeErrCnt >= 3) {
        return NO;
    }
    
    if (_pkgCnt >= _pkgMaxCnt) {
        return NO;
    }
    
    return YES;
}


@end
