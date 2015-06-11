//
//  MVVideoEffectAdvancedCurveRGBPartialFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-14.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectAdvancedCurveRGBPartialFilterExcutor.h"
#import "MVVideoAdvancedCurveRGBPartialFilter.h"

@interface MVVideoEffectAdvancedCurveRGBPartialFilterExcutor ()

@property(nonatomic,strong) MVVideoAdvancedCurveRGBPartialFilter *curveFilter;
@property(nonatomic) GPUImagePicture *picture;

@end

@implementation MVVideoEffectAdvancedCurveRGBPartialFilterExcutor

- (Class)getFilterClass
{
    return [MVVideoAdvancedCurveRGBPartialFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.curveFilter) {
        return self.curveFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.curveFilter = (MVVideoAdvancedCurveRGBPartialFilter *)filter;
    if (self.curveFilter.curveImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.curveFilter.curveImage];
        [self.picture addTarget:self.curveFilter atTextureLocation:1];
        [self.picture processImage];
    }
    return self.curveFilter;
}

@end
