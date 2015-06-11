//
//  MVVideoCurveRGBPartialFilter.h
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-13.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEngine.h"
#import "GPUImageThreeInputFilter.h"

@interface MVVideoCurveRGBPartialFilter : GPUImageThreeInputFilter
@property(nonatomic,strong) UIImage *curveImage;
-(instancetype)initWithCut:(BOOL)cutWithAlpha picture:(UIImage *)image;

@end
