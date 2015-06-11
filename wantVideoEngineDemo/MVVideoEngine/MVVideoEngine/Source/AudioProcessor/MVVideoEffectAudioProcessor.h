//
//  MVVideoEffectAudioProcessor.h
//  microChannel
//
//  Created by aidenluo on 8/29/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class MVVideoEffectPlayerModel;
@class MVAudioProcessorResult;

typedef void(^completionHandler)(MVAudioProcessorResult *result, NSError *error);

@interface MVVideoEffectAudioProcessor : NSObject

- (instancetype)init;
- (void)processAudio:(AVMutableComposition *)composition
        resourceData:(MVVideoEffectPlayerModel *)effectModel
            complete:(void (^)(AVMutableComposition *resultComposition,AVAudioMix *audioMix,NSError *error))completionHandler;
- (BOOL)processAudioWithResourceData:(MVVideoEffectPlayerModel *)effectModel
                       audioDuration:(CFTimeInterval)duration
                               error:(NSError **)error;

- (BOOL)processAudioWithResourceData:(MVVideoEffectPlayerModel *)effectModel
                       audioDuration:(CFTimeInterval)duration
                           timelines:(NSArray *)timeLines
                               error:(NSError **)error;

- (MVAudioProcessorResult *)outputAudioResult;


@end
