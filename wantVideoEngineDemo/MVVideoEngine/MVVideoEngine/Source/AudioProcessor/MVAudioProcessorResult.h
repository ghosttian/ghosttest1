//
//  MVAudioProcessorResult.h
//  microChannel
//
//  Created by wangxiaotang on 14-9-10.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVMutableComposition;
@class AVMutableAudioMix;

@interface MVAudioProcessorResult : NSObject

@property (nonatomic, strong)AVMutableComposition *mutableComposition;
@property (nonatomic, strong)AVMutableAudioMix *mutableAudioMix;

@end
