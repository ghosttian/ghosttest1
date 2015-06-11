//
//  MVVideoCurveFilter.h
//  microChannel
//
//  Created by aidenluo on 9/3/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "GPUImage.h"

@interface MVVideoCurveFilter : GPUImageTwoInputFilter

@property(nonatomic,strong) UIImage *curveImage;
+ (UIImage *)decodeImageByName:(NSString *)name;
- (instancetype)initWithMatix:(GPUMatrix4x4)matrix resourceImage:(UIImage *)image;

@end
