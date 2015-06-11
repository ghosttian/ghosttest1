//
//  MVVideoEffectFilterExcutor.h
//  microChannel
//
//  Created by aidenluo on 9/2/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "MVVideoEffectFilterFactory.h"
#import "MAMediaTimingFunction.h"
#import "NSDictionary+Util.h"

@protocol MVVideoEffectFilterExcutorProtocol <NSObject>

- (GPUImageOutput <GPUImageInput> *)getFilter;
- (void)updateExcutorTime:(CFTimeInterval)time;

@end

@interface MVVideoEffectFilterAnimationData : NSObject

@property(nonatomic) CFTimeInterval time;

@end

@interface MVVideoEffectFilterExcutor : NSObject<MVVideoEffectFilterExcutorProtocol>

@property(nonatomic,strong) NSArray *animationPath;
@property(nonatomic,strong) NSDictionary *filterConfig;
@property(nonatomic,assign) NSInteger filterId;
@property(nonatomic,assign) CFTimeInterval excutorStartTime;
@property(nonatomic,strong) MAMediaTimingFunction *interpolation;
@property(nonatomic,assign) BOOL isLocalFilter;//局部滤镜

+ (MVVideoEffectFilterExcutor *)createFilterExcutorWithAnimationPath:(NSArray *)animationPath
                                                        filterConfig:(NSDictionary *)filterConfig
                                                            filterId:(NSInteger)filterId
                                                    excutorStartTime:(CFTimeInterval)excutorStartTime
                                                            videoURL:(NSString *)videoURLString;
- (BOOL)findStartAnimationData:(MVVideoEffectFilterAnimationData **)startAnimationData
              endAnimationData:(MVVideoEffectFilterAnimationData **)endAnimationData
                        atTime:(CFTimeInterval)time
              inAnimationArray:(NSArray *)array;
- (Class)getFilterClass;
- (GPUImageFilter *)getFilter;

@end
