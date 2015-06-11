//
//  MVVideoEffectFilterFactory.h
//  microChannel
//
//  Created by aidenluo on 9/1/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPUImageFilter;
@interface MVVideoEffectFilterFactory : NSObject

+ (GPUImageFilter *)createFilterByFilterId:(NSInteger)filterId
                              filterConfig:(NSDictionary *)filterConfig
                                     Local:(BOOL)isLocalFilter;

@end
