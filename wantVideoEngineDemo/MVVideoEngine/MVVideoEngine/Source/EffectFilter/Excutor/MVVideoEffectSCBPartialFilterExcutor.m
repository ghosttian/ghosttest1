//
//  MVVideoEffectSCBPartialFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-14.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectSCBPartialFilterExcutor.h"
#import "MVVIdeoSCBPartialFilter.h"
#import "NSDictionary+Util.h"

@interface MVVideoEffectSCBPartialFilterExcutor ()

@property(nonatomic,strong)MVVIdeoSCBPartialFilter *scbFilter;

@end

@implementation MVVideoEffectSCBPartialFilterExcutor

- (Class)getFilterClass
{
    return [MVVIdeoSCBPartialFilter class];
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
    self.scbFilter = (MVVIdeoSCBPartialFilter *)filter;
    if (self.filterConfig) {
        if ([self.filterConfig objectForKey:@"s"]) {
            float s = [self.filterConfig mvFloatValueForKey:@"s"];
            [self.scbFilter setSaturation:s + 1];
        }
        if ([self.filterConfig objectForKey:@"c"]) {
            float c = [self.filterConfig mvFloatValueForKey:@"c"];
            [self.scbFilter setFilterContrast:c + 1];
        }
        if ([self.filterConfig objectForKey:@"b"]) {
            float b = [self.filterConfig mvFloatValueForKey:@"b"];
            [self.scbFilter setBrightness:b + 1];
        }
    }
    return self.scbFilter;
}

@end
