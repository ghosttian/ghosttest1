//
//  MVVideoEffect.h
//  SimpleVideoFileFilter
//
//  Created by eson on 14-9-2.
//  Copyright (c) 2014年 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MVVideoEffect : NSObject

@property (nonatomic, assign) NSInteger         filterId;
@property (nonatomic, assign) NSInteger         stageId;

@property (nonatomic, assign) CFTimeInterval start;
@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, assign) CFTimeInterval speed;
@property (nonatomic, assign) CFTimeInterval cut;

@property (nonatomic, strong) NSArray *inputStageIDs;
@property (nonatomic, strong) NSDictionary *filterConfig;
@property (nonatomic, strong) NSArray      *animationPath;
@property (nonatomic, strong) NSArray	   *resourceMaps;

@property (nonatomic, strong) NSString *videoURLString;
@property (nonatomic, assign) CFTimeInterval materialVideoStart;
@property (nonatomic, assign) BOOL isMaterialVideoReferSelf;

@property (nonatomic, assign) BOOL isLogoStage;

- (BOOL)isValidForTime:(CFTimeInterval)time;
- (BOOL)isStaticFrame;
- (CFTimeInterval)caculatedVideoDuration;

@end
