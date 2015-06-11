//
//  GinUploadVideoProgressDelegateDef.h
//  GinCore
//
//  Created by joeqiwang on 14-12-25.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#ifndef GinCore_GinUploadVideoProgressDelegateDef_h
#define GinCore_GinUploadVideoProgressDelegateDef_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GinUploadVideoDef.h"

@class GinDraftModelMetal;
@class GinTweetInfo;

@protocol UploadProgressUpdateDelegate <NSObject>
@optional
//设置进度
- (void)setUploadProgressStart:(CGFloat)start nextProgress:(CGFloat)next total:(CGFloat)total;
- (void)setUploadProgressWithStartPoint:(CGFloat)startPoint nextPoint:(CGFloat)nextPoint estimatedTime:(CGFloat)estimatedTime endPoint:(CGFloat)endPoint;

//发送成功或失败状态切换
-(void)changeSendingState:(eSendingBarStatus)state erro:(NSError *)error;

- (void)setUpLoadProgressStartTime:(NSTimeInterval)writeStartTime;
- (void)setUpLoadProgressWriteModel:(GinDraftModelMetal *)writeModel;
- (void)setUpLoadProgress:(CGFloat)progress;
- (void)setUploadOffset:(int)offset;
- (void)setUpLoadProgressGinTweetInfo:(GinTweetInfo*)tweetInfo;
@end

#endif
