//
//  MVBaseAudioFilter.m
//  microChannel
//
//  Created by wangxiaotang on 14-9-10.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "MVBaseAudioFilter.h"

@implementation MVBaseAudioFilter


- (instancetype)initWithInputAudioData:(id)inputAudioData
                  audioDataInformation:(id)audioDataInformation
                       audioFilterType:(MVAudioFilterType) audioFilterType
{
    self = [super init];
    if (self)
    {
        _inputAudioData = inputAudioData;
        _audioDataInformation = audioDataInformation;
        _audioFilterType = audioFilterType;
    }
    return self;
}

- (BOOL)processAudioData:(NSError **)error
{
    return YES;
}

- (id)outputAudioData
{
    return nil;
}

@end
