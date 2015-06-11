//
//  MVVideoRadialBlurPartialFilter.h
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-13.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEngine.h"
#import "GPUImageTwoInputFilter.h"

@interface MVVideoRadialBlurPartialFilter : GPUImageTwoInputFilter
@property(nonatomic,assign)float separation;
@property(nonatomic,assign)float radius;
@property(nonatomic,assign)float x;
@property(nonatomic,assign)float y;

@end
