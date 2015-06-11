//
//  GinUploadCoachBase.m
//  microChannel
//
//  Created by joeqiwang on 14-3-20.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinUploadCoachBase.h"
#import "GinNetworkUtils.h"
#import "GinLog.h"

@implementation GinUploadCoachBase

- (unsigned long long)getPackageSizeByPreviousSize:(unsigned long long)preSize andElapseTime:(double)duration
{
    unsigned long long packageSize = 0;
    
    if ([GinNetworkUtils isWifi])
    {
        packageSize = 256;
        // todo: [GlobalConfiguration sharedConfiguration].wifiUpSize;
    }
    else
    {
        packageSize = 128;
        // todo: [GlobalConfiguration sharedConfiguration].nowifiUpSize;
    }
    
    // 如果size为0，代表不分包直接按照整个文件大小上传
    if (0 == packageSize)
    {
        packageSize = self.totalSize;
    }
    else
    {
        packageSize *= 1024;
    }
    
    packageSize = self.uploadedOffset+packageSize > self.totalSize ? self.totalSize-self.uploadedOffset : packageSize;
    GINFO(LogModuleVideoUpload, @"SAME PACKAGE SIZE STRATEGY, the package size is: %llu", packageSize)
    return packageSize;
}

@end
