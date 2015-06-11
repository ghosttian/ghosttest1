//
//  MVVideoEffectColorPencilPartialFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-14.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectColorPencilPartialFilterExcutor.h"
#import "MVVideoColorPencilPartialFilter.h"

@interface MVVideoEffectColorPencilPartialFilterExcutor ()

@property(nonatomic,strong) MVVideoColorPencilPartialFilter *colorPencilFilter;
@property(nonatomic,strong) GPUImagePicture *picture;

@end

@implementation MVVideoEffectColorPencilPartialFilterExcutor

- (Class)getFilterClass
{
    return [MVVideoColorPencilPartialFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.colorPencilFilter ) {
        return self.colorPencilFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.colorPencilFilter = (MVVideoColorPencilPartialFilter *)filter;
    if (self.colorPencilFilter.modelImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.colorPencilFilter.modelImage];
        [self.picture addTarget:self.colorPencilFilter atTextureLocation:1];
        [self.picture processImage];
    }
    return self.colorPencilFilter;
}

@end
