//
//  MVAssetReaderWraper.m
//  microChannel
//
//  Created by eson on 14-9-9.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "MVAssetReaderWraper.h"
#import "AVAsset+Util.h"
#import "GPUImage.h"

static NSString * const kStatusKey = @"status";
static NSString * const kTracksKey = @"tracks";
static NSString * const kPlayableKey = @"playable";

@interface MVAssetReaderWraper () <AVPlayerItemOutputPullDelegate>
{

}
@property (nonatomic, strong) AVAssetReader     *assetReader;
@property (nonatomic, strong) AVAsset           *asset;

@property (nonatomic, assign) CMSampleBufferRef lastSampleBufferRef;
@property (nonatomic, assign) NSTimeInterval    currentTime;

@end

@implementation MVAssetReaderWraper

- (void)dealloc
{
	[self cancelProcess];
    [self releaseLastSampleBufferRef];
}

- (void)releaseLastSampleBufferRef
{
	self.lastSampleBufferRef = NULL;
}

- (void)setLastSampleBufferRef:(CMSampleBufferRef)lastSampleBufferRef
{
	if (_lastSampleBufferRef) {
		CMSampleBufferInvalidate (_lastSampleBufferRef);
		CFRelease(_lastSampleBufferRef);
	}
	if (lastSampleBufferRef) {
		CFRetain(lastSampleBufferRef);
	}
	_lastSampleBufferRef = lastSampleBufferRef;
}

- (instancetype)initWithAsset:(AVAsset *)asset
{
    if (self = [super init]) {
		self.asset = asset;
		self.currentTime = - 1;// invalidation
	}
    
    return self;
}

- (BOOL)startProcess
{
	if (self.asset) {
        return [self processAsset];
	}
	
	return NO;
}

- (void)cancelProcess
{
	[self releaseLastSampleBufferRef];


    if (self.assetReader.status == AVAssetReaderStatusReading) {
        [self.assetReader cancelReading];
    }

	[_asset cancelLoading];

	_currentTime = - 1;// invalidation
	_assetReader = nil;
}


#pragma mark - Private

- (BOOL)processAsset
{
    if (!self.assetReader) {
        self.assetReader = [self createAssetReader];
		if (self.assetReader) {
			[self addTrackOutputs];
		}
		if (!self.assetReader || self.assetReader.outputs.count == 0 || ![self.assetReader startReading]) {
			return NO;
		}
    }
	
	return YES;
}

- (AVAssetReader *)createAssetReader
{
    NSError       *error = nil;
	NSArray * videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
	AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:self.asset error:&error];

	if (videoTracks.count > 0 && !error) {
		CMTime start = CMTimeMake(self.readerStartTime * self.asset.duration.timescale, self.asset.duration.timescale);
		CMTime duration = CMTimeSubtract(self.asset.duration, start);
		if (duration.value > 0 && start.value > 0) {
			assetReader.timeRange = CMTimeRangeMake(start, duration);
		}
	} else {
		assetReader = nil;
	}
	return assetReader;
}

- (void)addTrackOutputs
{
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionary];
    
    [outputSettings setObject:@(kCVPixelFormatType_32BGRA) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	
	NSArray * videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
	if (videoTracks.count == 0) {
		return;
	}
    // Maybe set alwaysCopiesSampleData to NO on iOS 5.0 for faster video decoding
    AVAssetReaderTrackOutput *readerVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTracks.firstObject outputSettings:outputSettings];
    readerVideoTrackOutput.alwaysCopiesSampleData = NO;
    
    if ([self.assetReader canAddOutput:readerVideoTrackOutput]) {
        [self.assetReader addOutput:readerVideoTrackOutput];
    }
}

- (CGImageRef)copySampleCGImageRefAtTime:(NSTimeInterval)time
{
	CGImageRef imageRef = [[self class]copyImageRefFromCMSampleBuffer:[self copySampleBufferAtTime:time]];
	return imageRef;
}

- (CMSampleBufferRef)copySampleBufferAtTime:(NSTimeInterval)time
{
	NSTimeInterval readerBackwardsSeekMinDurationGap = 0.05;
	if (self.asset && CMTimeGetSeconds(_asset.duration) <= 1.5) { //less duration asset will drop less buffer
		readerBackwardsSeekMinDurationGap = 0.01;
	}

	if ((time < self.currentTime) && fabs(time - self.currentTime) > readerBackwardsSeekMinDurationGap && _assetReader != nil) {
		//read previous buffer need create new reader,so it is hang
		NSLog(@"read previous buffer time %f currentTime %f",time,self.currentTime);

		[self cancelProcess];
		
		NSTimeInterval readerStartTime = self.readerStartTime;
		self.readerStartTime = time;
		[self startProcess];
		self.readerStartTime = readerStartTime;
	}
	
	if (self.lastSampleBufferRef) {
		self.currentTime = CMTimeGetSeconds(CMSampleBufferGetOutputPresentationTimeStamp(self.lastSampleBufferRef));
		
		 if (self.currentTime >= time) {
			 return self.lastSampleBufferRef;
		 }

	}
	
	AVAssetReaderOutput *readerVideoTrackOutput = nil;
	
	for (AVAssetReaderOutput *output in self.assetReader.outputs) {
		if ([output.mediaType isEqualToString:AVMediaTypeVideo]) {
			readerVideoTrackOutput = output;
		}
	}
	
    while (self.currentTime < time && self.assetReader.status == AVAssetReaderStatusReading) {
        @autoreleasepool {
            CMSampleBufferRef sampleBufferRef = [readerVideoTrackOutput copyNextSampleBuffer];
            
            CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBufferRef);
			if (sampleBufferRef) {
				self.currentTime = CMTimeGetSeconds(currentSampleTime);
			}
			
			self.lastSampleBufferRef = sampleBufferRef; //will retain

			if (sampleBufferRef) {
				CFRelease(sampleBufferRef);
			}

			if (!self.lastSampleBufferRef) {
				break;
			}
        }
    }
    
    return self.lastSampleBufferRef;
}

+ (CGImageRef)copyImageRefFromCMSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
	CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	return [self copyImageRefFromCVPixelBufferRef:imageBuffer];
}

+ (CGImageRef)copyImageRefFromCVPixelBufferRef:(CVPixelBufferRef)imageBuffer
{
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
	
	if (width <= 0 || height <= 0) {
		return NULL;
	}
	
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (!colorSpace) {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
    
    // Get the base address of the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize,
                                                              NULL);
    // Create a bitmap image from data supplied by our data provider
    CGImageRef cgImage =
    CGImageCreate(width,
                  height,
                  8,
                  32,
                  bytesPerRow,
                  colorSpace,
                  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  provider,
                  NULL,
                  true,
                  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return cgImage;
}

@end
