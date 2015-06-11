//
//  SSCMParamEngine.m
//  QQMSFContact
//
//  Created by jontan on 12-10-23.
//
//

#import "SSCMParamEngine.h"
//#import "QQAppSetting.h"

static const int SFi_Switch = 1;             //鱼翅总开关  0：使用老的分片方案  1：使用鱼翅方案
static const int SFi_No = 0;                 //鱼翅参数编号
static const long SFi_Wifi_Sz = 131072;       //wifi下：初始分片大小128K
static const long SFi_WWAN_Sz = 16384;        //非wifi下：初始分片大小16K（ios 不区分2G、3G）
static const long SFi_WWAN_Max = 262144;      //非wifi下，分片大小上限设为256K
static const int  SFi_Stable_Usn = 3;         //在稳定态下，允许出现的连续不稳定值的最大次数
static const double SFi_Slope_Poi = 0.09;       //拐点
static const double SFi_Slow_Rate = 1.05;       //慢增长率
static const double SFi_Quick_Rate = 2;         //快增长率
static const int SFi_Small_Pic = 102400;     //小图界限100K
static const int SFi_Small_Mulity = 2;       //初始分片“增倍处理”
static const int SFi_NVT_Threshold = 100;    //真空阈值
static const long SFi_MNVT = 30;              //最大真空时间30s
static const long SFi_MSNVT = 60;             //累计最大真空时间60s
static const long SFi_NVT_Interval = 5;       //是否有网络流量的检测间隔时间
static const long SFi_Confirm_Num = 2;        //速率不在预期内的分片大小需要在原分片大小确认的次数
static const int SFi_Retry_Max = 180;        //每次尝试机会最长时间

static SSCMParamEngine* g_SSCMParamEngine = nil;

@implementation SSCMParamEngine

+ (SSCMParamEngine*)getInstance
{
	@synchronized(self){
		if (nil == g_SSCMParamEngine) {
			g_SSCMParamEngine = [[SSCMParamEngine alloc] init];
		}
	}
	return g_SSCMParamEngine;
}

- (id) init
{
    self = [super init];
    if (self) {
        _sscmParamDic = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:SFi_Switch],@"SFi_Switch",
                          [NSNumber numberWithInt:SFi_No],@"SFi_No",
                          [NSNumber numberWithLong:SFi_Wifi_Sz],@"SFi_Wifi_Sz",
                          [NSNumber numberWithLong:SFi_WWAN_Sz],@"SFi_WWAN_Sz",
                          [NSNumber numberWithLong:SFi_WWAN_Max],@"SFi_WWAN_Max",
                          [NSNumber numberWithInt:SFi_Stable_Usn],@"SFi_Stable_Usn",
                          [NSNumber numberWithDouble:SFi_Slope_Poi],@"SFi_Slope_Poi",
                          [NSNumber numberWithDouble:SFi_Slow_Rate],@"SFi_Slow_Rate",
                          [NSNumber numberWithDouble:SFi_Quick_Rate],@"SFi_Quick_Rate",
                          [NSNumber numberWithInt:SFi_Small_Pic],@"SFi_Small_Pic",
                          [NSNumber numberWithInt:SFi_Small_Mulity],@"SFi_Small_Mulity",
                          [NSNumber numberWithInt:SFi_NVT_Threshold],@"SFi_NVT_Threshold",
                          [NSNumber numberWithLong:SFi_MNVT],@"SFi_MNVT",
                          [NSNumber numberWithLong:SFi_MSNVT],@"SFi_MSNVT",
                          [NSNumber numberWithLong:SFi_NVT_Interval],@"SFi_NVT_Interval",
                          [NSNumber numberWithLong:SFi_Confirm_Num],@"SFi_Confirm_Num",
                          [NSNumber numberWithInt:SFi_Retry_Max],@"SFi_Retry_Max",
                           nil];
    }
    return self;
}

- (void)dealloc
{
}

- (int)getIntParamValue:(NSString*)paramKey
{
//    NSMutableDictionary* setting = [[QQAppSetting GetInstance] appSetting];
//    NSString* strParamValue = [setting objectForKey:paramKey];
//    if (strParamValue) {
//        return [strParamValue intValue];
//    } else {
//        NSNumber* defaultParamValue = [_sscmParamDic objectForKey:paramKey];
//        if (defaultParamValue) {
//            return [defaultParamValue intValue];
//        }
//    }
    NSNumber* defaultParamValue = [_sscmParamDic objectForKey:paramKey];
    if (defaultParamValue)
    {
        return [defaultParamValue intValue];
    }
    return 0;
}

- (long)getLongParamValue:(NSString*)paramKey
{
//    NSMutableDictionary* setting = [[QQAppSetting GetInstance] appSetting];
//    NSString* strParamValue = [setting objectForKey:paramKey];
//    if (strParamValue) {
//        return [strParamValue longLongValue];
//    } else {
//        NSNumber* defaultParamValue = [_sscmParamDic objectForKey:paramKey];
//        if (defaultParamValue) {
//            return [defaultParamValue longValue];
//        }
//    }
    NSNumber* defaultParamValue = [_sscmParamDic objectForKey:paramKey];
    if (defaultParamValue)
    {
        return [defaultParamValue longValue];
    }
    return 0;
}

- (double)getDoubleParamValue:(NSString*)paramKey
{
//    NSMutableDictionary* setting = [[QQAppSetting GetInstance] appSetting];
//    NSString* strParamValue = [setting objectForKey:paramKey];
//    if (strParamValue) {
//        return [strParamValue doubleValue];
//    } else {
//        NSNumber* defaultParamValue = [_sscmParamDic objectForKey:paramKey];
//        if (defaultParamValue) {
//            return [defaultParamValue doubleValue];
//        }
//    }
    NSNumber* defaultParamValue = [_sscmParamDic objectForKey:paramKey];
    if (defaultParamValue)
    {
        return [defaultParamValue doubleValue];
    }
    return 0;
}

- (int)getSFiSwitch
{
    return [self getIntParamValue:@"SFi_Switch"];
}

- (int)getSFiNo
{
    return [self getIntParamValue:@"SFi_No"];
}

- (long)getSFiWifiSz
{
    return [self getLongParamValue:@"SFi_Wifi_Sz"];
}

- (long)getSFiWWANSz
{
    return [self getLongParamValue:@"SFi_WWAN_Sz"];
}

- (long)getSFiWWANMax
{
    return [self getLongParamValue:@"SFi_WWAN_Max"];
}

- (int)getSFiStableUsn
{
    return [self getIntParamValue:@"SFi_Stable_Usn"];
}

- (double)getSFiSlopePoi
{
    return [self getDoubleParamValue:@"SFi_Slope_Poi"];
}

- (double)getSFiSlowRate
{
    return [self getDoubleParamValue:@"SFi_Slow_Rate"];
}

- (double)getSFiQuickRate
{
    return [self getDoubleParamValue:@"SFi_Quick_Rate"];
}

- (int)getSFiSmallPic
{    
    return [self getIntParamValue:@"SFi_Small_Pic"];
}

- (int)getSFiSmallMulity
{
    return [self getIntParamValue:@"SFi_Small_Mulity"];
}

- (int)getSFiNVTThreshold
{
    return [self getIntParamValue:@"SFi_NVT_Threshold"];
}

- (long)getSFiMNVT
{
    return [self getLongParamValue:@"SFi_MNVT"];
}

- (long)getSFiMSNVT
{
    return [self getLongParamValue:@"SFi_MSNVT"];
}

- (long)getSFiNVTInterval
{
    return [self getLongParamValue:@"SFi_NVT_Interval"];
}

- (long)getSFiConfirmNum
{
    return [self getLongParamValue:@"SFi_Confirm_Num"];
}

- (int)getSFiRetryMax
{
    return [self getLongParamValue:@"SFi_Retry_Max"];
}
@end


