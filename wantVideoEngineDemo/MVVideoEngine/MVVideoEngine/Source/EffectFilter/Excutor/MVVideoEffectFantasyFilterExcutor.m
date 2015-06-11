//
//  MVVideoEffectFantasyFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-19.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectFantasyFilterExcutor.h"
#import "MVVideoFantasyFilter.h"

@interface MVVideoEffectFantasyFilterExcutor ()

@property(nonatomic,strong)MVVideoFantasyFilter *fantasyFilter;
@property(nonatomic,strong)GPUImagePicture *picture;

@end

@implementation MVVideoEffectFantasyFilterExcutor

- (Class)getFilterClass{
    return [MVVideoFantasyFilter class];
}

- (GPUImageFilter *)getFilter
{
    if (self.fantasyFilter ) {
        return self.fantasyFilter;
    }
    GPUImageFilter *filter = [super getFilter];
    if (!filter) {
        return nil;
    }
    self.fantasyFilter = (MVVideoFantasyFilter *)filter;
    if (self.fantasyFilter.modelImage) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.fantasyFilter.modelImage];
        [self.picture addTarget:self.fantasyFilter atTextureLocation:1];
        [self.fantasyFilter disableSecondFrameCheck];
        [self.picture processImage];
    }
    return self.fantasyFilter;
}

@end
