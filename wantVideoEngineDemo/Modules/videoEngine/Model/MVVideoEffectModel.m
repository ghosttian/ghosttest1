//
//  MVVideoEffectModel.m
//  microChannel
//
//  Created by aidenluo on 8/29/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectModel.h"
#import "MVVideoEffectDefines.h"

@implementation MVVideoEffectModel

- (void)dealloc
{
    // Do nothing
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _musicVolume = 1.0f;
        _isSilent = NO;
        _filterID = [NSString stringWithFormat:@"%@", @(MVConfigurationNone)];
        _beautyFilterID = [NSString stringWithFormat:@"%@", @(MVConfigurationNone)];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"originPath:%@\neffectPath:%@\nbeautyPath:%@\nfinalPath:%@",self.originVideoPath,self.effectVideoPath,self.beautyVideoPath,self.finalVideoPath];
}

@end
