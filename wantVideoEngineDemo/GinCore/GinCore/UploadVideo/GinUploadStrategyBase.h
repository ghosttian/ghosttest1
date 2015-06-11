//
//  GinUploadStrategyBase.h
//  microChannel
//
//  Created by joeqiwang on 14-1-13.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GinUploadResult.h"
#import "MVVideoCommonDefine.h"
#import "GinUploadVideoProgressDelegateDef.h"
//#import "GinWriteFailView.h"

typedef enum
{
    SamePackageSizeMethod = 0,
    VariousPackageSizeMehtod = 1,
    SharkFinMethod = 2
}UploadSubType;

@class GinUploadRequiredInfo;
@class GinUploadCoachBase;

@interface GinUploadStrategyBase : NSObject
{
    BOOL _isGorgeousDisplayProgress;
}

@property (nonatomic, assign) GinVideoUploadStage uploadStage;
@property (nonatomic, assign) BOOL shouldDisplayProgress;
@property (nonatomic, assign) BOOL isGorgeousDisplayProgress;
@property (nonatomic, copy) void (^completeBlock)(GinUploadResult *result);
@property (nonatomic, weak) id<UploadProgressUpdateDelegate> delegate;              // 用于上传更新进度的delegate
@property (nonatomic, assign) ShootVideoType VideoType;                          // 区分视频是长视频还是短视频
@property (nonatomic, strong) GinUploadCoachBase *uploadCoach;                      // 具体负责上传策略中使用的算法来决定分包大小

- (void)uploadVideoWithRequiredInfo:(GinUploadRequiredInfo *)info;

- (void)continueUploadVideoWithModel:(GinUploadRequiredInfo *)model;

- (void)suspendUploadVideo;

@end

