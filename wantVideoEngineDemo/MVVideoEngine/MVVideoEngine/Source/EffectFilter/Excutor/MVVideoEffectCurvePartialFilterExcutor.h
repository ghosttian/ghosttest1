//
//  MVVideoEffectCurvePartialFilterExcutor.h
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-14.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEffectFilterExcutor.h"
#import "MVVIdeoCurvePartialFilter.h"

@interface MVVideoEffectCurvePartialFilterExcutor : MVVideoEffectFilterExcutor
@property(nonatomic,strong) MVVideoCurvePartialFilter *curveFilter;

@end
