//
//  SSCMParamEngine.h
//  QQMSFContact
//
//  Created by jontan on 12-10-23.
//
//

#import <Foundation/Foundation.h>

@interface SSCMParamEngine : NSObject
{
    NSDictionary* _sscmParamDic;
}

+ (SSCMParamEngine*)getInstance;

- (int)getIntParamValue:(NSString*)paramKey;
- (long)getLongParamValue:(NSString*)paramKey;
- (double)getDoubleParamValue:(NSString*)paramKey;

- (int)getSFiSwitch;
- (int)getSFiNo;
- (long)getSFiWifiSz;
- (long)getSFiWWANSz;
- (long)getSFiWWANMax;
- (int)getSFiStableUsn;
- (double)getSFiSlopePoi;
- (double)getSFiSlowRate;
- (double)getSFiQuickRate;
- (int)getSFiSmallPic;
- (int)getSFiSmallMulity;
- (int)getSFiNVTThreshold;
- (long)getSFiMNVT;
- (long)getSFiMSNVT;
- (long)getSFiNVTInterval;
- (long)getSFiConfirmNum;
- (int)getSFiRetryMax;


@end
