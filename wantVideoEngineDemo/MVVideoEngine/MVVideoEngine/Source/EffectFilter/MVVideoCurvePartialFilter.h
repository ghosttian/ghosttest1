//
//  MVVideoCurvePartialFilter.h
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-13.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEngine.h"
#import "GPUImageThreeInputFilter.h"

@interface MVVideoCurvePartialFilter : GPUImageThreeInputFilter
@property(nonatomic,strong) UIImage *curveImage;
- (instancetype)initWithMatix:(GPUMatrix4x4)matrix resourceImage:(UIImage *)image;

@end
