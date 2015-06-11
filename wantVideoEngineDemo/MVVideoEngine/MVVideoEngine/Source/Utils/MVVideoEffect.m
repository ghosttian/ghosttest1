//
//  MVVideoEffect.m
//  SimpleVideoFileFilter
//
//  Created by eson on 14-9-2.
//  Copyright (c) 2014年 Cell Phone. All rights reserved.
//

#import "MVVideoEffect.h"
#import "MVVideoEffectDefine.h"

@implementation MVVideoEffect

- (CFTimeInterval)caculatedVideoDuration
{
	if (_speed <= kMVVideoEffectTimeRangeSpeedMinThreshold) {
		return _duration;
	}
	return _duration / _speed;
}

- (BOOL)isStaticFrame
{
	BOOL isStaticFrame = _speed <= kMVVideoEffectTimeRangeSpeedMinThreshold;
	return isStaticFrame;
}

- (BOOL)isValidForTime:(CFTimeInterval)time
{
	BOOL isValidForTime = NO;
	if (self.start <= time && self.caculatedVideoDuration + self.start >= time) {
		isValidForTime = YES;
		if (self.cut > 0 && time - self.start > self.cut) { //末尾截断
			isValidForTime = NO;
		}
	}
	
	return isValidForTime;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];

    [description appendFormat:@"%@ ", [super description]];
    [description appendFormat:@"_stageId:%ld ", (long)_stageId];
    [description appendFormat:@"_filterId:%ld ", (long)_filterId];
    [description appendFormat:@"_start:%f ", _start];
    [description appendFormat:@"_duration:%f ", _duration];
    [description appendFormat:@"_speed:%f ", _speed];
    [description appendFormat:@"caculatedVideoDuration:%f ", [self caculatedVideoDuration]];

    if (_videoURLString.length) {
        [description appendFormat:@"\n_videoURLString : %@", _videoURLString];
    }

    return description;
}


@end
