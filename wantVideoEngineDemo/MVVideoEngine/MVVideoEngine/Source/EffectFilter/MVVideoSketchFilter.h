//
//  MVVideoSketchFilter.h
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-19.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEngine.h"
#import "GPUImageTwoInputFilter.h"

@interface MVVideoSketchFilter : GPUImageTwoInputFilter
@property(nonatomic,strong) UIImage *sketchImage;

- (instancetype)initWithResourceImage:(UIImage *)image;

@end
