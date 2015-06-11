//
//  MVVideoEffectParser.h
//  SimpleVideoFileFilter
//
//  Created by eson on 14-9-2.
//  Copyright (c) 2014年 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MVVideoEffectDefine.h"
#import <UIKit/UIKit.h>

@protocol MVVideoEffectParserDelegate <NSObject>

@optional
- (UIImage *)createWaterMarkImageByData:(NSArray *)data;

@end

@interface MVVideoEffectParser : NSObject

@property (nonatomic, strong) NSMutableArray * timelineVideoEffects;
@property (nonatomic, strong) NSMutableArray * normalVideoEffects;
@property (nonatomic, assign) NSTimeInterval compositionDuration;

- (void)parseEffectWithConfigUserData:(NSDictionary *)userData originVideoDuration:(CFTimeInterval)originVideoDuration;
+ (void)setEffectParserDelegate:(id)delegate;

@end
