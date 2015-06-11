//
//  MVVideoCurveRGBFilter.h
//  microChannel
//
//  Created by aidenluo on 9/4/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface MVVideoCurveRGBFilter : GPUImageTwoInputFilter

@property(nonatomic,strong) UIImage *curveImage;
-(instancetype)initWithCut:(BOOL)cutWithAlpha picture:(UIImage *)image;

@end
