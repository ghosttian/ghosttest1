//
//  MVVideoEffectColorAdjustmentFilterExcutor.m
//  MVVideoEngine
//
//  Created by ghosttian on 14-12-3.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectColorAdjustmentFilterExcutor.h"
#import "MVVideoColorAdjustmentFilter.h"

@implementation MVVideoEffectColorAdjustmentFilterExcutor

- (Class)getFilterClass{
    return [MVVideoColorAdjustmentFilter class];
}

@end
