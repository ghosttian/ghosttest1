//
//  MVBaseAudioFilter.h
//  microChannel
//
//  Created by wangxiaotang on 14-9-10.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_OPTIONS(NSInteger, MVAudioFilterType)
{
    MVAudioFilterNoneType = 0,
    MVAudioFilterComposeTimelineType = 1 << 0,
    MVAudioFilterVoiceChangeType = 1 << 1
};

@interface MVBaseAudioFilter : NSObject

@property (nonatomic, readonly, strong) id inputAudioData;

@property (nonatomic, readonly, strong) id audioDataInformation;

@property (nonatomic, readonly, assign) MVAudioFilterType audioFilterType;


- (instancetype)initWithInputAudioData:(id)inputAudioData
                  audioDataInformation:(id)audioDataInformation
                       audioFilterType:(MVAudioFilterType) audioFilterType;

- (BOOL)processAudioData:(NSError **)error;

- (id)outputAudioData;

@end
