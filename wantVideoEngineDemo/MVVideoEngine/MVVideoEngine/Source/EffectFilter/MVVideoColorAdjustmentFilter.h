//
//  MVVideoColorAdjustmentFilter.h
//  MVVideoEngine
//
//  Created by ghosttian on 14-12-3.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEngine.h"
#import "GPUImageFilter.h"

@interface MVVideoColorAdjustmentFilter : GPUImageFilter

- (instancetype)initWithMatix:(GPUMatrix4x4)matrix;

@end
