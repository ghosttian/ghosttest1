//
//  MVVideoColorPencilFilter.h
//  microChannel
//
//  Created by aidenluo on 9/10/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface MVVideoColorPencilFilter : GPUImageTwoInputFilter
@property(nonatomic,strong)UIImage *modelImage;

- (instancetype)initWithResourceImage:(UIImage *)image;

@end
