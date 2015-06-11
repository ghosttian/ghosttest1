//
//  GinUploadSoldierVideoExtension.h
//  GinCore
//
//  Created by joeqiwang on 14-12-25.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GinUploadResult.h"
#import "GinUploadStrategyBase.h"
#import "GinUploadVideoDef.h"

@class GinUploadRequiredInfo;
@protocol UploadProgressUpdateDelegate;

@interface GinUploadSoldierVideoExtension : NSObject

// 设置上传采用的方式
- (void)setUploadStrategyType:(GinUploadStrategyType)type;
// 设置上传的视频是长视频还是短视频
- (void)setUploadVideoDurationType:(ShootVideoType)videoType;
// 设置需要更新上传进度的delegate
- (void)setProgressUpdateDelegate:(id<UploadProgressUpdateDelegate>)delegate;
// 设置上传结束后的操作
- (void)setUploadCompleteBlock:(void(^)(GinUploadResult *result))completeBlock;
// 因为预上传的功能，需要更符合美观的显示进度条
- (void)setGorgeousDisplayProgressFlag:(BOOL)flag;

- (GinVideoUploadStage)getUploadStage;

// 上传视频的方法
- (void)uploadVideoWithRequiredInfo:(GinUploadRequiredInfo *)info;

// 上传失败后，根据上传结果重新上传
- (void)continueUploadVideoWithModel:(GinUploadRequiredInfo *)model;

// 暂停视频上传的方法
- (void)suspendUploadVideo;

@end
