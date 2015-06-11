//
//  MVVideoEffectVideoProcessor.h
//  SimpleVideoFileFilter
//
//  Created by eson on 14-9-2.
//  Copyright (c) 2014年 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MVVideoEffectDefine.h"

@class GPUImageView;

@interface MVVideoEffectVideoProcessor : NSObject

@property (nonatomic, strong, readonly) GPUImageView   *ginPreviewView;
@property (nonatomic, assign, readonly) CFTimeInterval compositionAssetDuration;
@property (nonatomic, assign, readonly) BOOL           isProcessing;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, copy, readwrite) NSString          *exportFilePath;
@property (nonatomic, assign, readwrite) BOOL            paused;
@property (nonatomic, assign, readwrite) BOOL            willExportToFile;
@property (nonatomic, assign, readwrite) BOOL            willAppendLogo;
@property (nonatomic, assign, readwrite) BOOL            willNotificateWhenProcessEnd;
@property (nonatomic, assign, readwrite) BOOL            isProcessForBeauty;
@property (nonatomic, assign, readwrite) CGSize          outputVideoSize; // Default kSquaredVideoSize
@property (nonatomic, copy, readwrite)  dispatch_block_t didProcessedFirstFrameBlock;
@property (nonatomic, assign) BOOL supportSeek;
@property (nonatomic, strong) NSNumber* videoBitrate; //使用该码率导出，如果设置了
@property (nonatomic, strong) NSArray* combineAssets; //多个原视频拼接

- (instancetype)init;
- (void)loadAsset:(AVAsset *)asset effectData:(NSDictionary *)effectData complete:(void (^)(AVAsset *videoAsset))completionHandler;
- (void)loadAsset:(AVAsset *)asset effectData:(NSDictionary *)effectData;
- (BOOL)startProcess;
- (BOOL)startProcessWithLivePreview:(BOOL)livePreview;
- (void)cancelProcess;
- (void)finishProcess:(MVVideoEffectVideoProcessCompletionBlock)completionHandler;

- (UIImage *)imageFromCurrentFrame;

- (BOOL)isProcessingCompleted;

- (void)insertStaticEffects;

@property (nonatomic, assign) float progress;

//get time line
- (NSArray *)effectTimeLines;



@end
