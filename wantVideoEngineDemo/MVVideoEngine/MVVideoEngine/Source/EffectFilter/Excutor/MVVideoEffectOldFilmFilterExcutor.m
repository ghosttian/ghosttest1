//
//  MVVideoEffectOldFilmFilterExcutor.m
//  microChannel
//
//  Created by aidenluo on 9/11/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoEffectOldFilmFilterExcutor.h"
#import "MVVideoOldFilmFilter.h"

@implementation MVVideoEffectOldFilmFilterExcutor

- (Class)getFilterClass
{
    return [MVVideoOldFilmFilter class];
}

- (void)updateExcutorTime:(CFTimeInterval)time
{
    static int r = 0;
    static int used = 12;
    static int useCnt = 5;
    static float fluc = 0.04;
    if ((++ used) > useCnt) {
        used = 0;
        r = (arc4random() % 10);
        r -= 5;
        useCnt = 6 + (r % 4);
        //
        
        fluc = arc4random() % 40000000;
        fluc *= 0.000000001;
    }
    MVVideoOldFilmFilter *filter = (MVVideoOldFilmFilter *)self.curveFilter;
    [filter setNosiyPoint1:CGPointMake((67.0 + r)/100.0, (77.0 + r)/100.0)];
    [filter setNosiyPoint2:CGPointMake((88.0 + r)/100.0, (66.0 + r)/100.0)];
    [filter setFluc:fluc];
}

@end
