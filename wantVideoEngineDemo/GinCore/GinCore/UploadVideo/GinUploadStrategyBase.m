//
//  GinUploadStrategyBase.m
//  microChannel
//
//  Created by joeqiwang on 14-1-13.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinUploadStrategyBase.h"
#import "GinUploadRequiredInfo.h"

@implementation GinUploadStrategyBase

- (void)dealloc
{
}

- (void)uploadVideoWithRequiredInfo:(GinUploadRequiredInfo*)info
{
    self.uploadStage = kGinVideoUploadPreApply;
}

- (void)continueUploadVideoWithModel:(GinUploadRequiredInfo *)model
{
    
    if (UP_STEP_APPLY == model.uploadStage)
    {
        self.uploadStage = kGinVideoUploadPreApply;
    }
    else
    {
        self.uploadStage = kGinVideoUploadVideo;
    }
}

- (void)suspendUploadVideo
{
}

@end

