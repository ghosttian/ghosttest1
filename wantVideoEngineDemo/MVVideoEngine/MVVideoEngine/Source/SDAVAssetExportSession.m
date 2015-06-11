//
//  SDAVAssetExportSession.m
//
//  Created by Olivier Poitrey on 13/03/13.
//  Copyright (c) 2013 Dailymotion. All rights reserved.
//

#import "SDAVAssetExportSession.h"

#if !__has_feature(objc_arc)
#error ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

static CFTimeInterval const kSDAVAssetExportSessionExportBufferMinGapTime = 0.01; //导出帧的最小间隙

@interface SDAVAssetExportSession ()
{
	BOOL isCanceled;
}
@property (nonatomic, strong) dispatch_queue_t inputQueue;
@property (nonatomic, assign) CMTime lastSamplePresentationTime;

@property (nonatomic, assign) CMTime lastAppendedVideoSampleBufferTime;
@property (nonatomic, assign) CMTime lastAppendedAudioSampleBufferTime;

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign, readwrite) float progress;
@property (nonatomic, strong) AVAssetReader *reader;
@property (nonatomic, strong) AVAssetReaderOutput *videoOutput;
@property (nonatomic, strong) AVAssetReaderAudioMixOutput *audioOutput;
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *videoPixelBufferAdaptor;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic, strong) void (^completionHandler)();

@property (nonatomic, assign) NSTimeInterval frameDuration;
@property (nonatomic, strong) NSError *frameError;
@property (nonatomic, strong) AVAssetReader *frameReader;
@property (nonatomic, strong) AVAssetReaderOutput *frameVideoOutput;
@property (nonatomic, strong) void (^frameExportCompletionHandler)();
@property (nonatomic, strong) NSLock *frameExportLock;

@end

@implementation SDAVAssetExportSession

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
	if (_inputQueue) {
		dispatch_release(_inputQueue);
	}
#endif
	NSLog(@"AVAssetExportSession dealloc");
}

+ (id)exportSessionWithAsset:(AVAsset *)asset
{
    return [SDAVAssetExportSession.alloc initWithAsset:asset];
}

- (id)initWithAsset:(AVAsset *)asset
{
    if ((self = [super init]))
    {
        _asset = asset;
        _timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
        _frameExportLock = [[NSLock alloc]init];
        
        //old is kCVPixelFormatType_32BGRA
        //but maybe blocked in concurrent operations in iOS7.0.x
        self.pixelFormatType = @(kCVPixelFormatType_32BGRA);
		_lastSamplePresentationTime = kCMTimeInvalid;
		_lastAppendedAudioSampleBufferTime = kCMTimeInvalid;
		_lastAppendedVideoSampleBufferTime = kCMTimeInvalid;
        //add by randyyu
        _shouldOptimizeForNetworkUse = YES;
    }

    return self;
}

- (void)exportEachFrameAsynchronouslyWithCompletionHandler:(void (^)())handler{

    NSParameterAssert(handler != nil);
    [self cancelFrameExport];
    self.frameExportCompletionHandler = handler;

    NSError *readerError;
    self.frameReader = [AVAssetReader.alloc initWithAsset:self.asset error:&readerError];
    if (readerError)
    {
        _frameError = readerError;
        handler();
        return;
    }

    self.frameReader.timeRange = self.timeRange;

    NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks <= 0)
    {
        _frameError = [NSError errorWithDomain:@"VideoTracks <= 0" code:1001 userInfo:nil];
        handler();
        return;
    }
    CGSize renderSize;
    if (self.videoComposition)
    {
        renderSize = self.videoComposition.renderSize;
    }
    else if (videoTracks.count)
    {
        renderSize = ((AVAssetTrack *)videoTracks[0]).naturalSize;
    }

    if (CMTIME_IS_VALID(self.timeRange.duration) && !CMTIME_IS_POSITIVE_INFINITY(self.timeRange.duration))
    {
        _frameDuration = CMTimeGetSeconds(self.timeRange.duration);
    }
    else
    {
        _frameDuration = CMTimeGetSeconds(self.asset.duration);
    }

    //
    // Video output
    //
    @try {
		if (self.videoComposition) {
			self.frameVideoOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:videoTracks videoSettings:nil];
		} else {
			//Fixbug:some special asset exporting -> AVAssetReaderVideoCompositionOutput copyNextSampleBuffer hangs
			//None return forever o(╯□╰)o,but using AVAssetReaderTrackOutput is OK
			NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: self.pixelFormatType};
			self.frameVideoOutput =  [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTracks.firstObject outputSettings:outputSettings];
		}
    }
    @catch (NSException *exception) {
        _frameError = [NSError errorWithDomain:exception.reason code:1001 userInfo:nil];
        handler();
        return;
    }
    if (!self.frameVideoOutput) {
        _frameError = [NSError errorWithDomain:@"VideoOutputIsNULL" code:1002 userInfo:nil];
        handler();
        return;
    }
    self.frameVideoOutput.alwaysCopiesSampleData = NO;
    if (self.videoComposition)
    {
        @try {
            ((AVAssetReaderVideoCompositionOutput *)self.frameVideoOutput).videoComposition = self.videoComposition;
        }
        @catch (NSException *exception) {
            _frameError = [NSError errorWithDomain:@"video composition renderSize is not positive" code:1001 userInfo:nil];
            handler();
            return;
        }
    }

    if ([self.frameReader canAddOutput:self.frameVideoOutput])
    {
        [self.frameReader addOutput:self.frameVideoOutput];
    }

    if (![self.frameReader startReading]) {
        _frameError = [NSError errorWithDomain:@"SDAVAssetExportSession reader can not startReadin" code:1001 userInfo:nil];
        handler();
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [self encodeReadySamplesFromOutput:self.frameVideoOutput];

        [self frameExportFinish];
    });
}

- (void)exportAsynchronouslyWithCompletionHandler:(void (^)())handler
{
    NSParameterAssert(handler != nil);
    [self cancelExport];
    self.completionHandler = handler;

    if (!self.outputURL)
    {
        _error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorExportFailed userInfo:@
        {
            NSLocalizedDescriptionKey: @"Output URL not set"
        }];
        handler();
    }

    NSError *readerError;
    self.reader = [AVAssetReader.alloc initWithAsset:self.asset error:&readerError];
    if (readerError)
    {
        _error = readerError;
        handler();
        return;
    }

    NSError *writerError;
    self.writer = [AVAssetWriter assetWriterWithURL:self.outputURL fileType:self.outputFileType error:&writerError];
    if (writerError)
    {
        _error = writerError;
        handler();
        return;
    }

    self.reader.timeRange = self.timeRange;
    self.writer.shouldOptimizeForNetworkUse = self.shouldOptimizeForNetworkUse;
    self.writer.metadata = self.metadata;

    NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks <= 0)
    {
        _error = [NSError errorWithDomain:@"VideoTracks <= 0" code:1001 userInfo:nil];
        handler();
        return;
    }
    CGSize renderSize;
    if (self.videoComposition)
    {
        renderSize = self.videoComposition.renderSize;
    }
    else if (videoTracks.count)
    {
        renderSize = ((AVAssetTrack *)videoTracks[0]).naturalSize;
    }

    if (CMTIME_IS_VALID(self.timeRange.duration) && !CMTIME_IS_POSITIVE_INFINITY(self.timeRange.duration))
    {
        _duration = CMTimeGetSeconds(self.timeRange.duration);
    }
    else
    {
        _duration = CMTimeGetSeconds(self.asset.duration);
    }

    //
    // Video output
    //
    @try {
		if (self.videoComposition) {
			self.videoOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:videoTracks videoSettings:nil];
		} else {
			//Fixbug:some special asset exporting -> AVAssetReaderVideoCompositionOutput copyNextSampleBuffer hangs
			//None return forever o(╯□╰)o,but using AVAssetReaderTrackOutput is OK
			NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: self.pixelFormatType};
			self.videoOutput =  [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTracks.firstObject outputSettings:outputSettings];
		}
    }
    @catch (NSException *exception) {
        _error = [NSError errorWithDomain:exception.reason code:1001 userInfo:nil];
        handler();
        return;
    }
    if (!self.videoOutput) {
        _error = [NSError errorWithDomain:@"VideoOutputIsNULL" code:1002 userInfo:nil];
        handler();
        return;
    }
    self.videoOutput.alwaysCopiesSampleData = NO;
    if (self.videoComposition)
    {
        @try {
            ((AVAssetReaderVideoCompositionOutput *)self.videoOutput).videoComposition = self.videoComposition;
        }
        @catch (NSException *exception) {
            _error = [NSError errorWithDomain:@"video composition renderSize is not positive" code:1001 userInfo:nil];
            handler();
            return;
        }
    }

    if ([self.reader canAddOutput:self.videoOutput])
    {
        [self.reader addOutput:self.videoOutput];
    }

    //
    // Video input
    //
    self.videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoSettings];
    self.videoInput.expectsMediaDataInRealTime = NO;
    
    if (self.needFixTransform)
    {
		NSInteger videoWith = [self.videoSettings[AVVideoWidthKey] integerValue];
		NSInteger videoHeight = [self.videoSettings[AVVideoHeightKey] integerValue];
		
		CGAffineTransform preferredTransform = [[self class]standardizingPreferredTransform:((AVAssetTrack *)videoTracks.firstObject)];
		CGAffineTransform fixTransform = preferredTransform;
		
		CGSize videoSize = CGSizeMake(videoWith, videoHeight);
		videoSize = CGSizeApplyAffineTransform(videoSize, preferredTransform);
		
		if (preferredTransform.tx != 0) {
			fixTransform.tx = preferredTransform.tx / fabs(preferredTransform.tx) * fabs(videoSize.width);
		}
		if (preferredTransform.ty != 0) {
			fixTransform.ty = preferredTransform.ty / fabs(preferredTransform.ty) * fabs(videoSize.height);
		}
        //colinwli 导出时已经不需要再fix一次了 先注掉 有问题随时联系
//        self.videoInput.transform = fixTransform;
    }


    if ([self.writer canAddInput:self.videoInput])
    {
        [self.writer addInput:self.videoInput];
    }
    NSDictionary *pixelBufferAttributes = @
    {
        (id)kCVPixelBufferPixelFormatTypeKey : self.pixelFormatType,
        (id)kCVPixelBufferWidthKey: @(renderSize.width),
        (id)kCVPixelBufferHeightKey: @(renderSize.height),
        @"IOSurfaceOpenGLESTextureCompatibility": @YES,
        @"IOSurfaceOpenGLESFBOCompatibility": @YES,
    };
    self.videoPixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoInput sourcePixelBufferAttributes:pixelBufferAttributes];

    //
    //Audio output
    //
    NSArray *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
	if (audioTracks.count > 0) {
		self.audioOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:audioTracks audioSettings:nil];
		self.audioOutput.alwaysCopiesSampleData = NO;
		self.audioOutput.audioMix = self.audioMix;
		if ([self.reader canAddOutput:self.audioOutput])
		{
			[self.reader addOutput:self.audioOutput];
		}
        else
        {

        }
		
		//
		// Audio input
		//
		self.audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.sdAudioSettings];
		self.audioInput.expectsMediaDataInRealTime = NO;
		if ([self.writer canAddInput:self.audioInput])
		{
			[self.writer addInput:self.audioInput];
		}
	} else {

	}
    @try {
        if (![self.writer startWriting]) {
            _error = [NSError errorWithDomain:@"SDAVAssetExportSession writer can not startWriting" code:1001 userInfo:nil];
            handler();
            return;
        }
        if (![self.reader startReading]) {
            _error = [NSError errorWithDomain:@"SDAVAssetExportSession reader can not startReadin" code:1001 userInfo:nil];
            handler();
            return;
        }
    }
    @catch (NSException *exception) {
        _error = [NSError errorWithDomain:@"SDAVAssetExportSession reader can not startReadin" code:1001 userInfo:nil];
        handler();
        return;
    }
    [self.writer startSessionAtSourceTime:CMTimeMake(0, ((AVAssetTrack *)videoTracks[0]).naturalTimeScale)];
	_inputQueue = dispatch_queue_create("VideoEncoderInputQueue", DISPATCH_QUEUE_SERIAL);

    __block BOOL videoCompleted = NO;
    __block BOOL audioCompleted = NO;
    __weak typeof(self) wself = self;
	if (audioTracks.count == 0) {
		audioCompleted = YES; //maybe silent video ,not exist audio tracks
	}

	isCanceled = NO;

    [self.videoInput requestMediaDataWhenReadyOnQueue:_inputQueue usingBlock:^
    {
        if (![wself encodeReadySamplesFromOutput:wself.videoOutput toInput:wself.videoInput])
        {
            @synchronized(wself)
            {
                videoCompleted = YES;
                if (audioCompleted)
                {
                    [wself finish];
                }
            }
        } else {
//            NSLog(@"SDExportSession video input not ready for more data");
        }
    }];
    [self.audioInput requestMediaDataWhenReadyOnQueue:_inputQueue usingBlock:^
    {
        if (![wself encodeReadySamplesFromOutput:wself.audioOutput toInput:wself.audioInput])
        {
            @synchronized(wself)
            {
                audioCompleted = YES;
                if (videoCompleted)
                {
                    [wself finish];
                }
            }
        } else {
//            NSLog(@"SDExportSession audio input not ready for more data");
        }
    }];
}

- (BOOL)encodeReadySamplesFromOutput:(AVAssetReaderOutput *)output{
    NSInteger index = 0;

    if (self.frameReader.status != AVAssetReaderStatusReading) {
        return NO;
    }

    CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];

    while (sampleBuffer) {

        [_frameExportLock lock];

        BOOL handled = NO;
        BOOL error = NO;

        @autoreleasepool {

            if (!handled && self.frameVideoOutput == output){

                if ([self.delegate respondsToSelector:@selector(frameExportSession:originalFrame:currentIndex:)]){
                    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);

                    [self.delegate frameExportSession:self originalFrame:pixelBuffer currentIndex:index];

                    index++;
                }

            }

            CFRelease(sampleBuffer);
            sampleBuffer = NULL;

            if (self.frameReader.status != AVAssetReaderStatusReading){
                handled = YES;
                error = YES;
            }

            if (error){
                [_frameExportLock unlock];
                return NO;
            }

            sampleBuffer = [output copyNextSampleBuffer];
        }

        [_frameExportLock unlock];

    }

    return YES;
}

- (BOOL)encodeReadySamplesFromOutput:(AVAssetReaderOutput *)output toInput:(AVAssetWriterInput *)input
{
    NSInteger index = 0;
    while (input.isReadyForMoreMediaData){

		@autoreleasepool {
			if (isCanceled) {
				[self.reader cancelReading]; //This method should not be called concurrently with any calls to -[AVAssetReaderOutput copyNextSampleBuffer]
			}
            if (self.reader.status != AVAssetReaderStatusReading) {
                return NO;
            }
			CMSampleBufferRef sampleBuffer = NULL;
			
			if (self.videoOutput || self.audioOutput) { //保证没有被cancel掉才允许copyNextSampleBuffer
				sampleBuffer = [output copyNextSampleBuffer];
			}
			if (sampleBuffer)
			{
				BOOL handled = NO;
				BOOL error = NO;
				
				if (self.reader.status != AVAssetReaderStatusReading || self.writer.status != AVAssetWriterStatusWriting)
				{
					handled = YES;
					error = YES;
				}
				
				CMTime currentSamplePresentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
				CMTime lastAppendedSampleBufferTime =  self.videoOutput == output ? _lastAppendedVideoSampleBufferTime : _lastAppendedAudioSampleBufferTime;
				NSTimeInterval lastAppendedSampleTimeInterval = CMTimeGetSeconds (lastAppendedSampleBufferTime);
				NSTimeInterval currentSampleTimeInterval = CMTimeGetSeconds (currentSamplePresentationTime);

				BOOL needAppendCurrentBuffer = NO;
				//fixbug: 防止出现buffer间隙时间过小的情况，导出失败
				if (CMTIME_IS_INVALID(lastAppendedSampleBufferTime)
					|| (currentSampleTimeInterval - lastAppendedSampleTimeInterval) > kSDAVAssetExportSessionExportBufferMinGapTime) {
					needAppendCurrentBuffer = YES;
				}
				
				if (!handled && self.videoOutput == output)
				{
					_lastSamplePresentationTime = currentSamplePresentationTime;

					self.progress = (_duration == 0 ? 1 : CMTimeGetSeconds(_lastSamplePresentationTime) / _duration);
					
					if ([self.delegate respondsToSelector:@selector(exportSession:renderFrame:withPresentationTime:toBuffer:currentIndex:)])
					{
						CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
						CVPixelBufferRef renderBuffer = NULL;
						CVPixelBufferPoolCreatePixelBuffer(NULL, self.videoPixelBufferAdaptor.pixelBufferPool, &renderBuffer);
						CVPixelBufferLockBaseAddress(renderBuffer, 0);
						[self.delegate exportSession:self renderFrame:pixelBuffer withPresentationTime:_lastSamplePresentationTime toBuffer:renderBuffer currentIndex:index];
						CVPixelBufferUnlockBaseAddress(renderBuffer, 0);
						if (![self.videoPixelBufferAdaptor appendPixelBuffer:renderBuffer withPresentationTime:_lastSamplePresentationTime])
						{
							error = YES;
						}
						CVPixelBufferRelease(renderBuffer);
						handled = YES;

                        index++;
					}
				}
				
				if (!handled && needAppendCurrentBuffer)
				{
                    handled = YES;
                    if (![input appendSampleBuffer:sampleBuffer]) {
                        error = YES;
                    } else {
//                        NSLog(@"SDExportSession input append buffer...");
						if (self.videoOutput == output) {
							_lastAppendedVideoSampleBufferTime = currentSamplePresentationTime;
						} else if (self.audioOutput == output) {
							_lastAppendedAudioSampleBufferTime = currentSamplePresentationTime;
						}
                    }
				}
				if (!needAppendCurrentBuffer) {
					NSLog(@"AssetExportSession drop current sample buffer");
					CMTimeShow(currentSamplePresentationTime);
				}
				CFRelease(sampleBuffer);
				sampleBuffer = NULL;
				if (error){
					return NO;
				}
			}
			else
			{
				[input markAsFinished];
				return NO;
			}
		}
    }

    return YES;
}

- (AVMutableVideoComposition *)buildDefaultVideoComposition
{
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    AVAssetTrack *videoTrack = [[self.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    // get the frame rate from videoSettings, if not set then try to get it from the video track,
    // if not set (mainly when asset is AVComposition) then use the default frame rate of 30
    float trackFrameRate = 0;
	if (self.videoSettings)
    {
        NSDictionary *videoCompressionProperties = [self.videoSettings objectForKey:AVVideoCompressionPropertiesKey];
        if (videoCompressionProperties)
        {
            NSNumber *maxKeyFrameInterval = [videoCompressionProperties objectForKey:AVVideoMaxKeyFrameIntervalKey];
            if (maxKeyFrameInterval)
            {
                trackFrameRate = maxKeyFrameInterval.floatValue;
            }
        }
    }
    else
    {
        trackFrameRate = [videoTrack nominalFrameRate];
    }

    if (trackFrameRate == 0)
    {
        trackFrameRate = 30;
    }

    videoComposition.frameDuration = CMTimeMake(1, trackFrameRate);
    videoComposition.renderSize = [videoTrack naturalSize];

	// Make a "pass through video track" video composition.
	AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
	passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);

	AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//	不设置，而在AVAssetWriterInput初始化的时候设置preferredTransform
//  [passThroughLayer setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];

	passThroughInstruction.layerInstructions = @[passThroughLayer];
	videoComposition.instructions = @[passThroughInstruction];

    return videoComposition;
}

- (void)finish
{
    // Synchronized block to ensure we never cancel the writer before calling finishWritingWithCompletionHandler
    if (self.reader.status == AVAssetReaderStatusCancelled || self.writer.status == AVAssetWriterStatusCancelled){
        return;
    }

    if (self.writer.status == AVAssetWriterStatusFailed){
        [self complete];
    }
    else{
        @try {
            typeof(self)__weak weakSelf = self;
            [self.writer finishWritingWithCompletionHandler:^
             {
                 [weakSelf complete];
             }];
        }
        @catch (NSException *exception) {
        }
    }
}

- (void)complete
{
    if (self.writer.status == AVAssetWriterStatusFailed || self.writer.status == AVAssetWriterStatusCancelled)
    {
		NSLog(@"complete exportSession = removeItemAtURL state %d",(int)self.writer.status);
        [NSFileManager.defaultManager removeItemAtURL:self.outputURL error:nil];
    }

    if (self.completionHandler)
    {
        self.completionHandler();
        self.completionHandler = nil;
    }
}

- (NSError *)error
{
    if (_error)
    {
        return _error;
    }
    else
    {
        return self.writer.error ? : self.reader.error;
    }
}

- (AVAssetExportSessionStatus)status
{
    switch (self.writer.status)
    {
        default:
        case AVAssetWriterStatusUnknown:
            return AVAssetExportSessionStatusUnknown;
        case AVAssetWriterStatusWriting:
            return AVAssetExportSessionStatusExporting;
        case AVAssetWriterStatusFailed:
            return AVAssetExportSessionStatusFailed;
        case AVAssetWriterStatusCompleted:
            return AVAssetExportSessionStatusCompleted;
        case AVAssetWriterStatusCancelled:
            return AVAssetExportSessionStatusCancelled;
    }
}

- (void)cancelExport
{
	isCanceled = YES;

    if (self.writer.status == AVAssetWriterStatusWriting) {
        [self.writer cancelWriting];
    }

//禁止和 copyNextSampleBuffer 并发执行
//    if (self.reader.status == AVAssetReaderStatusReading) {
//        [self.reader cancelReading];
//    }

	[self complete];
	[self reset];
}

- (void)reset{
    _error = nil;
    self.progress = 0;
    self.reader = nil;
    self.videoOutput = nil;
    self.audioOutput = nil;
    self.writer = nil;
    self.videoInput = nil;
    self.videoPixelBufferAdaptor = nil;
    self.audioInput = nil;
    self.inputQueue = nil;
    self.completionHandler = nil;
}

//对视频preferredTransform做归一化处理 其他软件或者Android的视频裁剪错误
+ (CGAffineTransform)standardizingPreferredTransform:(AVAssetTrack *)assetVideoTrack
{
	CGAffineTransform preferredTransform = assetVideoTrack.preferredTransform;
	CGSize naturalSize = assetVideoTrack.naturalSize;
	CGAffineTransform txf       = preferredTransform;
	if (txf.a == 0 && txf.b == 1.0 && txf.c == -1.0 && txf.d == 0) { //left
		preferredTransform.tx = naturalSize.height;
	}
	if (txf.a == 0 && txf.b == -1.0 && txf.c == 1.0 && txf.d == 0) { //right
		preferredTransform.ty = naturalSize.width;
	}
	if (txf.a == 1.0 && txf.b == 0 && txf.c == 0 && txf.d == 1.0) { //up
		//None operation
	}
	if (txf.a == -1.0 && txf.b == 0 && txf.c == 0 && txf.d == -1.0) { //down
		preferredTransform.tx = naturalSize.width;
		preferredTransform.ty = naturalSize.height;
	}

	return preferredTransform;
}

#pragma mark frame export functions

- (void)cancelFrameExport{
    [_frameExportLock lock];

    if (self.frameReader.status == AVAssetReaderStatusReading) {
        [self.frameReader cancelReading];
    }

    [_frameExportLock unlock];

    [self frameExportComplete];
    [self frameExportReset];
}

- (void)frameExportComplete{
    if (self.frameExportCompletionHandler)
    {
        self.frameExportCompletionHandler();
        self.frameExportCompletionHandler = nil;
    }
}

- (void)frameExportReset{
    _frameError = nil;
    self.frameReader = nil;
    self.frameVideoOutput = nil;
    self.frameExportCompletionHandler = nil;
}

- (void)frameExportFinish{
    if (self.reader.status == AVAssetReaderStatusCancelled){
        return;
    }

    [self frameExportComplete];
}

@end
