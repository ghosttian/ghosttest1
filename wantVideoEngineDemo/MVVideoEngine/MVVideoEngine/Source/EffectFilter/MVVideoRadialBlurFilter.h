//
//  MVVideoRadialBlurFilter.h
//  microChannel
//
//  Created by ghosttian on 14-11-4.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GPUImageFilter.h"

@interface MVVideoRadialBlurFilter : GPUImageFilter

@property(nonatomic,assign)float separation;
@property(nonatomic,assign)float radius;
@property(nonatomic,assign)float x;
@property(nonatomic,assign)float y;

@end
