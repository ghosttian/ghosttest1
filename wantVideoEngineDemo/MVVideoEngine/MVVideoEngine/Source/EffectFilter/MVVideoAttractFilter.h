//
//  MVVideoAttractFilter.h
//  MVVideoEngine
//
//  Created by ghosttian on 14-11-19.
//  Copyright (c) 2014年 microvision. All rights reserved.
//

#import "MVVideoEngine.h"
#import "GPUImageTwoInputFilter.h"

@interface MVVideoAttractFilter : GPUImageTwoInputFilter

@property(nonatomic,strong)UIImage *modelImage;

- (instancetype)initWithResourceImage:(UIImage *)image;

@end
