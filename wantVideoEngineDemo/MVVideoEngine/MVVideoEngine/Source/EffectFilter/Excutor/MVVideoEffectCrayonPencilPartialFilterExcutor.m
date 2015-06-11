//
//  MVVideoEffectCrayonPencilPartialFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-19.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectCrayonPencilPartialFilterExcutor.h"
#import "MVVideoCrayonPencilPartialFilter.h"

@implementation MVVideoEffectCrayonPencilPartialFilterExcutor

- (Class)getFilterClass{
    return [MVVideoCrayonPencilPartialFilter class];
}

@end
