//
//  MVVideoEffectVideoProcessor.m
//  SimpleVideoFileFilter
//
//  Created by eson on 14-9-2.
//  Copyright (c) 2014年 Cell Phone. All rights reserved.
//

#import "MVVideoEffectVideoProcessor.h"
#import "GPUImage.h"
#import "MVVideoEffectParser.h"
#import "MVVideoEffect.h"
#import "MVVideoEffectFilterExcutor.h"
#import "GPUImageMovieComposition.h"
#import "MVAssetReaderWraper.h"
#import <libkern/OSAtomic.h>
#import "NSString+Util.h"
#import "MVVideoCommonConfig.h"
#import "NSDictionary+Util.h"
#import "MVVideoLightingFilter.h"
#import "AVAsset+Util.h"

//#import "FBTweakInline.h"

static const NSInteger kMVVideoEffectVideoProcessorCachingObjectsMaxCount = 3;

@interface MVVideoEffectVideoProcessor () <GPUImageMovieDelegate,GPUImageMovieWriterDelegate>

@property (nonatomic, strong) GPUImageFilter * terminalFilter;
@property (nonatomic, strong) GPUImageFilter * initialFilter;
@property (nonatomic, strong) GPUImageMovie * movieFile;
@property (nonatomic, strong) AVAsset * compositeAsset;
@property (nonatomic, strong) GPUImageMovieWriter * movieWriter;
@property (nonatomic, strong) NSURL *movieOutputURL;
@property (nonatomic, strong) MVVideoEffectParser * effectParser;
@property (nonatomic, strong) MVVideoEffectParser *logoEffectParser;
@property (nonatomic, strong) NSMutableDictionary * readerWraperDictionary;
@property (nonatomic, strong) NSMutableDictionary * filterExcutorDictionary;
@property (nonatomic, strong) NSMutableArray *effectFilters;
@property (nonatomic, strong) NSMutableArray *blendPictures;

@property (nonatomic, assign) CFTimeInterval lastProcessedSampleTime;
@property (nonatomic, assign) CFTimeInterval currentSampleTime;
@property (nonatomic, assign) CMTime currentSampleCMTime;

@property (nonatomic, assign) CVPixelBufferRef lastPixelBuffer;
@property (nonatomic, assign) CMTime lastSampleCMTime;

@property (nonatomic, copy) MVVideoEffectVideoProcessCompletionBlock completionHandler;
@property (nonatomic, strong, readwrite) AVAsset      *asset;
@property (nonatomic, strong, readwrite) NSDictionary *effectData;
@property (nonatomic, strong) NSMutableArray * invalidatePicturesCache;
@property (nonatomic, strong) NSMutableArray * invalidateMovieFileCache;
@property (nonatomic, strong) UIImage *lastFrameImage;
@property (nonatomic, strong) UIImage *lastFrameBlurImage;
@property (nonatomic, strong) GPUImagePicture *lastFramePicture;
@property (nonatomic, assign) NSTimeInterval logoDuration;
@property (nonatomic, assign) BOOL isEnterLogoStage;
@property (nonatomic, strong) NSOperationQueue *blueImageOperationQueue;

@end

@implementation MVVideoEffectVideoProcessor
@synthesize compositionAssetDuration = _compositionAssetDuration;

- (void)dealloc
{

	[self releaseLastSampleBuffer];
	if (self.isProcessing) {
		[self cancelProcess];
	}
	for (MVAssetReaderWraper *reader in self.readerWraperDictionary.allValues) {
		[reader cancelProcess];
	}
	[GPUImageContext releaseSharedMovieWriterContext];
	[[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
}

- (instancetype)init
{
	if (self = [super init]) {
		self.blueImageOperationQueue = [[NSOperationQueue alloc]init];
		self.blueImageOperationQueue.maxConcurrentOperationCount = 1; //serial queue

		self.readerWraperDictionary = [NSMutableDictionary dictionary];
		self.filterExcutorDictionary = [NSMutableDictionary dictionary];
		self.effectFilters = [NSMutableArray array];
		self.blendPictures = [NSMutableArray array];
		self.invalidatePicturesCache = [NSMutableArray array];
		self.invalidateMovieFileCache = [NSMutableArray array];
		
		CGRect screenFrame  = [UIScreen mainScreen].bounds;
		_ginPreviewView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.width)];
        _ginPreviewView.fillMode = kGPUImageFillModePreserveAspectRatio;
		self.willExportToFile = YES;
		self.outputVideoSize = CGSizeMake(480, 480);
	}
	
	return self;
}

#pragma mark - Public

- (void)loadAsset:(AVAsset *)asset effectData:(NSDictionary *)effectData
{
	self.asset = asset;
	self.effectData = effectData;
	self.effectParser = [[MVVideoEffectParser alloc]init];
	[self parseEffectData:effectData];

    [self insertStaticEffects];
    if (self.willAppendLogo) {
        [self appendLogoEffectsIfNeed];
    }

	self.compositeAsset = [self compositeOriginVideoTracks:self.asset];
}

- (void)loadAsset:(AVAsset *)asset effectData:(NSDictionary *)effectData complete:(void (^)(AVAsset *videoAsset))completionHandler
{
    [self loadAsset:asset effectData:effectData];
    if (completionHandler) {
        completionHandler(self.compositeAsset);
    }
}

- (BOOL)startProcess
{
	return [self startProcessWithLivePreview:YES];
}

- (BOOL)startProcessWithLivePreview:(BOOL)livePreview
{
    runSynchronouslyOnVideoProcessingQueue(^{

        if (self.isProcessing) {
            [self cancelProcess];
        }
        if (self.movieFile) {
            if (self.invalidateMovieFileCache.count > kMVVideoEffectVideoProcessorCachingObjectsMaxCount) {
                [self.invalidateMovieFileCache removeLastObject];
            }
            [self.invalidateMovieFileCache insertObject:self.movieFile atIndex:0];
        }
        if (self.playerItem) {
            self.movieFile = [[GPUImageMovie alloc] initWithPlayerItem:self.playerItem];
        } else {
            self.movieFile = [[GPUImageMovie alloc]initWithAsset:self.compositeAsset];
        }
        self.movieFile.playAtActualSpeed = livePreview;
        self.movieFile.shouldDropFrame = YES;//保证播放的时候时序ok，丢帧，导出的时候不要丢帧
        self.movieFile.delegate = self;
		self.progress = 0;

        if (self.asset && self.movieFile) {
			_isProcessing = YES;
            self.lastProcessedSampleTime = 0;
            self.currentSampleTime = 0;

            self.initialFilter = [[GPUImageFilter alloc]init];
            self.terminalFilter = [[GPUImageFilter alloc]init];
            
            [self.movieFile addInputTarget:self.initialFilter];
            [self.initialFilter addInputTarget:self.terminalFilter];
            if (livePreview) {
                [self.terminalFilter addInputTarget:self.ginPreviewView];
            }

			[self createAndAddTargetToMovieWriterIfNeed];
			
			[self.movieWriter startRecording];
			[self.movieFile startProcessing];
		}
	});
	
	return self.isProcessing;
}

- (void)setPaused:(BOOL)paused
{
	_paused = paused;
	runSynchronouslyOnVideoProcessingQueue(^{
		_isProcessing = !paused;
		self.movieWriter.paused = paused;
        self.movieFile.paused = paused;
	});
}

- (void)cancelProcess;
{
	runSynchronouslyOnVideoProcessingQueue(^{

		_isProcessing = NO;
		[self.blueImageOperationQueue cancelAllOperations];
		self.movieWriter.paused = YES;
		self.movieFile.delegate = nil;
		[self releaseLastSampleBuffer];
		
		[self destoryFiltersChain];
		self.lastFrameBlurImage = nil;
		self.lastFrameImage = nil;
		self.isEnterLogoStage = NO;
		self.initialFilter = nil;
		self.terminalFilter = nil;

		[self.movieWriter cancelRecording];

		if ([self.movieFile.assetReader status] == AVAssetReaderStatusReading) {
			[self.movieFile cancelProcessing];
		} else {
			[self.movieFile endProcessing];
		}
        self.movieFile.paused = NO;
		
		[self.effectParser.normalVideoEffects enumerateObjectsUsingBlock:^(MVVideoEffect * effect, NSUInteger idx, BOOL *stop) {
			[self removeReaderWraperForEffect:effect];
		}];

		[self.filterExcutorDictionary removeAllObjects];
		if (![self isProcessingCompleted]) {
			[self deleteVideoEffectFile];
		}
		self.movieWriter = nil;
		self.completionHandler = nil;
	});
}

- (void)finishProcess:(MVVideoEffectVideoProcessCompletionBlock)completionHandler
{
	runAsynchronouslyOnVideoProcessingQueue(^{
		self.completionHandler = completionHandler;
        self.movieFile.playAtActualSpeed = NO;
		self.movieFile.shouldDropFrame = NO;//no need drop frame
        [self.terminalFilter removeTarget:self.ginPreviewView];
        [self notificationIfCompletion];
	});
}

- (UIImage *)imageFromCurrentFrame
{
	[self.terminalFilter useNextFrameForImageCapture];
	UIImage *image = [self.terminalFilter imageFromCurrentFramebuffer];
	return image;
}

- (CFTimeInterval)compositionAssetDuration
{
	_compositionAssetDuration = CMTimeGetSeconds(self.compositeAsset.duration);
	return _compositionAssetDuration;
}

- (float)progress
{
	float  progress = _progress;
	return progress;
}

- (BOOL)isProcessingCompleted
{
    if (self.playerItem) {
        double time = self.currentSampleTime - [self compositionAssetDuration];
        return (abs(time) <= 0.1);
    }
	return self.progress >= 0.98;
}

- (NSArray *)effectTimeLines
{
    NSMutableArray *timelines = [NSMutableArray array];
    for (MVVideoEffect *effect in self.effectParser.timelineVideoEffects) {
        
        NSNumber *start = @(effect.start);
        NSNumber *duration = @(effect.duration);
        NSNumber *speed = @(effect.speed);
        NSNumber *isStaticfFrame = @(effect.isStaticFrame);
        
        NSDictionary *info = @{@"start":start, @"duration":duration, @"staticframe":isStaticfFrame, @"speed":speed};
        
        [timelines addObject:info];
    }
    
    return (([timelines count] > 0) ? timelines : nil);
}

- (void)insertStaticEffects{
    NSString *logoStageFileName = @"static_effects";
    NSString *logoStageConfigPath = [[NSBundle mainBundle] pathForResource:logoStageFileName ofType:@"json"];
    NSError *error;
    NSString *stageConfigString = [NSString stringWithContentsOfFile:logoStageConfigPath encoding:NSUTF8StringEncoding error:&error];
    NSData *stageConfigStringData = [stageConfigString dataUsingEncoding:NSUTF8StringEncoding];
    if (stageConfigStringData) {
        NSDictionary *logoStageConfigDictinary = [NSJSONSerialization JSONObjectWithData:stageConfigStringData options:0 error:&error];
        if (!error && logoStageConfigDictinary.count > 0) {
            MVVideoEffectParser *logoEffectParser = [[MVVideoEffectParser alloc]init];
            [logoEffectParser parseEffectWithConfigUserData:logoStageConfigDictinary
                                        originVideoDuration:CMTimeGetSeconds(self.asset.duration)];
            self.effectParser = logoEffectParser;
        }
    }
}

#pragma mark - Logo
- (void)appendLogoEffectsIfNeed
{
	BOOL hasConfigLogoTime = NO;
	NSTimeInterval logoStaticFrameDuration = 0;
	NSDictionary *filterData = [self.effectData mvDictionaryValueForKey:kMVVideoEffectParserKeyFilterData];
	if ([filterData objectForKey:kMVVideoEffectParserKeyLogoTime]) { //服务器协议自己配置了末尾logo_time 插入一个定帧stage
		hasConfigLogoTime = YES;
		logoStaticFrameDuration = [filterData mvFloatValueForKey:kMVVideoEffectParserKeyLogoTime];
	}
	BOOL isSquareVideo = self.outputVideoSize.width == self.outputVideoSize.height;
	NSString *logoStageFileName = isSquareVideo ? @"logo_stage" : @"logo_long_video_stage";
	NSString *logoStageConfigPath = [[NSBundle mainBundle] pathForResource:hasConfigLogoTime ? @"logo_static_frame_stage" : logoStageFileName
																	ofType:@"json"];
	NSError *error;
	NSString *stageConfigString = [NSString stringWithContentsOfFile:logoStageConfigPath encoding:NSUTF8StringEncoding error:&error];
	NSData *stageConfigStringData = [stageConfigString dataUsingEncoding:NSUTF8StringEncoding];
	if (stageConfigStringData) {
		NSDictionary *logoStageConfigDictinary = [NSJSONSerialization JSONObjectWithData:stageConfigStringData options:0 error:&error];
		if (!error && logoStageConfigDictinary.count > 0) {
			MVVideoEffectParser *logoEffectParser = [[MVVideoEffectParser alloc]init];
			[logoEffectParser parseEffectWithConfigUserData:logoStageConfigDictinary
										originVideoDuration:CMTimeGetSeconds(self.asset.duration)];

			[logoEffectParser.timelineVideoEffects enumerateObjectsUsingBlock:^(MVVideoEffect * effect, NSUInteger idx, BOOL *stop) {
				if (hasConfigLogoTime) {
					effect.duration = logoStaticFrameDuration;
				}
			}];
			MVVideoEffect *logoLastEffect = logoEffectParser.timelineVideoEffects.lastObject;
			logoLastEffect.isLogoStage = YES;

			self.logoDuration = [(MVVideoEffect *)logoEffectParser.timelineVideoEffects.lastObject caculatedVideoDuration];
			NSTimeInterval normalDuration = self.effectParser.compositionDuration;
			NSTimeInterval fixAllDuration = normalDuration + self.logoDuration;
			
			[logoEffectParser.normalVideoEffects enumerateObjectsUsingBlock:^(MVVideoEffect * effect, NSUInteger idx, BOOL *stop) {
				effect.start = fixAllDuration - MIN(self.logoDuration, effect.caculatedVideoDuration);
				effect.duration = effect.duration + 0.1; //fixbug:组合之后compositionAssetDuration > fixAllDuration 导致末尾一帧没有logo
				effect.isLogoStage = YES;
			}];

			if (self.effectParser.timelineVideoEffects.count == 0 && logoEffectParser.timelineVideoEffects > 0) {
				MVVideoEffect *logoFirstStageEffect = logoEffectParser.timelineVideoEffects.firstObject;
				logoFirstStageEffect.duration = CMTimeGetSeconds(self.asset.duration);//无配置，以原始视频作为抽帧长度
				[self.effectParser.timelineVideoEffects addObjectsFromArray:logoEffectParser.timelineVideoEffects];//抽帧+末尾定帧
			} else if (logoEffectParser.timelineVideoEffects.lastObject) {
				[self.effectParser.timelineVideoEffects addObject:logoEffectParser.timelineVideoEffects.lastObject];//末尾定帧stage
			}
			self.effectParser.compositionDuration = fixAllDuration;
			
			if (logoEffectParser.normalVideoEffects.count > 0) {
				[self.effectParser.normalVideoEffects addObjectsFromArray:logoEffectParser.normalVideoEffects];
			}

			if (!hasConfigLogoTime) {
				self.logoEffectParser = logoEffectParser;
			}
		}
	}
}

#pragma mark - GPUImageMovieWriterDelegate

- (void)movieRecordingFailedWithError:(NSError*)error
{
	if (self.completionHandler) {
		self.completionHandler (nil,error);
	}
	[self cancelProcess];
	self.completionHandler = nil;
}

#pragma mark - GPUImageMovieDelegate

- (void)didCompletePlayingMovie
{
	[self.movieWriter finishRecording];
	self.movieWriter = nil;
	if (self.movieFile) {
		self.progress = self.movieFile.progress;
	}
	[self notificationIfCompletion];
    if (self.willNotificateWhenProcessEnd) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMVVideoEffectPlayerPlayVideoEndNotification object:nil];
    }
    [self cancelProcess];
	
	if (self.movieOutputURL) {
		AVAsset *asset = [AVAsset assetWithURL:self.movieOutputURL];
		NSLog(@"video processor completion movieOutputURL %@ duration %f",self.movieOutputURL,CMTimeGetSeconds(asset.duration));
	}
}

- (void)customProcessMovieFrame:(CVPixelBufferRef)movieFramePixelBuffer withSampleTime:(CMTime)movieFramePixelBufferCMTime
{
	if (!movieFramePixelBuffer) {
		return;
	}
    self.progress = self.movieFile.progress;
	typeof(self) __weak weakSelf = self;
	
	runSynchronouslyOnVideoProcessingQueue(^{
		@autoreleasepool {
			if (!weakSelf || !movieFramePixelBuffer) { //暂停的时候支持seek,需要处理
				return;
			}
			
			CFRetain(movieFramePixelBuffer);
			
			__block CMTime currentSampleCMTime = movieFramePixelBufferCMTime;
			CFTimeInterval currentSampleTime = CMTimeGetSeconds(currentSampleCMTime);
			CVPixelBufferRef moviePixelBuffer = movieFramePixelBuffer;
		
			weakSelf.currentSampleTime = currentSampleTime;
			weakSelf.currentSampleCMTime = currentSampleCMTime;

			__block BOOL isStaticFrame = NO;
			__block CFTimeInterval totalDuration = 0;
			
			[[weakSelf.effectParser timelineVideoEffects]enumerateObjectsUsingBlock:^(MVVideoEffect * e, NSUInteger idx, BOOL *stop) {
				if (e.isStaticFrame && totalDuration <= currentSampleTime && totalDuration + e.caculatedVideoDuration >= currentSampleTime) {
					isStaticFrame = YES;//定帧
				}
				totalDuration += e.caculatedVideoDuration;
			}];
			
			NSArray * validEffects = [weakSelf validEffectsForCurrentSampleTime];
			[weakSelf createFiltersChainWithEffects:validEffects];
			
			if (isStaticFrame && weakSelf.lastPixelBuffer) { //Using lastSampleBuffer
				CFRelease(moviePixelBuffer);

				moviePixelBuffer = weakSelf.lastPixelBuffer;
			} else {
				[weakSelf releaseLastSampleBuffer];
			}
			
			weakSelf.lastPixelBuffer = moviePixelBuffer;
			weakSelf.lastSampleCMTime = currentSampleCMTime;

			NSTimeInterval approchEndTime = weakSelf.logoEffectParser ? weakSelf.logoDuration + 0.35 : 0.1;
			if (weakSelf.effectParser.compositionDuration - weakSelf.currentSampleTime < approchEndTime && !weakSelf.isEnterLogoStage) {
				[[weakSelf blueImageOperationQueue] cancelAllOperations];
				[weakSelf.blueImageOperationQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
					if (!weakSelf || !weakSelf.isProcessing) {
						return;
					}
					UIImage *lastFrameImage = [weakSelf imageFromCurrentFrame];
					if (lastFrameImage && !weakSelf.isEnterLogoStage) {
						weakSelf.lastFrameImage = lastFrameImage;
						if (weakSelf.logoEffectParser) { //logo 模糊帧
							weakSelf.lastFrameBlurImage = [weakSelf processBlurFilter:weakSelf.lastFrameImage];
						}
					}
				}]];
			}
			
			if ((weakSelf.lastProcessedSampleTime == 0 || (fabs(currentSampleTime - weakSelf.lastProcessedSampleTime) >= kMVVideoEffectProcessingBufferMinGapTime))
				&& ![weakSelf forceDropLastFrameForBeautyFilter]) {
				
//				NSLog(@"shouldCustomProcessMovieFrame currentSampleTime %f videoLength:%f",currentSampleTime,[weakSelf compositionAssetDuration]);

				[weakSelf.movieFile processMovieFrame:moviePixelBuffer withSampleTime:currentSampleCMTime];
				weakSelf.lastProcessedSampleTime = currentSampleTime;
				
				[weakSelf.lastFramePicture processImage]; //最后定帧logo图片输出
			}
			if (weakSelf.didProcessedFirstFrameBlock) {
				weakSelf.didProcessedFirstFrameBlock();
				weakSelf.didProcessedFirstFrameBlock = nil;
			}
		}
	});
}

- (BOOL)forceDropLastFrameForBeautyFilter
{
    return (self.currentSampleTime  + 0.1 >= self.compositionAssetDuration) && self.isProcessForBeauty;
}

#pragma mark - Private

- (void)releaseLastSampleBuffer
{
	if (self.lastPixelBuffer) {
		CFRelease(self.lastPixelBuffer);
		self.lastPixelBuffer = NULL;
	}
}

- (void)removeReaderWraperForEffect:(MVVideoEffect *)effect
{
	MVAssetReaderWraper *reader = [self readerWraperForEffect:effect needCreateReader:NO];
	if (reader) {
		[reader cancelProcess];
		[self.readerWraperDictionary removeObjectForKey:[self keyForReaderWraperAssociatToEffect:effect]];
	}
}

- (MVAssetReaderWraper *)readerWraperForEffect:(MVVideoEffect *)effect needCreateReader:(BOOL)needCreateReader
{
	return [self readerWraperForEffect:effect needCreateReader:needCreateReader createReaderCompletionBlock:nil];
}

- (MVAssetReaderWraper *)readerWraperForEffect:(MVVideoEffect *)effect
							  needCreateReader:(BOOL)needCreateReader
				   createReaderCompletionBlock:(void (^)(MVAssetReaderWraper * reader))createReaderCompletionBlock
{
    NSString            *videoPath = [NSString getResourcePathIfExistWithURL:effect.videoURLString];
    NSString            *keyForReader = [self keyForReaderWraperAssociatToEffect:effect];
    MVAssetReaderWraper *reader = self.readerWraperDictionary[keyForReader];
    BOOL                isMaterialVideoValid = (effect.isMaterialVideoReferSelf && self.asset) ||
        (videoPath.length > 0 && keyForReader.length > 0);

    if (isMaterialVideoValid && !reader && needCreateReader) {

		if (effect.isMaterialVideoReferSelf) {
			reader = [[MVAssetReaderWraper alloc]initWithAsset:self.asset];
		} else {
			AVAsset *materialVideoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
			materialVideoAsset = [self compositeMaterialVideo:materialVideoAsset toDuration:effect.caculatedVideoDuration];
			reader = [[MVAssetReaderWraper alloc]initWithAsset:materialVideoAsset];
		}

		reader.readerStartTime = effect.materialVideoStart; // 设置素材读取起始时间

		if (createReaderCompletionBlock) {
			createReaderCompletionBlock (reader);
		}
        self.readerWraperDictionary[keyForReader] = reader;
        [reader startProcess];
    }

    return reader;
}

- (MVVideoEffectFilterExcutor *)createFilterExcutorIfNeedForEffect:(MVVideoEffect *)effect
{
	NSString *keyForFilterExcutor = [self keyForFilterExcutorAssociatToEffect:effect];
	MVVideoEffectFilterExcutor *filterExcutor = self.filterExcutorDictionary[keyForFilterExcutor];
	if (!filterExcutor) {
		filterExcutor = [MVVideoEffectFilterExcutor createFilterExcutorWithAnimationPath:effect.animationPath
																			filterConfig:effect.filterConfig
																				filterId:effect.filterId
                                                                        excutorStartTime:effect.start
                                                                                videoURL:effect.videoURLString];
		if (filterExcutor) {
			self.filterExcutorDictionary[keyForFilterExcutor] = filterExcutor;
		}
	}
	return filterExcutor;
}

- (void)createAndAddTargetToMovieWriterIfNeed
{
	if (self.willExportToFile) {
		if (!self.exportFilePath) {
			self.exportFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.mp4"];
		}
		unlink([self.exportFilePath UTF8String]);
		self.movieOutputURL = [NSURL fileURLWithPath:self.exportFilePath];
		
		
		NSMutableDictionary *videoCompressionSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
														 AVVideoCodecH264, AVVideoCodecKey,
														 [NSNumber numberWithInteger:self.outputVideoSize.width], AVVideoWidthKey,
														 [NSNumber numberWithInteger:self.outputVideoSize.height], AVVideoHeightKey,
														 [NSMutableDictionary dictionaryWithObjectsAndKeys:
														  self.videoBitrate ?: @(kMVVideoCommonConfigShootVideoRate), AVVideoAverageBitRateKey,
														  AVVideoProfileLevelH264Main31,AVVideoProfileLevelKey,
														  nil], AVVideoCompressionPropertiesKey,
														 AVVideoScalingModeResizeAspectFill,AVVideoScalingModeKey,
														 nil];
		self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieOutputURL
																	size:self.outputVideoSize
																fileType:AVFileTypeQuickTimeMovie //fixbug:出现写入失败等问题,请使用该格式较稳定
														  outputSettings:videoCompressionSettings];
		self.movieWriter.delegate = self;
		[self.terminalFilter addInputTarget:self.movieWriter];
		[self.movieFile enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
	}
}

- (NSArray *)validEffectsForCurrentSampleTime
{
	NSArray * normalVideoEffects  = [[self.effectParser normalVideoEffects] copy];
	NSMutableArray * validEffects = [NSMutableArray array];
	NSMutableArray * logoValidEffects = [NSMutableArray array];

	self.isEnterLogoStage = NO;
	[normalVideoEffects enumerateObjectsUsingBlock:^(MVVideoEffect * effect, NSUInteger idx, BOOL *stop) {
		if ([effect isValidForTime:self.currentSampleTime] && effect.filterId != kMVVideoEffectTimeLineFilterID) {
			[validEffects addObject:effect];
			self.isEnterLogoStage = effect.isLogoStage;
			if (self.isEnterLogoStage) {
				[logoValidEffects addObject:effect];
			}
//			GINFO(LogModuleVideoEdit,@"validEffects stagId %d filterId %d",effect.stageId,effect.filterId);
		} else {
			[self removeReaderWraperForEffect:effect];
		}
	}];
	
	if (self.isEnterLogoStage && self.lastFrameBlurImage) {
		validEffects = logoValidEffects; //最后一个模糊帧已生成，干掉其他多余的滤镜
	}

	return validEffects;
}

- (void)notificationIfCompletion
{
    if ([self isProcessingCompleted]) { //fixbug:有时候进度大于0.99 也为完成
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler(self.exportFilePath,nil);
                self.completionHandler = nil;
            }
        });
    }
}

#pragma mark - Filter Chain

- (void)createFiltersChainWithEffects:(NSArray *)validEffects
{
	[self destoryFiltersChain];
	
	[self.movieFile addInputTarget:self.initialFilter];
	
	GPUImageOutput<GPUImageInput> *filter;
	NSMutableArray *blendFilters = [NSMutableArray array];
	NSMutableArray *blendPictures = [NSMutableArray array];
	NSMutableArray *fiterInputEffects = [NSMutableArray array];
	NSMutableDictionary *filterOfStageIDMap = [NSMutableDictionary dictionary];
	CFTimeInterval currentSampleTime = self.currentSampleTime;
	
	for (MVVideoEffect *effect in validEffects) {
		MVVideoEffectFilterExcutor *filterExcutor = [self createFilterExcutorIfNeedForEffect:effect];
		filter = [filterExcutor getFilter];
		[filterExcutor updateExcutorTime:currentSampleTime];

		if (effect.filterId == kMVVideoEffectCombineMovieFilterID
            || effect.filterId == kMVVideoEffectCombineDirectingMovieFilterID
			|| (effect.filterId == kMVVideoEffectCombineLightingMovieFilterID && (effect.videoURLString || effect.isMaterialVideoReferSelf))
            || [self isPartialFilter:effect]){
			GPUImagePicture     *picture;
			
			if ([effect isValidForTime:currentSampleTime]) {
				MVAssetReaderWraper *reader = [self readerWraperForEffect:effect needCreateReader:YES];

				CGImageRef imageRef = [reader copySampleCGImageRefAtTime:currentSampleTime - effect.start + effect.materialVideoStart];
				if (imageRef) {
					picture = [[GPUImagePicture alloc]initWithCGImage:imageRef];
					CGImageRelease(imageRef);
				}
			}
			
			if (effect.inputStageIDs.count <= 1) { //if blending picture with previous filter, picture must exist
				filter = picture ? filter : nil;
			}
			
			if (picture && filter) {
				[blendPictures addObject:picture];
				[blendFilters addObject:filter];
			} else {
				NSLog(@" currentSampleTime %f !!!filter need a blend image not satisfy %@",currentSampleTime,effect);
			}
		}
		
		if (filter) {
			[filterOfStageIDMap setObject:filter forKey:@(effect.stageId)];
			[fiterInputEffects addObject:effect];
			[self.effectFilters addObject:filter];
		}
	}
	
	//chain all filters
	id prevFilter = self.initialFilter;
	GPUImagePicture     *lastFramePicture;
	if (self.isEnterLogoStage && self.lastFrameImage) {  //logo动画以最后一帧作为输入
		if (!self.lastFrameBlurImage) {
			self.lastFrameBlurImage = [self processBlurFilter:self.lastFrameImage];
		}
		lastFramePicture = [[GPUImagePicture alloc]initWithImage:self.lastFrameBlurImage];
		lastFramePicture.pictureFrameTime = self.currentSampleCMTime;
		prevFilter = lastFramePicture;
	}
	self.lastFramePicture = lastFramePicture;

	GPUImageOutput<GPUImageInput> *targetFilter = nil;
	for (MVVideoEffect *e in fiterInputEffects) {
		targetFilter = filterOfStageIDMap[@(e.stageId)];
		if (e.inputStageIDs.count == 0 //blending two filters, need to add default previous filter as input
			|| (e.filterId == kMVVideoEffectCombineMovieFilterID && e.inputStageIDs.count == 1 && ![blendFilters containsObject:targetFilter]))
		{
			[prevFilter removeAllTargets];//using previous filter input
			[prevFilter addInputTarget:targetFilter];
		}
		for (NSNumber * stageID in e.inputStageIDs) {//using special filter input
			GPUImageOutput<GPUImageInput> * inputFilter = filterOfStageIDMap[stageID];
			if (inputFilter && targetFilter) {
				[inputFilter addInputTarget:targetFilter];
			}
		}
		prevFilter = targetFilter;
	}
	[prevFilter removeAllTargets];
	if (self.terminalFilter) {
		[prevFilter addInputTarget:self.terminalFilter];
	}
	
	//add picture blend
	[blendPictures enumerateObjectsUsingBlock:^(GPUImagePicture *picture, NSUInteger idx, BOOL *stop) {
		GPUImageFilter *filter = blendFilters[idx];

		[picture removeAllTargets];
		if ([filter isKindOfClass:[MVVideoLightingFilter class]]) { //光源调节滤镜，配置了视频叠加素材，则不叠加原始输入
			[(MVVideoLightingFilter *)filter replaceCurrentCombineWithSource:picture];
		} else {
			[picture addInputTarget:filter];
		}
		[picture processImage];
	}];
	
	[self.blendPictures addObjectsFromArray:blendPictures]; // 要hold住 GPUImagePicture
	
	if (lastFramePicture) {
		[self.blendPictures addObject:lastFramePicture];
	}
}

- (void)destoryFiltersChain
{
	runSynchronouslyOnVideoProcessingQueue(^{
		[self.movieFile removeAllTargets];
		[self.initialFilter removeAllTargets];
		
		for (GPUImageFilter *filter in self.effectFilters) {
			[filter removeAllTargets];
		}
		[self.effectFilters removeAllObjects];
		
		if (self.invalidatePicturesCache.count > kMVVideoEffectVideoProcessorCachingObjectsMaxCount) {
			[self.invalidatePicturesCache removeLastObject];
		}
        if (self.blendPictures) {
            [self.invalidatePicturesCache insertObject:@[self.blendPictures] atIndex:0];
        }
		[self.blendPictures removeAllObjects];
	});
}

#pragma mark - Helper

- (NSString *)keyForReaderWraperAssociatToEffect:(MVVideoEffect *)effect
{
	NSString *keyReaderWraper;
	if (effect.videoURLString.length > 0 || effect.isMaterialVideoReferSelf) {
		keyReaderWraper = [NSString stringWithFormat:@"%@ stage:%ld isMaterialVideoReferSelf:%d start:%f caculatedVideoDuration:%f",
						   effect.videoURLString,(long)effect.stageId,effect.isMaterialVideoReferSelf,effect.start,effect.caculatedVideoDuration];
	}
	return keyReaderWraper;
}

- (NSString *)keyForFilterExcutorAssociatToEffect:(MVVideoEffect *)effect
{
	NSString *keyForFilterExcutor;
	keyForFilterExcutor = [NSString stringWithFormat:@"filterId:%ld stage:%ld",(long)effect.filterId,(long)effect.stageId];
	return keyForFilterExcutor;
}

- (void)parseEffectData:(NSDictionary *)effectData
{
//#if DEBUG
//	NSString *testConfigJsonName = @"test.json";
//	if (FBTweakValue(@"视频特效", @"特效配置从本地读取",@"使用",NO)) {
//		NSString *configPath = [NSTemporaryDirectory() stringByAppendingPathComponent:testConfigJsonName];
//		NSDictionary *configDictinary = [NSDictionary dictionaryWithContentsOfFile:configPath];
//		if (configDictinary.count) {
//			effectData = [configDictinary objectForKey:kMVVideoEffectParserKeyFilterData] ? configDictinary
//							: [configDictinary objectForKey:kMVVideoEffectParserKeyUserData];
//		}
//	}
//#endif
	
	[self.effectParser parseEffectWithConfigUserData:effectData
								 originVideoDuration:CMTimeGetSeconds(self.asset.duration)];
}

- (AVAsset *)compositeMaterialVideo:(AVAsset *)originMaterialVideoAsset toDuration:(NSTimeInterval)toDuration
{
	NSArray * videoTracks = [originMaterialVideoAsset tracksWithMediaType:AVMediaTypeVideo];
	if (CMTimeGetSeconds(originMaterialVideoAsset.duration) >= toDuration
		|| videoTracks.count <= 0) {
		return originMaterialVideoAsset;
	}

	__block NSError  *error;
	__block BOOL     insertTrackSuccess;
	AVMutableComposition *mutableComposition = [AVMutableComposition composition];
	CMTime insertTime = kCMTimeZero;

	for (AVAssetTrack *mutableTrack in videoTracks) {
		AVMutableCompositionTrack *mutableCompositionTrack = [mutableComposition mutableTrackCompatibleWithTrack:mutableTrack];
		if (!mutableCompositionTrack) {
			mutableCompositionTrack = [mutableComposition addMutableTrackWithMediaType:mutableTrack.mediaType
																	  preferredTrackID:kCMPersistentTrackID_Invalid];
		}
		CMTime      allTime = mutableTrack.timeRange.duration;
		CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, allTime);
		mutableCompositionTrack.preferredTransform = mutableTrack.preferredTransform;
        
		void (^insertTimeRangeBlock)(CMTimeRange timeRange, CMTime insertAtTime) = ^(CMTimeRange timeRange, CMTime insertAtTime)
		{
            insertTrackSuccess = [mutableCompositionTrack insertTimeRange:timeRange
                                                                      ofTrack:mutableTrack
                                                                       atTime:insertAtTime
                                                                        error:&error];
		};

		do {
			insertTimeRangeBlock(timeRange,insertTime);
			insertTime = mutableComposition.duration;
		} while (CMTimeGetSeconds(insertTime) < toDuration);

		if (!insertTrackSuccess || error ||
			![mutableCompositionTrack validateTrackSegments:mutableCompositionTrack.segments error:&error]) {
			return originMaterialVideoAsset;
		}
	}

	return [mutableComposition copy];
}

- (AVAsset *)compositeOriginVideoTracks:(AVAsset *)videoAsset
{
	if (self.effectParser.timelineVideoEffects.count <= 0) { //插入原始抽帧
		MVVideoEffect *effect = [[MVVideoEffect alloc]init];
		effect.start = 0;
		effect.speed = 1;
		effect.duration = CMTimeGetSeconds(videoAsset.duration);
		[self.effectParser.timelineVideoEffects addObject:effect];
	}
	
	__block NSError  *error;
	__block BOOL     insertTrackSuccess;
	AVMutableComposition *mutableComposition = [AVMutableComposition composition];
	CMTime insertTime = kCMTimeZero;
    
    AVMutableCompositionTrack *mutableCompositionTrack = nil;
    AVMutableCompositionTrack *videoMutableCompositionTrack = nil;
    AVMutableCompositionTrack *audioMutableCompositionTrack = nil;
    
    videoMutableCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                              preferredTrackID:MVEffectVideoCompositionTrackPreferredTrackIDOriginVideo];
    audioMutableCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                   preferredTrackID:MVEffectVideoCompositionTrackPreferredTrackIDOriginAudio];

	for (MVVideoEffect *timeLineEffect in [[self.effectParser timelineVideoEffects] copy]) {
		
		for (AVAssetTrack *mutableTrack in [videoAsset tracks]) {

			if ([mutableTrack.mediaType isEqualToString:AVMediaTypeAudio] && timeLineEffect.isStaticFrame) { //定帧没有音频
				continue;
			}
			
                if ([mutableTrack.mediaType isEqualToString:AVMediaTypeAudio]) {
                    
                    mutableCompositionTrack = audioMutableCompositionTrack;
                } else if ([mutableTrack.mediaType isEqualToString:AVMediaTypeVideo]) {
                    
                    mutableCompositionTrack = videoMutableCompositionTrack;
                }
			
			CMTime      allTime = mutableTrack.timeRange.duration;
			CMTimeScale timeScale = allTime.timescale;
			CMTime      start = CMTimeMake(timeLineEffect.start * timeScale, timeScale);
			CMTime      duration = CMTimeMinimum(CMTimeMake(timeLineEffect.duration * timeScale, timeScale),
												 CMTimeSubtract(mutableTrack.timeRange.duration, start));
			CMTimeRange timeRange = CMTimeRangeMake(start, duration);
			
			if (timeLineEffect.start >= CMTimeGetSeconds(mutableTrack.timeRange.duration) || duration.value <= 0) {
				break; //Should abandon current stage
			}
			
            NSArray *combineAssets= self.combineAssets;
            NSString *mediaType = mutableTrack.mediaType;
			void (^insertTimeRangeBlock)(CMTimeRange, AVAssetTrack *, CMTime) = ^(CMTimeRange timeRange,AVAssetTrack *ofTrack, CMTime insertAtTime)
			{
                if (combineAssets) {
                    
                    insertTrackSuccess = [AVAsset addTrackTo:mutableCompositionTrack fromAssets:combineAssets withType:mediaType timeRange:timeRange atTime:insertAtTime error:&error];
                    if (error) {
                        
                        NSLog(@"~~~~~~~~~~~~~%@", error);
                    }
                }else{
                
                    insertTrackSuccess = [mutableCompositionTrack insertTimeRange:timeRange
                                                                          ofTrack:ofTrack
                                                                           atTime:insertAtTime
                                                                            error:&error];
                }
			};
			
			if (timeLineEffect.isStaticFrame) {
				const CMTime staticFrameTotalDuration = CMTimeMake(timeLineEffect.duration * timeScale, timeScale);
				CMTime staticFrameInsertDuration;
				CMTime staticFrameInsertTime = insertTime;
				CMTime addedStaticTime = kCMTimeZero;
				AVAssetTrack *cooperationTrack;
				CMTimeRange minStaticFrameTimeRange;

				staticFrameInsertDuration = CMTimeMinimum (duration,CMTimeMakeWithSeconds(kMVVideoEffectStaticFrameCompositionMinDuration, timeScale));
				cooperationTrack = mutableTrack;
				minStaticFrameTimeRange = CMTimeRangeMake(start,staticFrameInsertDuration);

				do {
					minStaticFrameTimeRange.duration = CMTimeMinimum(staticFrameInsertDuration, CMTimeSubtract(staticFrameTotalDuration, addedStaticTime));
                    if (CMTimeGetSeconds(CMTimeSubtract(staticFrameTotalDuration, addedStaticTime)) < 0.01) {  //colinw
                        
                        NSLog(@"time range is too short~~");
                        break;
                    }
					insertTimeRangeBlock(minStaticFrameTimeRange,cooperationTrack, staticFrameInsertTime);
                    if (!insertTrackSuccess) {
                        
                        NSLog(@"insert static frame fail~~");
                        break;
                    }
					staticFrameInsertTime = CMTimeAdd(staticFrameInsertTime,  minStaticFrameTimeRange.duration);
					addedStaticTime = CMTimeSubtract(mutableCompositionTrack.timeRange.duration, insertTime);
				} while (CMTimeCompare(addedStaticTime, staticFrameTotalDuration) < 0);
			} else {
				insertTimeRangeBlock(timeRange,mutableTrack, insertTime);
				[mutableCompositionTrack scaleTimeRange:CMTimeRangeMake(insertTime, timeRange.duration)
											 toDuration:CMTimeMake(1.0 * timeRange.duration.value / timeLineEffect.speed, allTime.timescale)];
			}
			mutableCompositionTrack.preferredTransform = mutableTrack.preferredTransform;
            if (error) {
                
                NSLog(@"~~~return ori asset error = %@," ,error);
            }
			
			if (!insertTrackSuccess || error || ![mutableCompositionTrack validateTrackSegments:mutableCompositionTrack.segments error:&error]) {
                
                NSLog(@"~~~return ori asset insertTrackSuccess = %d, error = %@, ~~~", insertTrackSuccess, error);
				return videoAsset;
			}
		}
		
		insertTime = mutableComposition.duration;
	}
	
    if ([audioMutableCompositionTrack.segments count] == 0) {

        [mutableComposition removeTrack:audioMutableCompositionTrack];
    }
	return mutableComposition;
}

- (void)deleteVideoEffectFile
{
	if (self.exportFilePath && [[NSFileManager defaultManager] fileExistsAtPath:self.exportFilePath]) {
		NSError *error;
		if (![[NSFileManager defaultManager] removeItemAtPath:self.exportFilePath error:&error]) {
		}
	}
}

- (UIImage *)processBlurFilter:(UIImage *)sourceImage
{
    CIContext *processContext = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setValue:[CIImage imageWithCGImage:sourceImage.CGImage] forKey:kCIInputImageKey];
    CGFloat blurLevel = 8.0f;
    [blurFilter setValue:[NSNumber numberWithFloat:blurLevel] forKey:@"inputRadius"];
    
    CGRect rect = inputImage.extent;
    rect.origin.x += blurLevel;
    rect.origin.y += blurLevel;
    rect.size.height -= blurLevel*2.0f;
    rect.size.width -= blurLevel*2.0f;
    
    CGImageRef blurImageRef = [processContext createCGImage:blurFilter.outputImage fromRect:rect];
    UIImage *resultImage = [UIImage imageWithCGImage:blurImageRef];
    CGImageRelease(blurImageRef);
    return resultImage;
}

#pragma mark - private
- (BOOL)isGhostShootFilter:(NSInteger)filter
{
    if (((filter >= 11000) && (filter <= 11032))
        || (filter == 11035)
        || (filter == 11036)
        || (filter == 11037)) {
        return YES;
    }

    return NO;
}

- (BOOL)isPartialFilter:(MVVideoEffect *)effect
{
    if (effect.videoURLString &&
        ([self isGhostShootFilter:effect.filterId]
        || (effect.filterId == kMVVideoEffectCombineBlurMovieFilterID)
        || (effect.filterId == kMVVideoEffectCombineSCBMovieFilterID)
        || (effect.filterId == kMVVideoEffectCombineRadialBlurMovieFilterID)
        || (effect.filterId == kMVVideoEffectCombineCurveRGBMovieFilterID)
        || (effect.filterId == kMVVideoEffectCombineAdvancedCurveRGBMovieFilterID))) {
        return YES;
    }

    return NO;
}

@end