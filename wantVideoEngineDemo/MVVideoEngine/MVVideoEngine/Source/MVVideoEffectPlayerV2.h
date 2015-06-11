//
//  MVVideoEffectPlayerV2.h
//  microChannel
//
//  Created by aidenluo on 10/31/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "MVVideoEffectDefine.h"

static NSString *kSliderTounchDownNotification = @"kSliderTounchDownNotification";
static NSString *kSliderTounchUpNotification = @"kSliderTounchUpNotification";

@class GPUImageView;
@class MVVideoEffectPlayerModel;
@class MVVideoEffectPlayerV2;

@protocol MVVideoEffectPlayerV2Delegate <NSObject>

@optional
- (void)effectPlayer:(MVVideoEffectPlayerV2 *)player playerItemDuration:(CMTime)time;
- (void)effectPlayer:(MVVideoEffectPlayerV2 *)player didPlayAtTime:(CMTime)time;

@end

@interface MVVideoEffectPlayerV2 : NSObject

@property (nonatomic, weak) id<MVVideoEffectPlayerV2Delegate> delegate;
@property (nonatomic, strong ,readonly) GPUImageView *ginPreviewView;
@property (nonatomic, strong) UISlider *playerSlider;
@property (nonatomic, readonly) UIImage *coverImage;
@property (nonatomic, assign) float progress;
@property (nonatomic, strong) MVVideoEffectPlayerModel *effectModel;
@property (nonatomic, assign) BOOL didProcessedFirstFrame;

- (BOOL)isPlaying;

- (void)loadEffectModel:(MVVideoEffectPlayerModel *)model
			supportSeek:(BOOL)supportSeek
			 completion:(void (^)(NSError *error))completionHandler;

- (void)loadEffectModel:(MVVideoEffectPlayerModel *)model
             completion:(void (^)(NSError *error))completionHandler;

- (void)startPlay;
- (void)pausePlay;
- (void)resumePlay;
- (void)cancelPlay;
- (void)exportVideoCompletion:(MVVideoEffectVideoProcessCompletionBlock)completionHandler;
- (void)seekToTime:(CMTime)time;
- (void)settingWaterMarkLayer:(CALayer *)waterMarkLayer;

- (BOOL)isProcessingCompleted;

- (NSArray *)effectTimeLines;

@end
