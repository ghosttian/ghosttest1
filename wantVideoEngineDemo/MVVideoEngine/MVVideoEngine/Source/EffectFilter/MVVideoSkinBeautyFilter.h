//
//  MVVideoSkinBeautyFilter.h
//  microChannel
//
//  Created by aidenluo on 9/12/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface MVVideoSkinBeautyFilter : GPUImageTwoInputFilter

@property(nonatomic) float factor;
@property(nonatomic) float red;
@property(nonatomic) float green;
@property(nonatomic) float blue;

@end
