//
//  UIImageView+BetterFace.h
//  bf
//
//  Created by croath on 13-10-22.
//  Copyright (c) 2013年 Croath. All rights reserved.
//

#import <UIKit/UIKit.h>

void swizzleUIImageViewWithBetterFaceMethod();

@interface UIImageView (BetterFace)

@property (nonatomic) BOOL needsBetterFace;
@property (nonatomic) BOOL fast;

- (void)setBetterFaceImage:(UIImage *)image;

@end
