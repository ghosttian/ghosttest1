//
//  UIImage+BetterFace.h
//  bf
//
//  Created by liuyan on 13-11-25.
//  Copyright (c) 2013年 Croath. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BFAccuracy) {
    kBFAccuracyLow = 0,
    kBFAccuracyHigh,
};

@interface UIImage (BetterFace)

- (UIImage *)betterFaceImageForSize:(CGSize)size
                           accuracy:(BFAccuracy)accurary;

//通过进行人脸检测得到剪裁后的图片
- (UIImage *)betterFaceImageForSizeV2:(CGSize)size
                           accuracy:(BFAccuracy)accurary;

//根据给出的头像在原图中的区域和相框大小，得到新的剪裁后图片（其内部不再进行人脸检测，执行效率较高）
- (UIImage *)newImageWithFaceRect:(CGRect)faceRect FrameSize:(CGSize)frameSize;

//根据人脸在图片中的区域和相框大小，给出最佳剪裁后的区域
- (CGRect)newImageRectWithFaceRect:(CGRect)faceRect FrameSize:(CGSize)frameSize;

//返回人脸再图片中的区域，若识别失败返回值为CGRectZero
- (CGRect)faceDetectWithAccurary:(NSString *)accurary;

@end
