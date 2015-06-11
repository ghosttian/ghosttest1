//
//  AVAsset+PreviewAddition.h
//  microChannel
//
//  Created by eson on 13-11-26.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAsset (Silence)

- (BOOL)isSilence;
- (void)setSilence:(BOOL)silence;

@end

@interface AVAsset (Util)

+ (CGSize)maxSizeForImageGeneratorToCropAsset:(AVAsset*)thumbnailAsset toSize:(CGSize)size;

+ (BOOL)addTrackTo:(AVMutableCompositionTrack *)mutableTrack fromAssets:(NSArray *)assets withType:(NSString *)type timeRange:(CMTimeRange)timeRange atTime:(CMTime)insertTime error:(NSError **)error;

@end
