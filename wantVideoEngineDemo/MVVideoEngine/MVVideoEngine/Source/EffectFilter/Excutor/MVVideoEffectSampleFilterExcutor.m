//
//  MVVideoEffectSampleFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/15/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectSampleFilterExcutor.h"

@interface MVVideoEffectSampleFilterExcutor ()

@property(nonatomic,strong) GPUImageOutput<GPUImageInput> *sampleFilter;

@end

@implementation MVVideoEffectSampleFilterExcutor

- (GPUImageOutput<GPUImageInput> *)getFilter
{
    if(self.sampleFilter) {
        return self.sampleFilter;
    }
    GPUImageOutput<GPUImageInput> *filter = nil;
    switch (self.filterId) {
        case 11044://重影
        {
            filter = [[GPUImageLowPassFilter alloc] init];
            break;
        }
        default:
        {
            filter = [super getFilter];
            break;
        }
    }
    if (!filter) {
        return nil;
    }
    self.sampleFilter = filter;
    return filter;
}

@end
