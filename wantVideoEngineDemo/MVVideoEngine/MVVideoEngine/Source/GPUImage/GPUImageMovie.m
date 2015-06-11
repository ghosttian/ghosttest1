#import "GPUImageMovie.h"
#import "GPUImageMovieWriter.h"
#import "GPUImageFilter.h"
#import "GPUImageVideoCamera.h"

@interface GPUImageMovie () <AVPlayerItemOutputPullDelegate>
{
    BOOL audioEncodingIsFinished, videoEncodingIsFinished;
    GPUImageMovieWriter *synchronizedMovieWriter;
    AVAssetReader *reader;
    AVPlayerItemVideoOutput *playerItemOutput;
    CADisplayLink *displayLink;
    CMTime previousFrameTime, processingFrameTime;
  
    BOOL keepLooping;

    GLuint luminanceTexture, chrominanceTexture;

    GLProgram *yuvConversionProgram;
    GLint yuvConversionPositionAttribute, yuvConversionTextureCoordinateAttribute;
    GLint yuvConversionLuminanceTextureUniform, yuvConversionChrominanceTextureUniform;
    GLint yuvConversionMatrixUniform;
    const GLfloat *_preferredConversion;
    
    BOOL isFullYUVRange;
	
	
    int imageBufferWidth, imageBufferHeight;
	
}

@property (nonatomic, strong) NSOperationQueue *movieQueue;
@property (assign, atomic) BOOL isCanceled;
@property(nonatomic, assign)   CFAbsoluteTime previousActualFrameTime;
@property(nonatomic, assign)   NSInteger dropFrameCount;
@property(nonatomic, assign)   NSInteger validFrameCount;

- (void)processAsset;

@end

@implementation GPUImageMovie

@synthesize url = _url;
@synthesize asset = _asset;
@synthesize runBenchmark = _runBenchmark;
@synthesize playAtActualSpeed = _playAtActualSpeed;
@synthesize delegate = _delegate;
@synthesize shouldRepeat = _shouldRepeat;

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithURL:(NSURL *)url;
{
    if (!(self = [super init])) 
    {
        return nil;
    }

    [self yuvConversionSetup];

    self.url = url;
    self.asset = nil;

    return self;
}

- (id)initWithAsset:(AVAsset *)asset;
{
    if (!(self = [super init])) 
    {
      return nil;
    }
    
    [self yuvConversionSetup];

    self.url = nil;
    self.asset = asset;

    return self;
}

- (id)initWithPlayerItem:(AVPlayerItem *)playerItem;
{
    if (!(self = [super init]))
    {
        return nil;
    }

    [self yuvConversionSetup];

    self.url = nil;
    self.asset = nil;
    self.playerItem = playerItem;

    return self;
}

- (void)yuvConversionSetup;
{
    if ([GPUImageContext supportsFastTextureUpload])
    {
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];

            _preferredConversion = kColorConversion709;
            isFullYUVRange       = YES;
            yuvConversionProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageYUVFullRangeConversionForLAFragmentShaderString];

            if (!yuvConversionProgram.initialized)
            {
                [yuvConversionProgram addAttribute:@"position"];
                [yuvConversionProgram addAttribute:@"inputTextureCoordinate"];

                if (![yuvConversionProgram link])
                {
                    NSString *progLog = [yuvConversionProgram programLog];
                    NSLog(@"Program link log: %@", progLog);
                    NSString *fragLog = [yuvConversionProgram fragmentShaderLog];
                    NSLog(@"Fragment shader compile log: %@", fragLog);
                    NSString *vertLog = [yuvConversionProgram vertexShaderLog];
                    NSLog(@"Vertex shader compile log: %@", vertLog);
                    yuvConversionProgram = nil;
                    NSAssert(NO, @"Filter shader link failed");
                }
            }

            yuvConversionPositionAttribute = [yuvConversionProgram attributeIndex:@"position"];
            yuvConversionTextureCoordinateAttribute = [yuvConversionProgram attributeIndex:@"inputTextureCoordinate"];
            yuvConversionLuminanceTextureUniform = [yuvConversionProgram uniformIndex:@"luminanceTexture"];
            yuvConversionChrominanceTextureUniform = [yuvConversionProgram uniformIndex:@"chrominanceTexture"];
            yuvConversionMatrixUniform = [yuvConversionProgram uniformIndex:@"colorConversionMatrix"];

            [GPUImageContext setActiveShaderProgram:yuvConversionProgram];

            glEnableVertexAttribArray(yuvConversionPositionAttribute);
            glEnableVertexAttribArray(yuvConversionTextureCoordinateAttribute);
        });
    }
}

- (void)dealloc
{
    // Moved into endProcessing
    //if (self.playerItem && (displayLink != nil))
    //{
    //    [displayLink invalidate]; // remove from all run loops
    //    displayLink = nil;
    //}
	self.delegate = nil;
}

#pragma mark -
#pragma mark Movie processing

- (void)enableSynchronizedEncodingUsingMovieWriter:(GPUImageMovieWriter *)movieWriter;
{
    synchronizedMovieWriter = movieWriter;
    movieWriter.encodingLiveVideo = NO;
}

- (void)startProcessing
{
	self.isCanceled = NO;

    if( self.playerItem ) {
        [self processPlayerItem];
        return;
    }
    if(self.url == nil)
    {
      [self processAsset];
      return;
    }
    
    if (_shouldRepeat) keepLooping = YES;
    
    previousFrameTime = kCMTimeIndefinite;
    _previousActualFrameTime = CFAbsoluteTimeGetCurrent();
  
    NSDictionary *inputOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVAsset *inputAsset = [[AVURLAsset alloc] initWithURL:self.url options:inputOptions];
    
    GPUImageMovie __block *blockSelf = self;
    
    [inputAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler: ^{
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [inputAsset statusOfValueForKey:@"tracks" error:&error];
        if (tracksStatus != AVKeyValueStatusLoaded)
        {
            return;
        }
        blockSelf.asset = inputAsset;
        [blockSelf processAsset];
        blockSelf = nil;
    }];
}

- (AVAssetReader*)createAssetReader
{
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:self.asset error:&error];

    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
    if ([GPUImageContext supportsFastTextureUpload]) {
        [outputSettings setObject:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        isFullYUVRange = YES;
    }
    else {
        [outputSettings setObject:@(kCVPixelFormatType_32BGRA) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        isFullYUVRange = NO;
    }
	
	NSArray * videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
	if (videoTracks.count == 0) {
		return nil;
	}
    // Maybe set alwaysCopiesSampleData to NO on iOS 5.0 for faster video decoding
    AVAssetReaderTrackOutput *readerVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTracks.firstObject
																								  outputSettings:outputSettings];
    readerVideoTrackOutput.alwaysCopiesSampleData = NO;
    [assetReader addOutput:readerVideoTrackOutput];

    NSArray *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
    BOOL shouldRecordAudioTrack = (([audioTracks count] > 0) && (self.audioEncodingTarget != nil) );
    AVAssetReaderTrackOutput *readerAudioTrackOutput = nil;

    if (shouldRecordAudioTrack)
    {
        [self.audioEncodingTarget setShouldInvalidateAudioSampleWhenDone:YES];
        
        // This might need to be extended to handle movies with more than one audio track
        AVAssetTrack* audioTrack = [audioTracks objectAtIndex:0];
        readerAudioTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
        readerAudioTrackOutput.alwaysCopiesSampleData = NO;
        [assetReader addOutput:readerAudioTrackOutput];
    }

    return assetReader;
}

- (void)processAsset
{
    reader = [self createAssetReader];

    AVAssetReaderOutput *readerVideoTrackOutput = nil;
    AVAssetReaderOutput *readerAudioTrackOutput = nil;

    audioEncodingIsFinished = YES;
    for( AVAssetReaderOutput *output in reader.outputs ) {
        if( [output.mediaType isEqualToString:AVMediaTypeAudio] ) {
            audioEncodingIsFinished = NO;
            readerAudioTrackOutput = output;
        }
        else if( [output.mediaType isEqualToString:AVMediaTypeVideo] ) {
            readerVideoTrackOutput = output;
        }
    }

    if ([reader startReading] == NO) 
    {
		NSLog(@"Error reading from file at URL: %@", self.url);
        return;
    }

    __weak GPUImageMovie *weakSelf = self;

    if (synchronizedMovieWriter != nil)
    {
        [synchronizedMovieWriter setVideoInputReadyCallback:^{
			if (weakSelf) {
				return [weakSelf readNextVideoFrameFromOutput:readerVideoTrackOutput];
			}
			NSLog(@"weakSelf == nil  setVideoInputReadyCallback return NO");
			return NO;
        }];

        [synchronizedMovieWriter setAudioInputReadyCallback:^{
			if (weakSelf) {
				return [weakSelf readNextAudioSampleFromOutput:readerAudioTrackOutput];
			}
			NSLog(@"weakSelf == nil  setAudioInputReadyCallback return NO");
			return NO;
        }];

        [synchronizedMovieWriter enableSynchronizationCallbacks];
    }
    else
    {
		if (!self.movieQueue) {
			self.movieQueue = [[NSOperationQueue alloc]init];
			self.movieQueue.maxConcurrentOperationCount = 1;
		}
		[self.movieQueue cancelAllOperations];

		[self.movieQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
			while (reader.status == AVAssetReaderStatusReading && (!_shouldRepeat || keepLooping))
			{
                
				[weakSelf readNextVideoFrameFromOutput:readerVideoTrackOutput];
				
				if ( (readerAudioTrackOutput) && (!audioEncodingIsFinished) )
				{
					[weakSelf readNextAudioSampleFromOutput:readerAudioTrackOutput];
				}
			}
			
			if (reader.status == AVAssetWriterStatusCompleted) {
				[reader cancelReading];
				
				if (keepLooping) {
					reader = nil;
					dispatch_async(dispatch_get_main_queue(), ^{
						[self startProcessing];
					});
				} else {
					[weakSelf endProcessing];
				}
			}
		}]];
    }
}

- (void)processPlayerItem
{
    runSynchronouslyOnVideoProcessingQueue(^{
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [displayLink setPaused:YES];

        dispatch_queue_t videoProcessingQueue = [GPUImageContext sharedContextQueue];
        NSMutableDictionary *pixBuffAttributes = [NSMutableDictionary dictionary];
        if ([GPUImageContext supportsFastTextureUpload]) {
            [pixBuffAttributes setObject:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        }
        else {
            [pixBuffAttributes setObject:@(kCVPixelFormatType_32BGRA) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        }
        playerItemOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
        [playerItemOutput setDelegate:self queue:videoProcessingQueue];

        [_playerItem addOutput:playerItemOutput];
        [playerItemOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:1];
    });
}

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender
{
	// Restart display link.
	[displayLink setPaused:NO];
}

- (void)setPaused:(BOOL)paused
{
    _paused = paused;
    if (!paused) {
        _previousActualFrameTime = CFAbsoluteTimeGetCurrent();
    }
}

- (void)displayLinkCallback:(CADisplayLink *)sender
{
	/*
	 The callback gets called once every Vsync.
	 Using the display link's timestamp and duration we can compute the next time the screen will be refreshed, and copy the pixel buffer for that time
	 This pixel buffer can then be processed and later rendered on screen.
	 */
	// Calculate the nextVsync time which is when the screen will be refreshed next.
	CFTimeInterval nextVSync = ([sender timestamp] + [sender duration]);

	CMTime outputItemTime = [playerItemOutput itemTimeForHostTime:nextVSync];

	if ([playerItemOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        __unsafe_unretained GPUImageMovie *weakSelf = self;
		CVPixelBufferRef pixelBuffer = [playerItemOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        if( pixelBuffer )
            runSynchronouslyOnVideoProcessingQueue(^{
                [weakSelf customProcessMovieFrame:pixelBuffer withSampleTime:outputItemTime];
                CFRelease(pixelBuffer);
            });
	}
}

- (BOOL)readNextVideoFrameFromOutput:(AVAssetReaderOutput *)readerVideoTrackOutput;
{
    if (_paused) {
        return NO;
    }
	if (self.isCanceled) {
		[reader cancelReading];
	}
	
	if ([[UIApplication sharedApplication]applicationState] != UIApplicationStateActive) {
		return NO;
	}

    if (reader.status == AVAssetReaderStatusReading && ! videoEncodingIsFinished)
    {
		CMSampleBufferRef sampleBufferRef = NULL;
		if (reader.status == AVAssetReaderStatusReading && !self.isCanceled) {
			sampleBufferRef = [readerVideoTrackOutput copyNextSampleBuffer];
		}

        if (sampleBufferRef)
        {
            //NSLog(@"read a video frame: %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, CMSampleBufferGetOutputPresentationTimeStamp(sampleBufferRef))));
            if (_playAtActualSpeed)
            {
                // Do this outside of the video processing queue to not slow that down while waiting
                CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBufferRef);
                CMTime differenceFromLastFrame = CMTimeSubtract(currentSampleTime, previousFrameTime);
                CFAbsoluteTime currentActualTime = CFAbsoluteTimeGetCurrent();
                CGFloat frameTimeDifference = CMTimeGetSeconds(differenceFromLastFrame);
                CGFloat actualTimeDifference = currentActualTime - _previousActualFrameTime;
                
                if (frameTimeDifference > actualTimeDifference && !CMTIME_IS_INDEFINITE(previousFrameTime))
                {
					CGFloat diff = (frameTimeDifference - actualTimeDifference);
//					NSLog(@"usleep %f currentActualTime %f _previousActualFrameTime %f",diff,currentActualTime,_previousActualFrameTime);
                    usleep(1000000.0 * diff);
				} else if (self.shouldDropFrame && !CMTIME_IS_INDEFINITE(previousFrameTime)) {
					
						while (frameTimeDifference < actualTimeDifference) {
							CMSampleBufferInvalidate(sampleBufferRef);
							CFRelease(sampleBufferRef);
							sampleBufferRef = NULL;

							self.dropFrameCount ++;
							
							if (reader.status == AVAssetReaderStatusReading && !self.isCanceled) {
								sampleBufferRef = [readerVideoTrackOutput copyNextSampleBuffer];
							}
		
							if (sampleBufferRef) {
								currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBufferRef);
								differenceFromLastFrame = CMTimeSubtract(currentSampleTime, previousFrameTime);
								frameTimeDifference = CMTimeGetSeconds(differenceFromLastFrame);
								currentActualTime = CFAbsoluteTimeGetCurrent();
								actualTimeDifference = currentActualTime - _previousActualFrameTime;
							} else {
								if (!keepLooping) {
									videoEncodingIsFinished = YES;
									if( videoEncodingIsFinished && audioEncodingIsFinished )
										[self endProcessing];
								}
								return NO;
							}
						}
					if (frameTimeDifference > actualTimeDifference && !CMTIME_IS_INDEFINITE(previousFrameTime))
					{
						CGFloat diff = (frameTimeDifference - actualTimeDifference);
						usleep(1000000.0 * diff);
					}
					NSLog(@"movie dropFrameCount %ld validFrameCount %ld",(long)self.dropFrameCount,(long)self.validFrameCount);
				}
					
                previousFrameTime = currentSampleTime;
				
				_previousActualFrameTime = CFAbsoluteTimeGetCurrent();
            }

			self.validFrameCount ++;

            __weak GPUImageMovie *weakSelf = self;
            runSynchronouslyOnVideoProcessingQueue(^{
                [weakSelf processMovieFrame:sampleBufferRef];
				if (sampleBufferRef) {
//					CMSampleBufferInvalidate(sampleBufferRef);
					CFRelease(sampleBufferRef);
				}
            });

            return YES;
        }
        else
        {
            if (!keepLooping) {
                videoEncodingIsFinished = YES;
                if( videoEncodingIsFinished && audioEncodingIsFinished )
                    [self endProcessing];
            }
        }
    }
    else if (synchronizedMovieWriter != nil)
    {
        if (reader.status == AVAssetReaderStatusCompleted)
        {
            [self endProcessing];
        }
    }

    return NO;
}

- (BOOL)readNextAudioSampleFromOutput:(AVAssetReaderOutput *)readerAudioTrackOutput;
{
    if (_paused) {
        return NO;
    }
	if ([[UIApplication sharedApplication]applicationState] != UIApplicationStateActive) {
		return NO;
	}
    if (reader.status == AVAssetReaderStatusReading && ! audioEncodingIsFinished)
    {
		
		CMSampleBufferRef audioSampleBufferRef;
		audioSampleBufferRef = [readerAudioTrackOutput copyNextSampleBuffer];

        if (audioSampleBufferRef)
        {
            //NSLog(@"read an audio frame: %@", CFBridgingRelease(CMTimeCopyDescription(kCFAllocatorDefault, CMSampleBufferGetOutputPresentationTimeStamp(audioSampleBufferRef))));
            [self.audioEncodingTarget processAudioBuffer:audioSampleBufferRef];
            CFRelease(audioSampleBufferRef);
            return YES;
        }
        else
        {
            if (!keepLooping) {
                audioEncodingIsFinished = YES;
                if( videoEncodingIsFinished && audioEncodingIsFinished )
                    [self endProcessing];
            }
        }
    }
    else if (synchronizedMovieWriter != nil)
    {
        if (reader.status == AVAssetReaderStatusCompleted || reader.status == AVAssetReaderStatusFailed ||
            reader.status == AVAssetReaderStatusCancelled)
        {
            [self endProcessing];
        }
    }

    return NO;
}

- (void)processMovieFrame:(CMSampleBufferRef)movieSampleBuffer; 
{
//    CMTimeGetSeconds
//    CMTimeSubtract
    
    CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(movieSampleBuffer);
    CVImageBufferRef movieFrame = CMSampleBufferGetImageBuffer(movieSampleBuffer);

    processingFrameTime = currentSampleTime;
    [self customProcessMovieFrame:movieFrame withSampleTime:currentSampleTime];
}

- (float)progress
{
    if ( AVAssetReaderStatusReading == reader.status )
    {
        float current = processingFrameTime.value * 1.0f / processingFrameTime.timescale;
        float duration = self.asset.duration.value * 1.0f / self.asset.duration.timescale;
        return current / duration;
    }
    else if ( AVAssetReaderStatusCompleted == reader.status )
    {
        return 1.f;
    }
    else
    {
        return 0.f;
    }
}

- (void)customProcessMovieFrame:(CVPixelBufferRef)movieFrame withSampleTime:(CMTime)currentSampleTime
{
	if ([self.delegate respondsToSelector:@selector(customProcessMovieFrame:withSampleTime:)]) {
		[self.delegate customProcessMovieFrame:movieFrame withSampleTime:currentSampleTime];
	} else {
		[self processMovieFrame:movieFrame withSampleTime:currentSampleTime];
	}
}

- (void)processMovieFrame:(CVPixelBufferRef)movieFrame withSampleTime:(CMTime)currentSampleTime
{
	if ([[UIApplication sharedApplication]applicationState] != UIApplicationStateActive) {
		return;
	}
	
    int bufferHeight = (int) CVPixelBufferGetHeight(movieFrame);
    int bufferWidth = (int) CVPixelBufferGetWidth(movieFrame);

    CFTypeRef colorAttachments = CVBufferGetAttachment(movieFrame, kCVImageBufferYCbCrMatrixKey, NULL);
    if (colorAttachments != NULL)
    {
        if(CFStringCompare(colorAttachments, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo)
        {
            if (isFullYUVRange)
            {
                _preferredConversion = kColorConversion601FullRange;
            }
            else
            {
                _preferredConversion = kColorConversion601;
            }
        }
        else
        {
            _preferredConversion = kColorConversion709;
        }
    }
    else
    {
        if (isFullYUVRange)
        {
            _preferredConversion = kColorConversion601FullRange;
        }
        else
        {
            _preferredConversion = kColorConversion601;
        }

    }
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    // Fix issue 1580
    [GPUImageContext useImageProcessingContext];
    
    if ([GPUImageContext supportsFastTextureUpload])
    {
        CVOpenGLESTextureRef luminanceTextureRef = NULL;
        CVOpenGLESTextureRef chrominanceTextureRef = NULL;

        //        if (captureAsYUV && [GPUImageContext deviceSupportsRedTextures])
        if (CVPixelBufferGetPlaneCount(movieFrame) > 0) // Check for YUV planar inputs to do RGB conversion
        {

            if ( (imageBufferWidth != bufferWidth) && (imageBufferHeight != bufferHeight) )
            {
                imageBufferWidth = bufferWidth;
                imageBufferHeight = bufferHeight;
            }

            CVReturn err;
            // Y-plane
            glActiveTexture(GL_TEXTURE4);
            if ([GPUImageContext deviceSupportsRedTextures])
            {
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
            }
            else
            {
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
            }
            if (err)
            {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            }

            luminanceTexture = CVOpenGLESTextureGetName(luminanceTextureRef);
            glBindTexture(GL_TEXTURE_2D, luminanceTexture);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

            // UV-plane
            glActiveTexture(GL_TEXTURE5);
            if ([GPUImageContext deviceSupportsRedTextures])
            {
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, bufferWidth/2, bufferHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
            }
            else
            {
                err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, bufferWidth/2, bufferHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
            }
            if (err)
            {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            }

            chrominanceTexture = CVOpenGLESTextureGetName(chrominanceTextureRef);
            glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

//            if (!allTargetsWantMonochromeData)
//            {
                [self convertYUVToRGBOutput];
//            }

            for (id<GPUImageInput> currentTarget in targets)
            {
                NSInteger indexOfObject = [targets indexOfObject:currentTarget];
                NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
                [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:targetTextureIndex];
                [currentTarget setInputFramebuffer:outputFramebuffer atIndex:targetTextureIndex];
            }
            
            [outputFramebuffer unlock];

            for (id<GPUImageInput> currentTarget in targets)
            {
                NSInteger indexOfObject = [targets indexOfObject:currentTarget];
                NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
                [currentTarget newFrameReadyAtTime:currentSampleTime atIndex:targetTextureIndex];
            }

            CVPixelBufferUnlockBaseAddress(movieFrame, 0);
            CFRelease(luminanceTextureRef);
            CFRelease(chrominanceTextureRef);
        }
        else
        {
            // TODO: Mesh this with the new framebuffer cache
//            CVPixelBufferLockBaseAddress(movieFrame, 0);
//
//            CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, coreVideoTextureCache, movieFrame, NULL, GL_TEXTURE_2D, GL_RGBA, bufferWidth, bufferHeight, GL_BGRA, GL_UNSIGNED_BYTE, 0, &texture);
//
//            if (!texture || err) {
//                NSLog(@"Movie CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err);
//                NSAssert(NO, @"Camera failure");
//                return;
//            }
//
//            outputTexture = CVOpenGLESTextureGetName(texture);
//            //        glBindTexture(CVOpenGLESTextureGetTarget(texture), outputTexture);
//            glBindTexture(GL_TEXTURE_2D, outputTexture);
//            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//
//            for (id<GPUImageInput> currentTarget in targets)
//            {
//                NSInteger indexOfObject = [targets indexOfObject:currentTarget];
//                NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
//
//                [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:targetTextureIndex];
//                [currentTarget setInputTexture:outputTexture atIndex:targetTextureIndex];
//
//                [currentTarget newFrameReadyAtTime:currentSampleTime atIndex:targetTextureIndex];
//            }
//
//            CVPixelBufferUnlockBaseAddress(movieFrame, 0);
//            CVOpenGLESTextureCacheFlush(coreVideoTextureCache, 0);
//            CFRelease(texture);
//            
//            outputTexture = 0;
        }
    }
    else
    {
        // Upload to texture
        CVPixelBufferLockBaseAddress(movieFrame, 0);
        
        outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(bufferWidth, bufferHeight) textureOptions:self.outputTextureOptions onlyTexture:YES];

        glBindTexture(GL_TEXTURE_2D, [outputFramebuffer texture]);
        // Using BGRA extension to pull in video frame data directly
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     self.outputTextureOptions.internalFormat,
                     bufferWidth,
                     bufferHeight,
                     0,
                     self.outputTextureOptions.format,
                     self.outputTextureOptions.type,
                     CVPixelBufferGetBaseAddress(movieFrame));
        
        for (id<GPUImageInput> currentTarget in targets)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:targetTextureIndex];
            [currentTarget setInputFramebuffer:outputFramebuffer atIndex:targetTextureIndex];
        }
        
        [outputFramebuffer unlock];
        
        for (id<GPUImageInput> currentTarget in targets)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger targetTextureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            [currentTarget newFrameReadyAtTime:currentSampleTime atIndex:targetTextureIndex];
        }
        CVPixelBufferUnlockBaseAddress(movieFrame, 0);
    }
    
    if (_runBenchmark)
    {
        CFAbsoluteTime currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime);
        NSLog(@" Current frame time : %f ms", 1000.0 * currentFrameTime);
//		NSLog(@" %@ currentSampleTime :",_asset);
//		CMTimeShow(currentSampleTime);
    }
}

- (void)endProcessing;
{
    keepLooping = NO;
    [displayLink setPaused:YES];

    for (id<GPUImageInput> currentTarget in targets)
    {
        [currentTarget endProcessing];
    }
    
    if (synchronizedMovieWriter != nil)
    {
        [synchronizedMovieWriter setVideoInputReadyCallback:^{return NO;}];
        [synchronizedMovieWriter setAudioInputReadyCallback:^{return NO;}];
    }
    
    if (self.playerItem && (displayLink != nil))
    {
        [displayLink invalidate]; // remove from all run loops
        displayLink = nil;
    }

    if ([self.delegate respondsToSelector:@selector(didCompletePlayingMovie)]) {
        [self.delegate didCompletePlayingMovie];
    }
    self.delegate = nil;
}

- (void)cancelProcessing
{
	self.isCanceled = YES;
	if (self.movieQueue.operationCount == 0 && synchronizedMovieWriter == nil) {
		if (reader) {
			[reader cancelReading];
		}
	}
	
	[self endProcessing];
}

- (void)convertYUVToRGBOutput;
{
    [GPUImageContext setActiveShaderProgram:yuvConversionProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(imageBufferWidth, imageBufferHeight) onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };

    static const GLfloat textureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };

	glActiveTexture(GL_TEXTURE4);
	glBindTexture(GL_TEXTURE_2D, luminanceTexture);
	glUniform1i(yuvConversionLuminanceTextureUniform, 4);

    glActiveTexture(GL_TEXTURE5);
	glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
	glUniform1i(yuvConversionChrominanceTextureUniform, 5);

    glUniformMatrix3fv(yuvConversionMatrixUniform, 1, GL_FALSE, _preferredConversion);

    glVertexAttribPointer(yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
	glVertexAttribPointer(yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (AVAssetReader*)assetReader {
    return reader;
}

- (BOOL)audioEncodingIsFinished {
    return audioEncodingIsFinished;
}

- (BOOL)videoEncodingIsFinished {
    return videoEncodingIsFinished;
}

@end
