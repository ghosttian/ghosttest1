//
//  MVVideoEffectSketchPartialFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-19.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectSketchPartialFilterExcutor.h"
#import "MVVideoSketchPartialFilter.h"

@interface MVVideoEffectSketchPartialFilterExcutor ()

@property(nonatomic,strong)MVVideoSketchPartialFilter *sketchPartailFilter;
@property(nonatomic,strong)GPUImagePicture *picture;

@end

@implementation MVVideoEffectSketchPartialFilterExcutor

- (Class)getFilterClass{
    return [MVVideoSketchPartialFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.sketchPartailFilter ) {
        return self.sketchPartailFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.sketchPartailFilter = (MVVideoSketchPartialFilter *)filter;
    if (self.sketchPartailFilter.modelImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.sketchPartailFilter.modelImage];
        [self.picture addTarget:self.sketchPartailFilter atTextureLocation:1];
        [self.picture processImage];
    }
    return self.sketchPartailFilter;
}

@end
