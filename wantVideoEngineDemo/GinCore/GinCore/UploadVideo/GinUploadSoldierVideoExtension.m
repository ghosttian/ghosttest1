//
//  GinUploadSoldierVideoExtension.m
//  GinCore
//
//  Created by joeqiwang on 14-12-25.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import "GinUploadSoldierVideoExtension.h"
#import "GinLog.h"
#import "GinUploadStrategyByHTTPVideoExtension.h"


@interface GinUploadSoldierVideoExtension()

// Strategy obj用来实现具体的upload方法
@property (nonatomic, strong) GinUploadStrategyBase *uploadStrategy;

@end

@implementation GinUploadSoldierVideoExtension

- (void)setUploadStrategyType:(GinUploadStrategyType)type
{
    switch (type)
    {
        case kGinUploadStrategyFTN:
        {
            self.uploadStrategy = [[GinUploadStrategyByHTTPVideoExtension alloc] init];
            GINFO(LogModuleVideoUpload, @"using FTN to upload video.");
        }
            break;
        case kGinUploadStrategyHTTP:
        default:
        {
            self.uploadStrategy = [[GinUploadStrategyByHTTPVideoExtension alloc] init];
            GINFO(LogModuleVideoUpload, @"using HTTP to upload video.")
        }
            break;
    }
}

- (void)setUploadVideoDurationType:(ShootVideoType)videoType
{
    self.uploadStrategy.VideoType = videoType;
}

- (void)setProgressUpdateDelegate:(id<UploadProgressUpdateDelegate>)delegate
{
    self.uploadStrategy.delegate = delegate;
}

- (void)setUploadCompleteBlock:(void(^)(GinUploadResult *result))completeBlock
{
    self.uploadStrategy.completeBlock = completeBlock;
}

- (void)setGorgeousDisplayProgressFlag:(BOOL)flag
{
    self.uploadStrategy.isGorgeousDisplayProgress = flag;
}

- (GinVideoUploadStage)getUploadStage
{
    return self.uploadStrategy.uploadStage;
}

- (void)uploadVideoWithRequiredInfo:(GinUploadRequiredInfo*)info
{
    [self.uploadStrategy uploadVideoWithRequiredInfo:info];
}

- (void)continueUploadVideoWithModel:(GinUploadRequiredInfo *)model
{
    [self.uploadStrategy continueUploadVideoWithModel:model];
}

- (void)suspendUploadVideo
{
    [self.uploadStrategy suspendUploadVideo];
}


@end
