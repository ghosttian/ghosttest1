//
//  MVVideoEffectAttractFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-19.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectAttractFilterExcutor.h"
#import "MVVideoAttractFilter.h"

@interface MVVideoEffectAttractFilterExcutor ()

@property(nonatomic,strong)MVVideoAttractFilter *attractFilter;
@property(nonatomic,strong)GPUImagePicture *picture;

@end

@implementation MVVideoEffectAttractFilterExcutor

- (Class)getFilterClass{
    return [MVVideoAttractFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.attractFilter ) {
        return self.attractFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.attractFilter = (MVVideoAttractFilter *)filter;
    if (self.attractFilter.modelImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.attractFilter.modelImage];
        [self.picture addTarget:self.attractFilter atTextureLocation:1];
        [self.attractFilter disableSecondFrameCheck];
        [self.picture processImage];
    }
    return self.attractFilter;
}

@end
