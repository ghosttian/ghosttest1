//
//  MVVideoColorPencilPartialFilter.h
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-14.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoCurvePartialFilter.h"
#import "GPUImageThreeInputFilter.h"

@interface MVVideoColorPencilPartialFilter : GPUImageThreeInputFilter
@property(nonatomic,strong)UIImage *modelImage;

- (instancetype)initWithResourceImage:(UIImage *)image;

@end
