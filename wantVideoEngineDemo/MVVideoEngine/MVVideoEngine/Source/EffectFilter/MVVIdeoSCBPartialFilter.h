//
//  MVVIdeoSCBPartialFilter.h
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-13.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEngine.h"
#import "GPUImageTwoInputFilter.h"

@interface MVVIdeoSCBPartialFilter : GPUImageTwoInputFilter

@property(nonatomic) float filterContrast;
@property(nonatomic) float saturation;
@property(nonatomic) float brightness;

@end
