//
//  GinUploadCoachBase.h
//  microChannel
//
//  Created by joeqiwang on 14-3-20.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GinUploadCoachBase : NSObject

@property (nonatomic, assign) unsigned long long totalSize;
@property (nonatomic, assign) unsigned long long uploadedOffset;

- (unsigned long long)getPackageSizeByPreviousSize:(unsigned long long)preSize andElapseTime:(double)duration;

@end
