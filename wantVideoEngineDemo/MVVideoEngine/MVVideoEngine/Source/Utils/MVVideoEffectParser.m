//
//  MVVideoEffectParser.m
//  SimpleVideoFileFilter
//
//  Created by eson on 14-9-2.
//  Copyright (c) 2014年 Cell Phone. All rights reserved.
//

#import "MVVideoEffectParser.h"
#import "UIImage+Util.h"
#import "NSDictionary+Util.h"
#import "NSString+Util.h"
#import "AVAsset+Util.h"
//#import "MVWaterMarkFactory.h"
#import "MVVideoEffect.h"

@interface MVVideoEffectParser ()

@end

@implementation MVVideoEffectParser

- (instancetype)init
{
	if (self = [super init]) {
		_timelineVideoEffects = [NSMutableArray array];
		_normalVideoEffects = [NSMutableArray array];
	}
	return self;
}

- (void)parseEffectWithConfigUserData:(NSDictionary *)userData originVideoDuration:(CFTimeInterval)originVideoDuration
{
	NSDictionary *filterData = [userData mvDictionaryValueForKey:kMVVideoEffectParserKeyFilterData];

	NSArray * resourceArray = [filterData mvArrayValueForKey:kMVVideoEffectParserKeyResourceMap];
	NSMutableDictionary *allResourceMap = [NSMutableDictionary dictionary];
	for (NSDictionary *resourceDictionary in resourceArray) {
		id resource = [resourceDictionary objectForKey:kMVVideoEffectParserKeyURL];
        if (!resource) {
            resource = [resourceDictionary objectForKey:kMVVideoEffectParserKeyWatermark];          
        }
		NSString * idString = [resourceDictionary mvStringValueForKey:kMVVideoEffectParserKeyResourceID];
		if (resource && idString) {
			[allResourceMap setObject:resource forKey:idString];
		}
	}
	
	NSMutableArray *stageArray = [[filterData mvArrayValueForKey:kMVVideoEffectParserKeyStageArray] mutableCopy];
		
	if (filterData.count == 0 && [userData objectForKey:kMVVideoEffectParserKeyFilterType]) { //simple filter
		MVVideoEffect *effect = [[MVVideoEffect alloc]init];
		effect.duration = originVideoDuration;
		effect.speed = 1;
		effect.filterId = [userData mvIntValueForKey:kMVVideoEffectParserKeyFilterType];
		[_timelineVideoEffects addObject:effect];
		[_normalVideoEffects addObject:effect];
	}
	
	self.compositionDuration = 0; //抽帧之后的视频长度
	NSMutableDictionary *startStringMap = [NSMutableDictionary dictionary];

	for (NSDictionary *effectDic in stageArray) {
		MVVideoEffect *effect = [[MVVideoEffect alloc]init];

		effect.resourceMaps = [filterData mvArrayValueForKey:kMVVideoEffectParserKeyResourceMap];
		effect.animationPath = [effectDic mvArrayValueForKey:kMVVideoEffectParserKeyAnimationPath];
		effect.filterConfig = [effectDic mvDictionaryValueForKey:kMVVideoEffectParserKeyFilterConfig];
		
		effect.stageId = [effectDic mvIntValueForKey:kMVVideoEffectParserKeyStageID];
		effect.filterId = [effectDic mvIntValueForKey:kMVVideoEffectParserKeyFilterID];
		
		NSDictionary* timeRangeDic = [effectDic mvDictionaryValueForKey:kMVVideoEffectParserKeyTimeRange];
		NSString * startString = [timeRangeDic mvStringValueForKey:kMVVideoEffectParserKeyStart];
		effect.start = parseStartTimeWithDuration(startString,originVideoDuration);
		effect.speed = [timeRangeDic mvFloatValueForKey:kMVVideoEffectParserKeySpeed];
		effect.speed = effect.speed <= 0 ? 1 : effect.speed;

		[startStringMap setObject:startString forKey:@(effect.stageId)];
		effect.duration = [timeRangeDic mvFloatValueForKey:kMVVideoEffectParserKeyLength];
		if (effect.filterId == kMVVideoEffectTimeLineFilterID) {
			if (effect.start >= originVideoDuration) {
				continue;//不合法的抽帧
			}
			if (![effect isStaticFrame]) { //普通抽帧长度限制
				effect.duration = MIN(effect.duration, originVideoDuration - effect.start);
			}
		}

		effect.cut = [timeRangeDic mvFloatValueForKey:kMVVideoEffectParserKeyCut];
		if (effect.cut < 0) {
			effect.cut = effect.cut + effect.caculatedVideoDuration;
		}
		
		if ([effect.filterConfig objectForKey:kMVVideoEffectParserKeyInputID]) {
			effect.inputStageIDs = [effect.filterConfig mvArrayValueForKey:kMVVideoEffectParserKeyInputID];
		}
				
		NSString *videoReferIDString = [effect.filterConfig mvStringValueForKey:kMVVideoEffectParserKeyVideo];
		NSString *videoReferID = [videoReferIDString stringByReplacingOccurrencesOfString:@"#" withString:@""];
		NSString *materialVideoStartString = [effect.filterConfig mvStringValueForKey:kMVVideoEffectParserKeyVideoStart];
		effect.materialVideoStart = parseStartTimeWithDuration(materialVideoStartString, originVideoDuration);
		NSTimeInterval  materialVideoDuration = 0;
		if (videoReferID.length) {
			effect.videoURLString = [allResourceMap mvStringValueForKey:videoReferID];
			NSString *materialVideoPath = [NSString getResourcePathIfExistWithURL:effect.videoURLString];
			if (materialVideoPath) {
				AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:materialVideoPath]];
				materialVideoDuration = CMTimeGetSeconds(asset.duration);
			}
		} else if ([videoReferIDString isEqualToString:kMVVideoEffectParserValueSelfRefer]) {
			effect.isMaterialVideoReferSelf = YES;
			materialVideoDuration = originVideoDuration;
		}
		if (materialVideoStartString.length > 0 && (effect.videoURLString.length > 0 || effect.isMaterialVideoReferSelf)) {
			effect.materialVideoStart = parseStartTimeWithDuration(materialVideoStartString, materialVideoDuration);
		}

		NSString *pictureReferID = [[effect.filterConfig mvStringValueForKey:kMVVideoEffectParserKeyPicture] stringByReplacingOccurrencesOfString:@"#" withString:@""];
		if (pictureReferID.length) {
            id pictureReferObject = [allResourceMap objectForKey:pictureReferID];
			UIImage *picture = [self parsePictureReferObject:pictureReferObject];
            NSMutableDictionary *config = [NSMutableDictionary dictionaryWithDictionary:effect.filterConfig];
            if ([config objectForKey:kMVVideoEffectParserKeyPicture] && picture) {
                [config setObject:picture forKey:kMVVideoEffectParserKeyPicture];
                effect.filterConfig = [NSDictionary dictionaryWithDictionary:config];
            } else {
				NSLog(@"picture is empty effectDic %@ pictureReferID %@",effectDic,pictureReferID);
			}
		}
        
        NSString *curveReferID = [[effect.filterConfig mvStringValueForKey:kMVVideoEffectParserKeyCurve] stringByReplacingOccurrencesOfString:@"#" withString:@""];
        if (curveReferID.length) {
            curveReferID = [allResourceMap mvStringValueForKey:curveReferID];
            NSMutableDictionary *config = [NSMutableDictionary dictionaryWithDictionary:effect.filterConfig];
            if ([config objectForKey:kMVVideoEffectParserKeyCurve] && curveReferID) {
                [config setObject:curveReferID forKey:kMVVideoEffectParserKeyCurve];
                effect.filterConfig = [NSDictionary dictionaryWithDictionary:config];
            }
        }
		
		if (effect.filterId == kMVVideoEffectTimeLineFilterID) {
			[_timelineVideoEffects addObject:effect];
			self.compositionDuration += [effect caculatedVideoDuration];
		}else {
			[_normalVideoEffects addObject:effect];
		}
	}
	
	if (self.compositionDuration == 0) {
		self.compositionDuration = originVideoDuration;
	}
	
	[_normalVideoEffects enumerateObjectsUsingBlock:^(MVVideoEffect *effect, NSUInteger idx, BOOL *stop) {
		NSTimeInterval fixedStart = parseStartTimeWithDuration(startStringMap[@(effect.stageId)], self.compositionDuration);
		if (fixedStart != effect.start) {
			effect.start = fixedStart;
		}
		NSTimeInterval duration = (self.compositionDuration - effect.start) * effect.speed;
		effect.duration = MIN(effect.duration, duration);
	}];
	
	[_normalVideoEffects sortUsingComparator:[self comparatorForMVEffectSort]];
	[_timelineVideoEffects sortUsingComparator:[self comparatorForMVEffectSort]];
}

- (UIImage *)parsePictureReferObject:(id)pictureReferObject
{
	UIImage *picture = nil;
	if ([pictureReferObject isKindOfClass:[NSString class]]) {
		NSString *picturePath = (NSString *)pictureReferObject;
		picture = [UIImage imageWithContentsOfFile:[NSString getResourcePathIfExistWithURL:picturePath]];
	} else if ([pictureReferObject isKindOfClass:[NSArray class]]) {
        if ([_delegate respondsToSelector:@selector(createWaterMarkImageByData:)]) {
            NSArray *data = (NSArray *)pictureReferObject;
            picture = [_delegate createWaterMarkImageByData:data];
        }
	}
	return picture;
}

CFTimeInterval parseStartTimeWithDuration(NSString* startString, CFTimeInterval duration)
{
    if (startString.length <= 0) {
        return 0.0;
    }
    float start = [startString floatValue];
    if ([startString hasSuffix:kMVVideoEffectParserValuePercentFlag]) {
        start *= 0.01 * duration;
    }
	start = MAX(0, start < 0 ? duration + start : start);

    return start;
}

- (NSComparator)comparatorForMVEffectSort
{
	NSComparator comparator = ^NSComparisonResult(MVVideoEffect *effect1, MVVideoEffect *effect2) {
		return effect1.stageId - effect2.stageId;
	};
	return comparator;
}

//need refact

static __weak id _delegate = nil;

+ (void)setEffectParserDelegate:(id)delegate
{
    _delegate = delegate;
}

@end
