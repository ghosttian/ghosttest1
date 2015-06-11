//
//  MVVideoTransformFilter.h
//  microChannel
//
//  Created by aidenluo on 9/2/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "GPUImageTransformFilter.h"

typedef NS_ENUM(NSInteger, MVVideoTransformFilterType)
{
    MVVideoTransformFilterScaleOnly,
    MVVideoTransformFilterRotateOnly,
    MVVideoTransformFilterScaleAndRotate
};

@interface MVVideoTransformFilter : GPUImageTransformFilter

@property(nonatomic) MVVideoTransformFilterType type;

@end
