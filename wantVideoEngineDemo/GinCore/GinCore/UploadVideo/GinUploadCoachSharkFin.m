//
//  GinUploadCoachSharkFin.m
//  microChannel
//
//  Created by joeqiwang on 14-3-24.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinUploadCoachSharkFin.h"
#import "SSCM.h"
#import "GinNetworkUtils.h"
#import "GinLog.h"
//#import "GinUploadUtil.h"

@interface  GinUploadCoachSharkFin()

@property (nonatomic, strong) SSCM* sscmModel;

@end

@implementation GinUploadCoachSharkFin

- (id)init
{
    if (self = [super init])
    {
        self.sscmModel = [[SSCM alloc] init];
    }
    return self;
}

- (unsigned long long)getPackageSizeByPreviousSize:(unsigned long long)preSize andElapseTime:(double)duration
{
    unsigned long long packageSize = 0;
    
    // 如果之前的请求失败，重试的话需要清空之前数据从头开始计算分片大小的增长
    if (0 == duration)
    {
        [self.sscmModel initParam];
    }
    else
    {
        // 设置上一片发送的耗时，便于计算下片的大小
        [self.sscmModel setPkgSendT:duration];
    }
    
    if ([GinNetworkUtils isWifi])
    {
        packageSize = [self.sscmModel getPkgSizeByNetType:TYPE_WIFI fileSize:self.totalSize transferedSize:self.uploadedOffset];
    }
    else
    {
        packageSize = [self.sscmModel getPkgSizeByNetType:TYPE_WWAN fileSize:self.totalSize transferedSize:self.uploadedOffset];
    }
    GINFO(LogModuleVideoUpload, @"SHARK FIN STRATEGY, package size is: %llu", packageSize);
    return packageSize;
}

@end
