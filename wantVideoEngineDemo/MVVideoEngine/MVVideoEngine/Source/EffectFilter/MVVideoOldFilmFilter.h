//
//  MVVideoOldFilmFilter.h
//  microChannel
//
//  Created by aidenluo on 9/11/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVVideoCurveFilter.h"

@interface MVVideoOldFilmFilter : MVVideoCurveFilter

@property(nonatomic) CGPoint nosiyPoint1;
@property(nonatomic) CGPoint nosiyPoint2;
@property(nonatomic) float fluc;

- (instancetype)initWithResourceImage:(UIImage *)image;

@end
