//
//  MVVideoCurveDarkCornerFilter.h
//  microChannel
//
//  Created by aidenluo on 9/12/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface MVVideoCurveDarkCornerFilter : GPUImageTwoInputFilter

@property(nonatomic,strong)UIImage *darkCornerImage;

- (instancetype)initWithPicture:(UIImage *)image
                          Matix:(GPUMatrix4x4)matrix
                  gradientStart:(float)gStart
                    gradientEnd:(float)gEnd;

@end
