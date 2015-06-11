//
//  MVVideoEffectSCBFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/22/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectSCBFilterExcutor.h"
#import "MVVideoSCBFilter.h"
#import "NSDictionary+Util.h"

@interface MVVideoEffectSCBFilterExcutor ()

@property(nonatomic,strong) MVVideoSCBFilter *scbFilter;

@end

@implementation MVVideoEffectSCBFilterExcutor

- (Class)getFilterClass
{
    return [MVVideoSCBFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.scbFilter) {
        return self.scbFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.scbFilter = (MVVideoSCBFilter *)filter;
    float s = 0.0;
    float c = 0.0;
    float b = 0.0;
    if (self.filterConfig) {
        if ([self.filterConfig objectForKey:@"s"]) {
            s = [self.filterConfig mvFloatValueForKey:@"s"];
        }
        if ([self.filterConfig objectForKey:@"c"]) {
            c = [self.filterConfig mvFloatValueForKey:@"c"];
        }
        if ([self.filterConfig objectForKey:@"b"]) {
            b = [self.filterConfig mvFloatValueForKey:@"b"];
        }
    }
    [self.scbFilter setSaturation:s + 1];
    [self.scbFilter setFilterContrast:c + 1];
    [self.scbFilter setBrightness:b + 1];
    return self.scbFilter;
}

@end
