//
//  MVVideoAdvancedCurveRGBFilter.h
//  microChannel
//
//  Created by aidenluo on 9/22/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface MVVideoAdvancedCurveRGBFilter : GPUImageTwoInputFilter

@property(nonatomic,strong) UIImage *curveImage;

-(instancetype)initWithPicture:(UIImage *)image;

@end
