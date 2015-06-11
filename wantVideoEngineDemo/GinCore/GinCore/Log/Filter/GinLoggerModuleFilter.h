//
//  GinLoggerModuleFilter.h
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GinLoggerFilterSkeleton.h"
#import "GinLoggerDef.h"

@interface GinLoggerModuleFilter : GinLoggerFilterSkeleton

- (NSString *)getModuleNameWithModuleType:(LogModuleType)aModuleType;

@end
