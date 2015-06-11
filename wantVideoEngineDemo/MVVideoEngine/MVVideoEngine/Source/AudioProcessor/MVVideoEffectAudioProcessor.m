//
//  MVVideoEffectAudioProcessor.m
//  microChannel
//
//  Created by aidenluo on 8/29/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectAudioProcessor.h"
#import "MVAudioProcessorResult.h"
#import "MVVideoEffectDefine.h"
#import "MVVideoEffectPlayerModel.h"
#import "AVAsset+Util.h"

static int32_t const kMVVideoEditExportPreferredTimeScale = 600;

@interface MVVideoEffectAudioProcessor()

@property (nonatomic, strong)NSMutableArray *filters;

@property (nonatomic, strong)MVAudioProcessorResult *audioResult;

@end

static const NSInteger musicAudioMixInputParametersVolumeRampDuration = 1.5;

@implementation MVVideoEffectAudioProcessor


- (instancetype)init
{
    self = [super init];
    if (self){
        //Do nothing
    }
    return self;
}

- (void)processAudio:(AVMutableComposition *)composition
        resourceData:(MVVideoEffectPlayerModel *)effectModel
            complete:(void (^)(AVMutableComposition *resultComposition,AVAudioMix *audioMix,NSError *error))completionHandler
{
    AVMutableCompositionTrack *compositionVideoTrack = nil;
    AVMutableCompositionTrack *compositionAudioTrack = nil;
    AVMutableCompositionTrack *compositionMusicTrack = nil;

    CMPersistentTrackID videoTrackID = MVEffectVideoCompositionTrackPreferredTrackIDOriginVideo;
    CMPersistentTrackID audioTrackID = MVEffectVideoCompositionTrackPreferredTrackIDOriginAudio;
    CMPersistentTrackID musicTrackID = MVEffectVideoCompositionTrackPreferredTrackIDMixMusicAudio;

    
    compositionVideoTrack = (AVMutableCompositionTrack *)[composition trackWithTrackID:videoTrackID];
    compositionAudioTrack = (AVMutableCompositionTrack *)[composition trackWithTrackID:audioTrackID];
    
    Float64 videoDuration = CMTimeGetSeconds(compositionVideoTrack.timeRange.duration);
    if (videoDuration < 1.95f)
    {
        //Temp error
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:10000 userInfo:nil];
        if (completionHandler)
        {
            completionHandler(nil,nil,error);
        }
        return;
    }
    
    //配乐
    if (effectModel.musicPath != nil)
    {
        NSURL *musicURL = [NSURL fileURLWithPath:effectModel.musicPath];
        AVURLAsset *musicAsset = [[AVURLAsset alloc] initWithURL:musicURL options:nil];
        AVAssetTrack *musicTrack = nil;
        NSArray *musicTrackArray = [musicAsset tracksWithMediaType:AVMediaTypeAudio];
        if (musicTrackArray && [musicTrackArray count] > 0)
        {
            musicTrack = [musicTrackArray objectAtIndex:0];
        }
        
        if (musicTrack != nil)
        {
            
            BOOL success = YES;
            NSError *error = nil;
            
            AVMutableCompositionTrack *compositionTrack = (AVMutableCompositionTrack *)[composition trackWithTrackID:musicTrackID];
            if (compositionTrack) {
                [composition removeTrack:compositionTrack];
            }
            
            compositionMusicTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                             preferredTrackID:musicTrackID];
            
            Float64 musicDuration = CMTimeGetSeconds(musicTrack.timeRange.duration);
            

            if (videoDuration <= musicDuration)
            {
                CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(videoDuration, kMVVideoEditExportPreferredTimeScale));
                success = [compositionMusicTrack insertTimeRange:timeRange
                                                         ofTrack:musicTrack
                                                          atTime:kCMTimeZero
                                                           error:&error];
            }
            else
            {
                int result = videoDuration / musicDuration;
                NSMutableArray *timeRanges = [NSMutableArray array];
                NSMutableArray *tracks = [NSMutableArray array];
                
                for (int i = 0; i < result; i++) {
                    NSValue *timeRangeValue = [NSValue valueWithCMTimeRange:musicTrack.timeRange];
                    [timeRanges addObject:timeRangeValue];
                    [tracks addObject:musicTrack];
                }
                
                Float64 subtractValue = videoDuration - musicDuration * result;
                if (subtractValue > 0.5f) { //小于0.5秒忽略
                    
                    CMTime timeDuration = CMTimeMakeWithSeconds(subtractValue, kMVVideoEditExportPreferredTimeScale);
                    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, timeDuration);
                    NSValue *timeRangeValue = [NSValue valueWithCMTimeRange:timeRange];
                    [timeRanges addObject:timeRangeValue];
                    [tracks addObject:musicTrack];
                }
                
                success = [compositionMusicTrack insertTimeRanges:timeRanges
                                                         ofTracks:tracks
                                                           atTime:kCMTimeZero
                                                            error:&error];
                
                
            }
            
            if (!success)
            {
                if (completionHandler) {
                    completionHandler(nil, nil, error);
                }
                return;
            }
        }
    }
   
    //处理静音和音坡
    NSMutableArray *audioMixArray = [NSMutableArray array];
    if (effectModel.isSilent) // 静音
    {
        if (compositionAudioTrack)
        {
            AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTrack];
            [parameters setVolume:0.0f atTime:kCMTimeZero];
            [audioMixArray addObject:parameters];
        }
        
        if (compositionMusicTrack)
        {
            AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionMusicTrack];
            [parameters setVolume:effectModel.musicVolume atTime:kCMTimeZero];
            
            Float64 musicDuration = CMTimeGetSeconds(compositionMusicTrack.timeRange.duration);
            CMTimeRange allRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(musicDuration, kMVVideoEditExportPreferredTimeScale));
            NSTimeInterval rampDuration = musicAudioMixInputParametersVolumeRampDuration;
            CMTime timeDuration = CMTimeMakeWithSeconds(rampDuration, kMVVideoEditExportPreferredTimeScale);
            CMTime timeStart = CMTimeSubtract(allRange.duration, timeDuration);
            @try {
                if (CMTIME_IS_VALID(timeStart)) {
                    [parameters setVolumeRampFromStartVolume:effectModel.musicVolume
                                                 toEndVolume:0.0f
                                                   timeRange:CMTimeRangeMake(timeStart, timeDuration)];
                    [audioMixArray addObject:parameters];
                }
            }
            @catch (NSException *exception) {
                // Do nothing
            }
            @finally {
                // Do nothing
            }
        }
        
    }
    else
    {
        //musicVolume只是对音乐起作用
        if (compositionMusicTrack)
        {
            AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionMusicTrack];
            [parameters setVolume:effectModel.musicVolume atTime:kCMTimeZero];
            
            Float64 musicDuration = CMTimeGetSeconds(compositionMusicTrack.timeRange.duration);
            CMTimeRange allRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(musicDuration, kMVVideoEditExportPreferredTimeScale));
            NSTimeInterval rampDuration = musicAudioMixInputParametersVolumeRampDuration;
            CMTime timeDuration = CMTimeMakeWithSeconds(rampDuration, kMVVideoEditExportPreferredTimeScale);
            CMTime timeStart = CMTimeSubtract(allRange.duration, timeDuration);
            @try {
                if (CMTIME_IS_VALID(timeStart)) {
                    [parameters setVolumeRampFromStartVolume:effectModel.musicVolume
                                                 toEndVolume:0.0f
                                                   timeRange:CMTimeRangeMake(timeStart, timeDuration)];
                    [audioMixArray addObject:parameters];
                }
            }
            @catch (NSException *exception) {
                // Do nothing
            }
            @finally {
                // Do nothing
            }
        }
    }
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = audioMixArray;
    
    if (completionHandler) {
        completionHandler(composition,audioMix,nil);
    }
}

- (BOOL)processAudioWithResourceData:(MVVideoEffectPlayerModel *)effectModel
                       audioDuration:(CFTimeInterval)duration
                               error:(NSError **)error
{
    self.audioResult = nil;
    if (duration < 1.95) {
        return NO;
    }
    
    AVAsset *videoAsset = nil;
    if (effectModel.originAsset) {
        videoAsset = effectModel.originAsset;
    }else{
        NSURL *videoAssetURL = [NSURL fileURLWithPath:effectModel.originVideoPath];
        videoAsset = [[AVURLAsset alloc] initWithURL:videoAssetURL options:nil];
    }

    AVMutableComposition *audioMutableComposition = [AVMutableComposition composition];
    
    //原声或者带有配乐
    NSArray *audioTrackArray = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
    for (AVAssetTrack *audioTrack in audioTrackArray)
    {
        int trackID = audioTrack.trackID;
        if (trackID != MVEffectVideoCompositionTrackPreferredTrackIDOriginAudio &&
            trackID != MVEffectVideoCompositionTrackPreferredTrackIDMixMusicAudio)
        {
            trackID = MVEffectVideoCompositionTrackPreferredTrackIDOriginAudio;
        }
        
        AVMutableCompositionTrack *compositionAudioTrack = nil;
        compositionAudioTrack = [audioMutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                     preferredTrackID:trackID];
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, audioTrack.timeRange.duration);
        
        BOOL success = [compositionAudioTrack insertTimeRange:timeRange
                                                      ofTrack:audioTrack
                                                       atTime:kCMTimeZero
                                                        error:error];
        if (!success) {
            return success;
        }
    }
    
    //配乐
    if (effectModel.musicPath != nil)
    {
        NSURL *musicURL = [NSURL fileURLWithPath:effectModel.musicPath];
        AVURLAsset *musicAsset = [[AVURLAsset alloc] initWithURL:musicURL options:nil];
        AVAssetTrack *musicTrack = nil;
        NSArray *musicTrackArray = [musicAsset tracksWithMediaType:AVMediaTypeAudio];
        if (musicTrackArray && [musicTrackArray count] > 0)
        {
            musicTrack = [musicTrackArray objectAtIndex:0];
        }
        
        if (musicTrack != nil)
        {
            
            AVMutableCompositionTrack *compositionTrack = (AVMutableCompositionTrack *)[audioMutableComposition trackWithTrackID:MVEffectVideoCompositionTrackPreferredTrackIDMixMusicAudio];
            if (compositionTrack) {
                [audioMutableComposition removeTrack:compositionTrack];
            }
            
            AVMutableCompositionTrack *musicCompositionTrack = nil;
            int musicTrackID = MVEffectVideoCompositionTrackPreferredTrackIDMixMusicAudio;
            musicCompositionTrack = [audioMutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                         preferredTrackID:musicTrackID];
            
            Float64 musicDuration = CMTimeGetSeconds(musicTrack.timeRange.duration);
            
            BOOL success = YES;
            if (duration <= musicDuration) {
                CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(duration, kMVVideoEditExportPreferredTimeScale));
                success = [musicCompositionTrack insertTimeRange:timeRange
                                                              ofTrack:musicTrack
                                                               atTime:kCMTimeZero
                                                                error:error];
            }
            else
            {
                int result = duration / musicDuration;
                NSMutableArray *timeRanges = [NSMutableArray array];
                NSMutableArray *tracks = [NSMutableArray array];
                
                for (int i = 0; i < result; i++) {
                    NSValue *timeRangeValue = [NSValue valueWithCMTimeRange:musicTrack.timeRange];
                    [timeRanges addObject:timeRangeValue];
                    [tracks addObject:musicTrack];
                }
                
                Float64 subtractValue = duration - musicDuration * result; //musicDuration - duration * result;
                if (subtractValue > 0.5f) { //小于0.5秒忽略
                    
                    CMTime timeDuration = CMTimeMakeWithSeconds(subtractValue, kMVVideoEditExportPreferredTimeScale);
                    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, timeDuration);
                    NSValue *timeRangeValue = [NSValue valueWithCMTimeRange:timeRange];
                    [timeRanges addObject:timeRangeValue];
                    [tracks addObject:musicTrack];
                }
                
                success = [musicCompositionTrack insertTimeRanges:timeRanges
                                                         ofTracks:tracks
                                                           atTime:kCMTimeZero
                                                            error:error];
                
                
            }
            
            if (!success) {
                return success;
            }
        }
    }
    
    //处理静音和音坡
    NSMutableArray *audioMixArray = [NSMutableArray array];
    
    int originalAudioTrackID = MVEffectVideoCompositionTrackPreferredTrackIDOriginAudio;
    int musicTrackID = MVEffectVideoCompositionTrackPreferredTrackIDMixMusicAudio;
    AVAssetTrack *orignalCompositionAudioTrack = nil;
    AVAssetTrack *musicCompositionAudioTrack = nil;
    
    orignalCompositionAudioTrack = [audioMutableComposition trackWithTrackID:originalAudioTrackID];
    musicCompositionAudioTrack = [audioMutableComposition trackWithTrackID:musicTrackID];
    
    if (effectModel.isSilent) // 静音
    {
        if (orignalCompositionAudioTrack)
        {
            AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:orignalCompositionAudioTrack];
            [parameters setVolume:0.0f atTime:kCMTimeZero];
            [audioMixArray addObject:parameters];
        }
        
        if (musicCompositionAudioTrack)
        {
            AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:musicCompositionAudioTrack];
            [parameters setVolume:effectModel.musicVolume atTime:kCMTimeZero];
            
            Float64 musicDuration = CMTimeGetSeconds(musicCompositionAudioTrack.timeRange.duration);
            CMTimeRange allRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(musicDuration, kMVVideoEditExportPreferredTimeScale));
            NSTimeInterval rampDuration = musicAudioMixInputParametersVolumeRampDuration;
            CMTime timeDuration = CMTimeMakeWithSeconds(rampDuration, kMVVideoEditExportPreferredTimeScale);
            CMTime timeStart = CMTimeSubtract(allRange.duration, timeDuration);
            @try {
                if (CMTIME_IS_VALID(timeStart)) {
                    [parameters setVolumeRampFromStartVolume:effectModel.musicVolume
                                                 toEndVolume:0.0f
                                                   timeRange:CMTimeRangeMake(timeStart, timeDuration)];
                    [audioMixArray addObject:parameters];
                }
            }
            @catch (NSException *exception) {
                // Do nothing
            }
            @finally {
                // Do nothing
            }
        }
        
    }
    else
    {
        //musicVolume只是对音乐起作用
        if (musicCompositionAudioTrack)
        {
            AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:musicCompositionAudioTrack];
            [parameters setVolume:effectModel.musicVolume atTime:kCMTimeZero];
            
            Float64 musicDuration = CMTimeGetSeconds(musicCompositionAudioTrack.timeRange.duration);
            CMTimeRange allRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(musicDuration, kMVVideoEditExportPreferredTimeScale));
            NSTimeInterval rampDuration = musicAudioMixInputParametersVolumeRampDuration;
            CMTime timeDuration = CMTimeMakeWithSeconds(rampDuration, kMVVideoEditExportPreferredTimeScale);
            CMTime timeStart = CMTimeSubtract(allRange.duration, timeDuration);
            @try {
                if (CMTIME_IS_VALID(timeStart)) {
                    [parameters setVolumeRampFromStartVolume:effectModel.musicVolume
                                                 toEndVolume:0.0f
                                                   timeRange:CMTimeRangeMake(timeStart, timeDuration)];
                    [audioMixArray addObject:parameters];
                }
            }
            @catch (NSException *exception) {
                // Do nothing
            }
            @finally {
                // Do nothing
            }
        }
    }
    
    self.audioResult = [[MVAudioProcessorResult alloc] init];
    self.audioResult.mutableComposition = audioMutableComposition;
    self.audioResult.mutableAudioMix = [AVMutableAudioMix audioMix];
    self.audioResult.mutableAudioMix.inputParameters = audioMixArray;
    
    return YES;
}

- (BOOL)processAudioWithResourceData:(MVVideoEffectPlayerModel *)effectModel
                       audioDuration:(CFTimeInterval)duration
                           timelines:(NSArray *)timeLines
                               error:(NSError **)error
{
    self.audioResult = nil;
    if (duration < 1.95) {
        return NO;
    }
    
    AVAsset *videoAsset = nil;
    if (effectModel.originAsset) {
        videoAsset = effectModel.originAsset;
    }else{
        NSURL *videoAssetURL = [NSURL fileURLWithPath:effectModel.originVideoPath];
        videoAsset = [[AVURLAsset alloc] initWithURL:videoAssetURL options:nil];
    }
    
    AVMutableCompositionTrack *compositionAudioTrack = nil;
    AVMutableComposition *audioMutableComposition = [AVMutableComposition composition];
    compositionAudioTrack = [audioMutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                 preferredTrackID:MVEffectVideoCompositionTrackPreferredTrackIDOriginAudio];
    
    //原声或者带有配乐
    NSArray *audioTrackArray = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
    for (AVAssetTrack *audioTrack in audioTrackArray)
    {
        int trackID = audioTrack.trackID;
        if (trackID != MVEffectVideoCompositionTrackPreferredTrackIDOriginAudio &&
            trackID != MVEffectVideoCompositionTrackPreferredTrackIDMixMusicAudio)
        {
            trackID = MVEffectVideoCompositionTrackPreferredTrackIDOriginAudio;
        }
        
        //只对原音做处理
        if (trackID == MVEffectVideoCompositionTrackPreferredTrackIDOriginAudio) {
            CMTimeRange timeRange;
//            AVMutableCompositionTrack *compositionAudioTrack = nil;
//            compositionAudioTrack = [audioMutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio
//                                                                         preferredTrackID:trackID];
            if (timeLines && [timeLines count] > 0)
            {
                //插入开始时间
                CMTime insertTime = kCMTimeZero;
                //原始音频的长度
                Float64 originAudioAssertDuration = CMTimeGetSeconds(audioTrack.timeRange.duration);
                //设置timescale
                CMTimeScale originAudioAssertTimeScale = audioTrack.timeRange.duration.timescale;
                CMTimeScale timescale = (originAudioAssertTimeScale > 0) ? originAudioAssertTimeScale : kMVVideoEditExportPreferredTimeScale;
                
                for (NSDictionary *timeinfo in timeLines) {
                    
                    NSNumber *startNumber = [timeinfo objectForKey:@"start"];
                    NSNumber *durationNumber = [timeinfo objectForKey:@"duration"];
                    NSNumber *staticFrame = [timeinfo objectForKey:@"staticframe"];
                    NSNumber *speedNumber = [timeinfo objectForKey:@"speed"];
                    
                    CFTimeInterval start = [startNumber doubleValue];
                    if (start < 0) {
                        start = originAudioAssertDuration + start; // start 为负数的情况
                    }
                    CFTimeInterval length = [durationNumber doubleValue];
                    BOOL isStaticFrame = [staticFrame boolValue];
                    CFTimeInterval speed = [speedNumber doubleValue];
                    
                    if (!isStaticFrame) { //抽帧
                        
                        if (start > originAudioAssertDuration) {
                            // 跳过
                            continue;
                            
                        }
                        else if ((start + length*speed) > originAudioAssertDuration )
                        {
                            
                            length = (originAudioAssertDuration - start)/speed;
                            
                        }else{
                            //
                            length = length;
                        }
                        
                        if (speed >= 0.6 && speed <= 1.40) {
                            // 插入原始音频
                            CMTime startTime = CMTimeMakeWithSeconds(start, timescale);
                            CMTime durationTime = CMTimeMakeWithSeconds(length, timescale);
                            CMTimeRange timeRange = CMTimeRangeMake(startTime, durationTime);
                            
                            BOOL success = NO;
                            if ([videoAsset isKindOfClass:[AVMutableComposition class]])
                            {
                                success = [AVAsset addTrackTo:compositionAudioTrack
                                                   fromAssets:effectModel.combineAssets
                                                     withType:AVMediaTypeAudio
                                                    timeRange:timeRange
                                                       atTime:insertTime
                                                        error:nil];
                            }
                            else
                            {
                                success = [compositionAudioTrack insertTimeRange:timeRange
                                                                         ofTrack:audioTrack
                                                                          atTime:insertTime
                                                                           error:nil];
                            }
                            
                            if (success)
                            {
                                CFTimeInterval startDuration = CMTimeGetSeconds(insertTime);
                                CFTimeInterval addDuration = CMTimeGetSeconds(timeRange.duration);
                                insertTime = CMTimeMakeWithSeconds(startDuration + addDuration, timescale);
                            }
                            else
                            {
                                return success;
                            }
                            
                        }else{
                            //插入空白音频
                            CMTime startTime = insertTime;//CMTimeMakeWithSeconds(start, timescale);
                            CMTime durationTime = CMTimeMakeWithSeconds(length, timescale);
                            CMTimeRange timeRange = CMTimeRangeMake(startTime, durationTime);
                            [compositionAudioTrack insertEmptyTimeRange:timeRange];
                            insertTime = CMTimeAdd(startTime, durationTime);
                            
                        }
                    }
                    else
                    { //定帧
                        
                        if (start > originAudioAssertDuration)
                        {
                            continue;
                        }
                        else
                        {
                            //插入空白音频
                            CMTime startTime = insertTime;//CMTimeMakeWithSeconds(start, timescale);
                            CMTime durationTime = CMTimeMakeWithSeconds(length, timescale);
                            CMTimeRange timeRange = CMTimeRangeMake(startTime, durationTime);
                            [compositionAudioTrack insertEmptyTimeRange:timeRange];
                            insertTime = CMTimeAdd(startTime, durationTime);
                        }
                    }
                }
            }
            else
            {
               timeRange = CMTimeRangeMake(kCMTimeZero, audioTrack.timeRange.duration);
                BOOL success = [compositionAudioTrack insertTimeRange:timeRange
                                                              ofTrack:audioTrack
                                                               atTime:kCMTimeZero
                                                                error:error];
                if (!success) {
                    return success;
                }
            }
        }
    }
    
    //配乐
    if (effectModel.musicPath != nil)
    {
        NSURL *musicURL = [NSURL fileURLWithPath:effectModel.musicPath];
        AVURLAsset *musicAsset = [[AVURLAsset alloc] initWithURL:musicURL options:nil];
        AVAssetTrack *musicTrack = nil;
        NSArray *musicTrackArray = [musicAsset tracksWithMediaType:AVMediaTypeAudio];
        if (musicTrackArray && [musicTrackArray count] > 0)
        {
            musicTrack = [musicTrackArray objectAtIndex:0];
        }
        
        if (musicTrack != nil)
        {
            
            AVMutableCompositionTrack *compositionTrack = (AVMutableCompositionTrack *)[audioMutableComposition trackWithTrackID:MVEffectVideoCompositionTrackPreferredTrackIDMixMusicAudio];
            if (compositionTrack) {
                [audioMutableComposition removeTrack:compositionTrack];
            }
            
            AVMutableCompositionTrack *musicCompositionTrack = nil;
            int musicTrackID = MVEffectVideoCompositionTrackPreferredTrackIDMixMusicAudio;
            musicCompositionTrack = [audioMutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                         preferredTrackID:musicTrackID];
            
            Float64 musicDuration = CMTimeGetSeconds(musicTrack.timeRange.duration);
            
            BOOL success = YES;
            if (duration <= musicDuration) {
                CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(duration, kMVVideoEditExportPreferredTimeScale));
                success = [musicCompositionTrack insertTimeRange:timeRange
                                                         ofTrack:musicTrack
                                                          atTime:kCMTimeZero
                                                           error:error];
            }
            else
            {
                int result = duration / musicDuration;
                NSMutableArray *timeRanges = [NSMutableArray array];
                NSMutableArray *tracks = [NSMutableArray array];
                
                for (int i = 0; i < result; i++) {
                    NSValue *timeRangeValue = [NSValue valueWithCMTimeRange:musicTrack.timeRange];
                    [timeRanges addObject:timeRangeValue];
                    [tracks addObject:musicTrack];
                }
                
                Float64 subtractValue = duration - musicDuration * result; //musicDuration - duration * result;
                if (subtractValue > 0.5f) { //小于0.5秒忽略
                    
                    CMTime timeDuration = CMTimeMakeWithSeconds(subtractValue, kMVVideoEditExportPreferredTimeScale);
                    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, timeDuration);
                    NSValue *timeRangeValue = [NSValue valueWithCMTimeRange:timeRange];
                    [timeRanges addObject:timeRangeValue];
                    [tracks addObject:musicTrack];
                }
                
                success = [musicCompositionTrack insertTimeRanges:timeRanges
                                                         ofTracks:tracks
                                                           atTime:kCMTimeZero
                                                            error:error];
                
                
            }
            
            if (!success) {
                return success;
            }
        }
    }
    
    //处理静音和音坡
    NSMutableArray *audioMixArray = [NSMutableArray array];
    
    int originalAudioTrackID = MVEffectVideoCompositionTrackPreferredTrackIDOriginAudio;
    int musicTrackID = MVEffectVideoCompositionTrackPreferredTrackIDMixMusicAudio;
    AVAssetTrack *orignalCompositionAudioTrack = nil;
    AVAssetTrack *musicCompositionAudioTrack = nil;
    
    orignalCompositionAudioTrack = [audioMutableComposition trackWithTrackID:originalAudioTrackID];
    musicCompositionAudioTrack = [audioMutableComposition trackWithTrackID:musicTrackID];
    
    if (effectModel.isSilent) // 静音
    {
        if (orignalCompositionAudioTrack)
        {
            AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:orignalCompositionAudioTrack];
            [parameters setVolume:0.0f atTime:kCMTimeZero];
            [audioMixArray addObject:parameters];
        }
        
        if (musicCompositionAudioTrack)
        {
            AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:musicCompositionAudioTrack];
            [parameters setVolume:effectModel.musicVolume atTime:kCMTimeZero];
            
            Float64 musicDuration = CMTimeGetSeconds(musicCompositionAudioTrack.timeRange.duration);
            CMTimeRange allRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(musicDuration, kMVVideoEditExportPreferredTimeScale));
            NSTimeInterval rampDuration = musicAudioMixInputParametersVolumeRampDuration;
            CMTime timeDuration = CMTimeMakeWithSeconds(rampDuration, kMVVideoEditExportPreferredTimeScale);
            CMTime timeStart = CMTimeSubtract(allRange.duration, timeDuration);
            @try {
                if (CMTIME_IS_VALID(timeStart)) {
                    [parameters setVolumeRampFromStartVolume:effectModel.musicVolume
                                                 toEndVolume:0.0f
                                                   timeRange:CMTimeRangeMake(timeStart, timeDuration)];
                    [audioMixArray addObject:parameters];
                }
            }
            @catch (NSException *exception) {
                // Do nothing
            }
            @finally {
                // Do nothing
            }
        }
        
    }
    else
    {
        //musicVolume只是对音乐起作用
        if (musicCompositionAudioTrack)
        {
            AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:musicCompositionAudioTrack];
            [parameters setVolume:effectModel.musicVolume atTime:kCMTimeZero];
            
            Float64 musicDuration = CMTimeGetSeconds(musicCompositionAudioTrack.timeRange.duration);
            CMTimeRange allRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(musicDuration, kMVVideoEditExportPreferredTimeScale));
            NSTimeInterval rampDuration = musicAudioMixInputParametersVolumeRampDuration;
            CMTime timeDuration = CMTimeMakeWithSeconds(rampDuration, kMVVideoEditExportPreferredTimeScale);
            CMTime timeStart = CMTimeSubtract(allRange.duration, timeDuration);
            @try {
                if (CMTIME_IS_VALID(timeStart)) {
                    [parameters setVolumeRampFromStartVolume:effectModel.musicVolume
                                                 toEndVolume:0.0f
                                                   timeRange:CMTimeRangeMake(timeStart, timeDuration)];
                    [audioMixArray addObject:parameters];
                }
            }
            @catch (NSException *exception) {
                // Do nothing
            }
            @finally {
                // Do nothing
            }
        }
    }
    
    self.audioResult = [[MVAudioProcessorResult alloc] init];
    self.audioResult.mutableComposition = audioMutableComposition;
    self.audioResult.mutableAudioMix = [AVMutableAudioMix audioMix];
    self.audioResult.mutableAudioMix.inputParameters = audioMixArray;
    
    return YES;
}

- (MVAudioProcessorResult *)outputAudioResult
{
    return self.audioResult;
}


@end
