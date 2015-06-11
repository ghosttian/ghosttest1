//
//  MVVideoSCBFilter.h
//  microChannel
//
//  Created by aidenluo on 9/22/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "GPUImageFilter.h"

@interface MVVideoSCBFilter : GPUImageFilter

@property(nonatomic) float filterContrast;
@property(nonatomic) float saturation;
@property(nonatomic) float brightness;

@end
