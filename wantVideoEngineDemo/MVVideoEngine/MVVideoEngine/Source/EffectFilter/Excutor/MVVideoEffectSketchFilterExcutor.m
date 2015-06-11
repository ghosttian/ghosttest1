//
//  MVVideoEffectSketchFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-19.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectSketchFilterExcutor.h"
#import "MVVideoSketchFilter.h"

@interface MVVideoEffectSketchFilterExcutor ()

@property(nonatomic,strong) GPUImagePicture *picture;
@property(nonatomic,strong) MVVideoSketchFilter *sketchFilter;

@end

@implementation MVVideoEffectSketchFilterExcutor

- (Class)getFilterClass
{
    return [MVVideoSketchFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.sketchFilter ) {
        return self.sketchFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.sketchFilter = (MVVideoSketchFilter *)filter;
    if (self.sketchFilter.sketchImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.sketchFilter.sketchImage];
        [self.picture addTarget:self.sketchFilter atTextureLocation:1];
        [self.sketchFilter disableSecondFrameCheck];
        [self.picture processImage];
    }
    return self.sketchFilter;
}

@end
