//
//  MVVideoEffectPlayerV2.m
//  microChannel
//
//  Created by aidenluo on 10/31/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectPlayerV2.h"
#import "MVVideoEffectPlayerModel.h"
#import "MVVideoEffectAudioProcessor.h"
#import "MVVideoEffectVideoProcessor.h"
#import "SDAVAssetExportSession.h"
#import "MVAudioProcessorResult.h"
#import "GPUImageView.h"
#import "GPUImageFilter.h"
#import "NSDictionary+Util.h"
#import "MVVideoCommonConfig.h"
#import "UIImage+Util.h"
#import "NSDictionary+Util.h"

@interface MVVideoEffectPlayerV2 ()

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *currentPlayerItem;
@property (nonatomic, strong) MVVideoEffectVideoProcessor *videoProcessor;
@property (nonatomic, strong) MVVideoEffectAudioProcessor *audioProcessor;
@property (nonatomic, strong) id playerTimeObserver;
@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, assign) NSTimeInterval coverTime;
@property (nonatomic, assign) BOOL hasCaptureCoverImage;
@property (nonatomic, strong) NSNumber* videoBitrate; //使用该码率导出，如果设置了
@property (nonatomic, strong) NSOperationQueue *coverImageOperationQueue;

@property (nonatomic, assign) BOOL playerPlaying;

@end

@implementation MVVideoEffectPlayerV2

#pragma mark - Public Method

- (void)dealloc
{
    [self.videoProcessor removeObserver:self forKeyPath:@"progress"];
	[self cancelPlay];
	[self removePlayerTimeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
		self.coverImageOperationQueue = [[NSOperationQueue alloc]init];
	
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAVPlayerItemDidPlayToEndTimeNotification:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        self.videoProcessor = [[MVVideoEffectVideoProcessor alloc] init];
        self.audioProcessor = [[MVVideoEffectAudioProcessor alloc] init];
		[self createPlayerWithPlayerItem:nil];
		
		[self.videoProcessor addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)createPlayerWithPlayerItem:(AVPlayerItem *)playerItem
{
	[self removePlayerTimeObserver];

	if (playerItem) {
		self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
	} else {
		self.player = [[AVPlayer alloc] init];
	}
	__weak typeof(self) weakSelf = self;
	self.playerTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30)
																		queue:dispatch_get_main_queue()
																   usingBlock:^(CMTime time) {
																	   double seconds = CMTimeGetSeconds(time);
																	   double duration = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
																	   if (isfinite(duration) && isfinite(seconds) && duration > 0) {
																		   weakSelf.playerSlider.value = MIN(seconds / duration, weakSelf.playerSlider.maximumValue);
																	   }
																	   if ([weakSelf.delegate respondsToSelector:@selector(effectPlayer:didPlayAtTime:)]) {
																		   [weakSelf.delegate effectPlayer:weakSelf didPlayAtTime:time];
																	   }
																	   if (weakSelf.hasCaptureCoverImage && weakSelf.coverImage) {
																		   return;
																	   }
																	   if (seconds >= weakSelf.coverTime) {
																		   [weakSelf.coverImageOperationQueue cancelAllOperations];
																		   [weakSelf.coverImageOperationQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
																			   if (!weakSelf) {
																				   return ;
																			   }
																			   weakSelf.hasCaptureCoverImage = YES;
																			   
																			   if (weakSelf.effectModel.isLongVideo) { //长视频没有生成视频，需要合成封面
																				   UIImage *image = [weakSelf.videoProcessor imageFromCurrentFrame];
																				   if (!image) {
																					   weakSelf.hasCaptureCoverImage = NO;
																					   return;
																				   }
																				   weakSelf.coverImage = image;
																				   if (weakSelf.effectModel.waterMarkLayer && weakSelf.coverImage) {
                                                                                       
                                                                                       CGSize size = weakSelf.effectModel.waterMarkLayer.bounds.size;
                                                                                       
                                                                                       CALayer *coverLayer = [CALayer layer];
                                                                                       coverLayer.frame = weakSelf.effectModel.waterMarkLayer.bounds;
                                                                                       for (CALayer *subLayer in weakSelf.effectModel.waterMarkLayer.sublayers) {
                                                                                           CGSize subSize = subLayer.frame.size;
                                                                                           UIImage *subImage =  [UIImage imageFromLayer:subLayer size:subSize];
                                                                                           CGRect subLayerFrame = subLayer.frame;
                                                                                           CALayer *layer = [CALayer layer];
                                                                                           subLayerFrame.origin.y = size.height - subLayerFrame.origin.y - subLayerFrame.size.height;
                                                                                           layer.frame = subLayerFrame;
                                                                                           layer.contents = (id)(subImage.CGImage);
                                                                                           [coverLayer addSublayer:layer];
                                                                                       }
                                                                                       
																					   UIImage *waterMarkImage = [UIImage imageFromLayer:coverLayer size:size];
																					   UIGraphicsBeginImageContextWithOptions(size, YES, 0);
																					   [weakSelf.coverImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
																					   [waterMarkImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
																					   weakSelf.coverImage = UIGraphicsGetImageFromCurrentImageContext();
																					   UIGraphicsEndImageContext();
																				   }
																			   }
																		   }]];
																	   }
																   }];
}

- (void)setPlayerSlider:(UISlider *)slider
{
    _playerSlider = slider;
    if (_playerSlider) {
        [_playerSlider addTarget:self action:@selector(onSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_playerSlider addTarget:self action:@selector(onSliderTouchUp:) forControlEvents:UIControlEventTouchUpInside];
		[_playerSlider addTarget:self action:@selector(onSliderTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [_playerSlider addTarget:self action:@selector(onSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    }
}

- (GPUImageView * )ginPreviewView
{
    return [self.videoProcessor ginPreviewView];
}


- (void)loadEffectModel:(MVVideoEffectPlayerModel *)model
			 completion:(void (^)(NSError *error))completionHandler
{
	//仅仅有长视频支持拖动~
	[self loadEffectModel:model supportSeek:/*model.isLongVideo*/ NO completion:completionHandler];
}

- (void)loadEffectModel:(MVVideoEffectPlayerModel *)model
			supportSeek:(BOOL)supportSeek
			 completion:(void (^)(NSError *error))completionHandler
{
	if (!model) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:10000
                                         userInfo:nil];
        if (completionHandler) {
            completionHandler(error);
        }
        return;
    }
	self.videoBitrate = model.videoBitrate;
    self.effectModel = model;
    self.hasCaptureCoverImage = NO;
    self.didProcessedFirstFrame = NO;
	self.coverImage = nil;
    self.coverTime = [self.effectModel.effectUserData mvDoubleValueForKey:@"covertime" defaultValue:0.05];
    self.asset = model.originAsset;
    if (!self.asset && model.originVideoPath) {
        
        self.asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:model.originVideoPath]];
    }
	
	self.videoProcessor.willNotificateWhenProcessEnd = YES;
    self.videoProcessor.willAppendLogo = NO;
	self.videoProcessor.supportSeek = supportSeek;
    __weak typeof(self) weakSelf = self;
    self.videoProcessor.didProcessedFirstFrameBlock = ^()
    {
        weakSelf.didProcessedFirstFrame = YES;
    };
    if ([self.asset tracksWithMediaType:AVMediaTypeVideo].count > 0) {
        AVAssetTrack *videoTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
        self.videoProcessor.outputVideoSize = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
    }
	
	if (!self.videoBitrate) {
		self.videoBitrate = self.effectModel.isLongVideo ? @(kMVVideoCommonConfigVideoLongVideoDefaultRate) : @(kMVVideoCommonConfigVideoRateHigh);
	}

    self.videoProcessor.combineAssets = model.combineAssets;
    [self.videoProcessor loadAsset:self.asset
                        effectData:self.effectModel.effectUserData
                          complete:^(AVAsset *videoAsset) {
                              if ([videoAsset isKindOfClass:[AVMutableComposition class]]) {
                                  AVMutableComposition *composition = (AVMutableComposition *)videoAsset;
                                  __weak typeof(self) weakSelf = self;

                                  [self.audioProcessor processAudio:composition
                                                       resourceData:self.effectModel
                                                           complete:^(AVMutableComposition *resultComposition, AVAudioMix *audioMix, NSError *error) {
                                                               MVVideoEffectPlayerV2 * strongSelf = weakSelf;
                                                               if (error) {
//                                                                   GERROR(LogModuleVideoEdit,@"Audio process error:%@",[error description]);
                                                                   if (completionHandler) {
                                                                       completionHandler(error);
                                                                   }
                                                                   return;
                                                               }
															   
															   strongSelf.currentPlayerItem = [AVPlayerItem playerItemWithAsset:resultComposition];
															   
                                                               strongSelf.currentPlayerItem.audioMix = audioMix;
                                                               [strongSelf.player replaceCurrentItemWithPlayerItem:strongSelf.currentPlayerItem];
//															   [strongSelf createPlayerWithPlayerItem:strongSelf.currentPlayerItem];

                                                               if ([weakSelf.delegate respondsToSelector:@selector(effectPlayer:playerItemDuration:)]) {
                                                                   [weakSelf.delegate effectPlayer:weakSelf playerItemDuration:weakSelf.currentPlayerItem.duration];
                                                               }

                                                               if (completionHandler) {
                                                                   completionHandler(nil);
                                                               }
                                                               
                                                           }];
                              }
                              
                          }];
}

- (void)setVideoBitrate:(NSNumber *)videoBitrate
{
	_videoBitrate = videoBitrate;
	self.videoProcessor.videoBitrate = videoBitrate;
}

- (void)startPlay
{
    self.videoProcessor.willExportToFile = NO;
	self.videoProcessor.playerItem = self.effectModel.isLongVideo ? self.currentPlayerItem : nil;
    [self.videoProcessor startProcess];
    self.playerSlider.value = self.playerSlider.minimumValue;
    [self.player play];
}

- (BOOL)isPlaying
{
	if (self.videoProcessor.isProcessing || self.player.rate != 0) {
		return YES;
	}
	
	return NO;
}

- (void)pausePlay
{
    [self.player pause];
    [self.videoProcessor setPaused:YES];
}

- (void)resumePlay
{
    [self.player play];
    [self.videoProcessor setPaused:NO];
}

- (void)cancelPlay
{
	[self.coverImageOperationQueue cancelAllOperations];
    [self.player pause];
    [self.videoProcessor cancelProcess];
}

- (void)removePlayerTimeObserver
{
	if (self.playerTimeObserver) {
		[self.player removeTimeObserver:self.playerTimeObserver];
		self.playerTimeObserver = nil;
	}
}

- (void)exportVideoCompletion:(MVVideoEffectVideoProcessCompletionBlock)completionHandler
{
    NSParameterAssert(self.effectModel.finalVideoPath);
    NSParameterAssert(self.effectModel.effectVideoPath);
    [self cancelPlay];
    self.videoProcessor.exportFilePath = self.effectModel.effectVideoPath;
    self.videoProcessor.willExportToFile = YES;
    self.videoProcessor.playerItem = nil;
    [self.videoProcessor startProcessWithLivePreview:NO];
    __weak typeof(self) weakSelf = self;
    [self.videoProcessor finishProcess:^(NSString *path, NSError *error) {
		if (error) {
			if (completionHandler) {
				completionHandler (nil,error);
			}
			return ;
		}
		
        __strong typeof(self) strongSelf = weakSelf;
//        GINFO(LogModuleVideoEdit,@"begin export video,video model is:%@",[strongSelf.effectModel description]);
        AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
        NSArray *videoTrakcs = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        if (videoTrakcs.count <= 0) {
//            GERROR(LogModuleVideoEdit,@"Effect video asset has no video track");
            return;
        }
        AVAssetTrack *videoTrack = videoTrakcs[0];
        
//        [strongSelf.audioProcessor processAudioWithResourceData:strongSelf.effectModel
//                                                  audioDuration:CMTimeGetSeconds(videoTrack.timeRange.duration) - 0.05 //fixbug:导出最后一帧为黑屏,音频数据过多
//                                                          error:nil];
        
        [strongSelf.audioProcessor processAudioWithResourceData:strongSelf.effectModel
                                                  audioDuration:CMTimeGetSeconds(videoTrack.timeRange.duration) - 0.05
                                                      timelines:[self effectTimeLines]
                                                          error:nil];
        
        MVAudioProcessorResult *audioProcessResult = [strongSelf.audioProcessor outputAudioResult];
        AVMutableComposition *composition = [strongSelf addVideo:videoAsset toAudioComposition:audioProcessResult.mutableComposition];
        AVMutableAudioMix *audioMix = audioProcessResult.mutableAudioMix;
        AVMutableVideoComposition *videoComposition = nil;
        if (strongSelf.effectModel.waterMarkLayer) {
            videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:composition];
            CALayer* watermarkLayer = strongSelf.effectModel.waterMarkLayer;
            CALayer *parentLayer = [CALayer layer];
            CALayer *videoLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, videoComposition.renderSize.width, videoComposition.renderSize.height);
            videoLayer.frame = parentLayer.bounds;
            watermarkLayer.frame = parentLayer.bounds;
            watermarkLayer.contentsGravity = kCAGravityBottom;
            [parentLayer addSublayer:videoLayer];
            [parentLayer addSublayer:watermarkLayer];
            videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
                                                                                                                                          inLayer:parentLayer];
        }
        SDAVAssetExportSession *exportSession = [SDAVAssetExportSession exportSessionWithAsset:composition];
        exportSession.audioMix = audioMix;
        exportSession.videoComposition = videoComposition;
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.outputURL = [NSURL fileURLWithPath:strongSelf.effectModel.finalVideoPath];
		[[NSFileManager defaultManager]removeItemAtURL:exportSession.outputURL error:nil];//清理上次导出的视频
        exportSession.pixelFormatType = @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange);
        double preferredHardwareSampleRate = [[AVAudioSession sharedInstance] sampleRate];
        AudioChannelLayout acl;
        bzero( &acl, sizeof(acl));
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        exportSession.sdAudioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                       [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
                                       [ NSNumber numberWithFloat: preferredHardwareSampleRate ], AVSampleRateKey,
                                       [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
                                       [ NSNumber numberWithInt: 64000 ], AVEncoderBitRateKey,
                                       nil];

        NSMutableDictionary *videoCompressionSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         AVVideoCodecH264, AVVideoCodecKey,
                                                         [NSNumber numberWithInteger:videoTrack.naturalSize.width], AVVideoWidthKey,
                                                         [NSNumber numberWithInteger:videoTrack.naturalSize.height], AVVideoHeightKey,
                                                         [NSMutableDictionary dictionaryWithObjectsAndKeys:
														  self.videoBitrate, AVVideoAverageBitRateKey,
                                                          AVVideoProfileLevelH264Main31,AVVideoProfileLevelKey,
                                                          nil], AVVideoCompressionPropertiesKey,
                                                         AVVideoScalingModeResizeAspectFill,AVVideoScalingModeKey,
                                                         nil];
        exportSession.videoSettings = videoCompressionSettings;
//        GINFO(LogModuleVideoEdit,@"Begin exporting video");
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
//            GINFO(LogModuleVideoEdit,@"End exporting video");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (exportSession.status == AVAssetExportSessionStatusCompleted) {
//                    GINFO(LogModuleVideoEdit,@"Exporiting video success");
                    if (completionHandler) {
                        completionHandler (strongSelf.effectModel.finalVideoPath,error);
                    }
                }else{
//                    GERROR(LogModuleVideoEdit,@"Exporting composition:%@ fail:%@",composition,exportSession.error);
                    if (completionHandler) {
                        completionHandler (nil,exportSession.error);
                    }
                }
            });
        }];

    }];
}

- (void)seekToTime:(CMTime)time
{
    if (CMTIME_IS_INVALID(time)) {
        return;
    }
	if (CMTimeGetSeconds(time) < self.coverTime) {
		self.hasCaptureCoverImage = NO;
	}
    self.hasCaptureCoverImage = NO;
    [self.player seekToTime:time];
}

- (void)settingWaterMarkLayer:(CALayer *)waterMarkLayer
{
    self.effectModel.waterMarkLayer = waterMarkLayer;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"progress"]) {
        self.progress = self.videoProcessor.progress;
//        NSLog(@"Processing video progress:%f",self.progress);
    }
}

#pragma mark - Private Method

- (AVMutableComposition *)addVideo:(AVAsset *)videoAsset toAudioComposition:(AVMutableComposition *)audioComposition
{
    AVMutableComposition *composition = nil;
    NSArray *videoTrakcs = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTrakcs.count <= 0) {
//        GERROR(LogModuleVideoEdit,@"Cache video doesn't have video track,video asset:%@",videoAsset);
        return nil;
    }
    AVAssetTrack *videoTrack = videoTrakcs[0];
    composition = [audioComposition mutableCopy];
    if (!composition) {
        composition = [AVMutableComposition composition];
    }
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSError *error;
    if (![videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:&error]) {
//        GERROR(LogModuleVideoEdit,@"Insert cache video track to composition error:%@",error);
        return nil;
    }
    return composition;
}

- (void)handleAVPlayerItemDidPlayToEndTimeNotification:(NSNotification *)notification
{
    if (self.currentPlayerItem == notification.object && self.effectModel.isLongVideo) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMVVideoEffectPlayerPlayVideoEndNotification object:nil];
    }
}

- (void)onSliderTouchDown:(UISlider*)slider
{
    self.playerPlaying = [self isPlaying];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSliderTounchDownNotification object:nil];
    [self.player pause];
}

- (void)onSliderTouchUp:(UISlider*)slider
{
    if (self.playerPlaying) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSliderTounchUpNotification object:nil];
        [self.player play];
    }
}

- (void)onSliderValueChange:(UISlider*)slider
{
    CMTime playerDuration = self.player.currentItem.duration;
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [slider minimumValue];
        float maxValue = [slider maximumValue];
        float value = [slider value];
        double time = duration * (value - minValue) / (maxValue - minValue);
        double tolerance = 1.0f * duration / slider.bounds.size.width;
        [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)
            toleranceBefore:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)
             toleranceAfter:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)
          completionHandler:^(BOOL finished) {
              
          }];
        if ([self.delegate respondsToSelector:@selector(effectPlayer:didPlayAtTime:)]) {
            [self.delegate effectPlayer:self didPlayAtTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
        }
    }
}

- (BOOL)isProcessingCompleted;
{
    return self.videoProcessor.isProcessingCompleted;
}

- (NSArray *)effectTimeLines
{
    return [self.videoProcessor effectTimeLines];
}


@end
