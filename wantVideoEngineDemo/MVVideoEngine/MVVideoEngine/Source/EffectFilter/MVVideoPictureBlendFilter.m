//
//  MVVideoPictureBlendFilter.m
//  microChannel
//
//  Created by aidenluo on 9/4/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoPictureBlendFilter.h"
#import "GPUImagePicture.h"

@interface MVVideoPictureBlendFilter ()

@end

@implementation MVVideoPictureBlendFilter

- (instancetype)init
{
    self = [super initWithBlendMode:MVVideoBlendFilterModeMix];
    if (self) {

    }
    return self;
}

@end
