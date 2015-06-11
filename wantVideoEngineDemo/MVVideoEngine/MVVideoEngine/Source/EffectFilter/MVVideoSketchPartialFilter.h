//
//  MVVideoSketchPartialFilter.h
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-19.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEngine.h"
#import "GPUImageThreeInputFilter.h"

@interface MVVideoSketchPartialFilter : GPUImageThreeInputFilter

@property(nonatomic,strong)UIImage *modelImage;
- (instancetype)initWithResourceImage:(UIImage *)image;

@end
