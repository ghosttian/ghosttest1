//
//  MVVideoOffsetFilter.h
//  microChannel
//
//  Created by aidenluo on 9/1/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "GPUImageFilter.h"

@interface MVVideoOffsetFilter : GPUImageFilter

@property(nonatomic,assign) float offsetX;
@property(nonatomic,assign) float offsetY;
@property(nonatomic,assign) int followType;//0为不跟随 1为水平跟随 2为竖直跟随
@property(nonatomic,assign) float followGap;

@end
