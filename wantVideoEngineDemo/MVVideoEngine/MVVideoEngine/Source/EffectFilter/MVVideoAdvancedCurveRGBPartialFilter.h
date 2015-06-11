//
//  MVVideoAdvancedCurveRGBPartialFilter.h
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-14.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEngine.h"
#import "GPUImageThreeInputFilter.h"

@interface MVVideoAdvancedCurveRGBPartialFilter : GPUImageThreeInputFilter

@property(nonatomic,strong) UIImage *curveImage;

-(instancetype)initWithPicture:(UIImage *)image;

@end
