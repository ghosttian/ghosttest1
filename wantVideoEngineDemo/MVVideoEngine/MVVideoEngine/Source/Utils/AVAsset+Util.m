//
//  AVAsset+PreviewAddition.m
//  microChannel
//
//  Created by eson on 13-11-26.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "AVAsset+Util.h"
#import <objc/runtime.h>

static char AVAssetSilenceKey;


@implementation AVAsset (Silence)

- (BOOL)isSilence
{
    id object = objc_getAssociatedObject(self, &AVAssetSilenceKey);
    if ([object isKindOfClass:[NSNumber class]]) {
        return [object boolValue];
    }
    return NO;
}

- (void)setSilence:(BOOL)silence
{
    [self willChangeValueForKey:@"isSilence"];
    objc_setAssociatedObject(self,&AVAssetSilenceKey,@(silence),OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"isSilence"];
}

@end

@implementation AVAsset (Util)

CGRect makeRectWithAspectRatioOutsideRect(CGSize aspectRatio, CGRect containerRect)
{
	CGSize scale = CGSizeMake(containerRect.size.width / aspectRatio.width, containerRect.size.height / aspectRatio.height);
	CGFloat maxScale = fmax(scale.width, scale.height);
	
	CGPoint centerPoint = CGPointMake(CGRectGetMidX(containerRect), CGRectGetMidY(containerRect));
	CGSize size = CGSizeMake(aspectRatio.width * maxScale, aspectRatio.height * maxScale);
	return CGRectMake(centerPoint.x - 0.5f * size.width, centerPoint.y - 0.5f * size.height, size.width, size.height);
}

+ (CGSize)maxSizeForImageGeneratorToCropAsset:(AVAsset*)thumbnailAsset toSize:(CGSize)size
{
	CGSize naturalSize = CGSizeZero;
	CGSize naturalSizeTransformed = CGSizeZero;
	
	NSArray *videoTracks = [thumbnailAsset tracksWithMediaType:AVMediaTypeVideo];
	if ( ([videoTracks count] > 0) ) {
		AVAssetTrack *videoTrack = [videoTracks objectAtIndex:0];
		NSArray *formatDescriptions = [videoTrack formatDescriptions];
		if ([formatDescriptions count] > 0) {
			CMVideoFormatDescriptionRef videoFormatDescription = (__bridge CMFormatDescriptionRef)[formatDescriptions objectAtIndex:0];
			naturalSize = CMVideoFormatDescriptionGetPresentationDimensions(videoFormatDescription, YES, YES);
			naturalSizeTransformed = CGSizeApplyAffineTransform (naturalSize, videoTrack.preferredTransform);
			naturalSizeTransformed.width = fabs(naturalSizeTransformed.width);
			naturalSizeTransformed.height = fabs(naturalSizeTransformed.height);
		}
		else {
			return CGSizeZero;
		}
	}
	else {
		return CGSizeZero;
	}
	
	CGRect croppedRect = CGRectZero;
	croppedRect.size = size;
	CGRect containerRect = makeRectWithAspectRatioOutsideRect(naturalSizeTransformed, croppedRect);
	containerRect.origin = CGPointZero;
	containerRect = CGRectIntegral(containerRect);
	
	return containerRect.size;
}

+ (BOOL)addTrackTo:(AVMutableCompositionTrack *)mutableTrack fromAssets:(NSArray *)assets withType:(NSString *)type timeRange:(CMTimeRange)timeRange atTime:(CMTime)insertTime error:(NSError **)error
{
    BOOL added = NO;
    CMTime start = kCMTimeZero;
    CMTime duration = kCMTimeZero;
    CMTime realInsertTime = insertTime;

    Float64 total = 0;
    Float64 lastTotal = 0;
    Float64 rangeStart = CMTimeGetSeconds(timeRange.start);
    Float64 rangeEnd = CMTimeGetSeconds(timeRange.duration);
    rangeEnd = rangeEnd + rangeStart;
    for (int i = 0; i < [assets count]; ++i) {
        
        AVAsset *anAsset = [assets objectAtIndex:i];
        NSArray *trackArray = [anAsset tracksWithMediaType:type];
        AVAssetTrack *aTrack = [trackArray lastObject];
        
        CMTimeRange aRange = CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
        total = total + CMTimeGetSeconds(anAsset.duration);
        if (total <= rangeStart) {
            
            lastTotal = total;
            continue;
        }
        Float64 curStart = 0;
        if (lastTotal >= rangeStart) {
            
            start = kCMTimeZero;
        }else{
            
            curStart = rangeStart - lastTotal;
            start = CMTimeMakeWithSeconds(curStart, anAsset.duration.timescale);
        }
        
        if (total > rangeEnd) {
            
            Float64 curEnd = rangeEnd - lastTotal;
            if (lastTotal < rangeStart) {
                
                curEnd = curEnd - curStart;
            }
            duration = CMTimeMakeWithSeconds(curEnd, anAsset.duration.timescale);
            aRange = CMTimeRangeMake(start, duration);
        }else{
            
            CMTimeRange range = CMTimeRangeMake(kCMTimeZero, anAsset.duration);
            aRange = CMTimeRangeFromTimeToTime(start, CMTimeRangeGetEnd(range));
        }
    
        if (!aTrack || ([anAsset isSilence] && [type isEqualToString:AVMediaTypeAudio])) {
            
            [mutableTrack insertEmptyTimeRange:CMTimeRangeMake(realInsertTime, aRange.duration)];
            added = YES;
        }else{
            
            added = [mutableTrack insertTimeRange:aRange ofTrack:aTrack atTime:realInsertTime error:error];
        }

        realInsertTime = CMTimeAdd(realInsertTime, aRange.duration);
        lastTotal = total;
        //防止精度随机值导致计算失误
        if ((total + 0.001) >= rangeEnd) {
            
            break;
        }
    }
    
    NSError *er = nil;
    if (![mutableTrack validateTrackSegments:mutableTrack.segments error:&er]) {
        
        NSLog(@"~~~~~~~~%@", er);
    }
    return added;
}

@end
