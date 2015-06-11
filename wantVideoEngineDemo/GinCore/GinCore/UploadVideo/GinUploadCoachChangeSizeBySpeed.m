//
//  GinUploadCoachChangeSizeBySpeed.m
//  microChannel
//
//  Created by joeqiwang on 14-3-20.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinUploadCoachChangeSizeBySpeed.h"
#import "GinLog.h"

#pragma mark -Constants

typedef enum
{
    // In kilo bytes
    kGinNetworkSpeedInWeakNetwork = 4,
    kGinNetworkSpeedIn2G = 15,
    kGinNetworkSpeedIn3G = 120,
    kGinNetworkSpeedInLTE = 250
}GinOptimizeNetworkStatus;//各种网络情况的最优值

typedef NS_ENUM(NSInteger, GinVideoUploadPackageSizeType)
{
    GinVideoUploadPackageSizeForWeakNetwork = 32,
    GinVideoUploadPackageSizeFor2G = 64,
    GinVideoUploadPackageSizeFor3G = 128,
    GinVideoUploadPackageSizeForLTE = 512,
    GinVideoUploadPackageSizeForWifi = 1024
};


@implementation GinUploadCoachChangeSizeBySpeed

#pragma mark -public methods

- (unsigned long long)getPackageSizeByPreviousSize:(unsigned long long)preSize andElapseTime:(double)duration
{
    unsigned long long packageSize = 0;
    CGFloat speedForLastRequest = 0;    // in KB
    CGFloat tmpNum = 0;
    if (duration != 0)
    {
        tmpNum = preSize/1024;
        speedForLastRequest = tmpNum/duration;
    }
    
    // 根据之前的传输速度决定包大小
    if (0 == speedForLastRequest)
    {
        // 之前没有数据传输，先尝试发送一个32k bytes的包，测试一下bandwidth
        packageSize = GinVideoUploadPackageSizeForWeakNetwork;
    }
    else if (speedForLastRequest > 0 && speedForLastRequest <= kGinNetworkSpeedInWeakNetwork)
    {
        packageSize = GinVideoUploadPackageSizeForWeakNetwork;
    }
    else if (speedForLastRequest > kGinNetworkSpeedInWeakNetwork && speedForLastRequest <= kGinNetworkSpeedIn2G)
    {
        packageSize = GinVideoUploadPackageSizeFor2G;
    }
    else if (speedForLastRequest > kGinNetworkSpeedIn2G && speedForLastRequest <= kGinNetworkSpeedIn3G)
    {
        packageSize = GinVideoUploadPackageSizeFor3G;
    }
    else if (speedForLastRequest > kGinNetworkSpeedIn3G && speedForLastRequest <= kGinNetworkSpeedInLTE)
    {
        packageSize = GinVideoUploadPackageSizeForLTE;
    }
    else
    {
        // 如果速度大于LTE就选择最大的包大小了
        packageSize = GinVideoUploadPackageSizeForWifi;
    }
    
    // 转化为bytes
    packageSize *= 1024;
    
    packageSize = self.uploadedOffset+packageSize > self.totalSize ? self.totalSize-self.uploadedOffset : packageSize;
    GINFO(LogModuleVideoUpload, @"DYNAMIC PACKAGE SIZE STRATEGY, the speed is: %f; package size is: %llu", speedForLastRequest, packageSize);
    return packageSize;
}

@end
