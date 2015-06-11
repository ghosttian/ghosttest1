//
//  UIImage+BetterFace.m
//  bf
//
//  Created by liuyan on 13-11-25.
//  Copyright (c) 2013年 Croath. All rights reserved.
//

#import "UIImage+BetterFace.h"
#import "UIImage+ADResize.h"

static const float goldDivisionPoint = 0.618;
static const float faceDetectMargin = 0.0;

#define GOLDEN_RATIO (0.618)

#ifdef BF_DEBUG
#define BFLog(format...) NSLog(format)
#else
#define BFLog(format...)
#endif

@implementation UIImage (BetterFace)

- (UIImage *)betterFaceImageForSize:(CGSize)size
                           accuracy:(BFAccuracy)accurary;
{
    NSArray *features = [UIImage _faceFeaturesInImage:self accuracy:accurary];
    
    if ([features count]==0) {
        BFLog(@"no faces");
        return nil;
    } else {
        BFLog(@"succeed %lu faces", (unsigned long)[features count]);
        return [self _subImageForFaceFeatures:features
                                         size:size];
    }
}

- (UIImage *)betterFaceImageForSizeV2:(CGSize)size
                             accuracy:(BFAccuracy)accurary{

    NSString *accuraryStr = (accurary == kBFAccuracyLow) ? CIDetectorAccuracyLow : CIDetectorAccuracyHigh;

    CGRect newRect = [self newImageRectAfterFaceDetect:size Accurary:accuraryStr];

    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, newRect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return newImage;
}

- (UIImage *)newImageWithFaceRect:(CGRect)faceRect FrameSize:(CGSize)frameSize{
    //注意，self的大小可能跟frameSize的大小不匹配，需要对self进行缩放以匹配frameSize，同时要调整faceRect的大小和位置
    UIImage *resizedImage = [self ad_resizeImageToAspectFill:frameSize];
    float rate = resizedImage.size.width / self.size.width;
    faceRect.origin.x *= rate;
    faceRect.origin.y *= rate;
    faceRect.size.width *= rate;
    faceRect.size.height *= rate;

    CGRect croppedImageRect = [resizedImage newImageRectWithFaceRect:faceRect FrameSize:frameSize];
    CGImageRef imageRef = CGImageCreateWithImageInRect(resizedImage.CGImage, croppedImageRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

- (CGRect)newImageRectWithFaceRect:(CGRect)faceRect FrameSize:(CGSize)frameSize{

    CGRect newImageRect;
    newImageRect.size = frameSize;

    BOOL faceDetected = NO;
    if (!CGRectEqualToRect(faceRect, CGRectZero)) {
        faceDetected = YES;
    }

    if (faceDetected) {
        //以人脸为中心图片进行剪裁
        //人脸整个在相框内
        if (faceRect.size.height <= frameSize.height && faceRect.size.width <= frameSize.width) {
            //靠左侧，靠顶部
            if ((frameSize.width - faceRect.size.width)/2 >= faceRect.origin.x
                &&(frameSize.height - faceRect.size.height)/2 >= faceRect.origin.y) {
                newImageRect.origin.x = 0;
                newImageRect.origin.y = 0;
            }else
                //靠左侧，靠底部
                if ((frameSize.width - faceRect.size.width)/2 >= faceRect.origin.x
                    &&(frameSize.height - faceRect.size.height)/2 >= self.size.height - faceRect.origin.y - faceRect.size.height) {
                    newImageRect.origin.x = 0;
                    newImageRect.origin.y = self.size.height - frameSize.height;
                }else
                    //靠右侧，靠底部
                    if ((frameSize.width - faceRect.size.width)/2 >= self.size.width - faceRect.origin.x - faceRect.size.width
                        &&(frameSize.height - faceRect.size.height)/2 >= self.size.height - faceRect.origin.y - faceRect.size.height) {
                        newImageRect.origin.x = self.size.width - frameSize.width;
                        newImageRect.origin.y = self.size.height - frameSize.height;
                    }else
                        //靠右侧，靠顶部
                        if ((frameSize.width - faceRect.size.width)/2 >= self.size.width - faceRect.origin.x - faceRect.size.width
                            &&(frameSize.height - faceRect.size.height)/2 >= faceRect.origin.y) {
                            newImageRect.origin.x = self.size.width - frameSize.width;
                            newImageRect.origin.y = 0;
                        }else
                            //左右在中间，靠顶部
                            if((frameSize.height - faceRect.size.height)/2 >= faceRect.origin.y){
                                newImageRect.origin.x = faceRect.origin.x - (frameSize.width - faceRect.size.width)/2;
                                newImageRect.origin.y = 0;
                            }else
                                //左右在中间，靠底部
                                if ((frameSize.height - faceRect.size.height)/2 >= self.size.height - faceRect.origin.y - faceRect.size.height) {
                                    newImageRect.origin.x = faceRect.origin.x - (frameSize.width - faceRect.size.width)/2;
                                    newImageRect.origin.y = self.size.height - frameSize.height;
                                }else
                                    //靠左侧，上下在中间
                                    if ((frameSize.width - faceRect.size.width)/2 >= faceRect.origin.x){
                                        newImageRect.origin.x = 0;
                                        newImageRect.origin.y = faceRect.origin.y - (frameSize.height - faceRect.size.height)/2;
                                    }else
                                        //靠右侧，上下在中间
                                        if ((frameSize.width - faceRect.size.width)/2 >= self.size.width - faceRect.origin.x - faceRect.size.width) {
                                            newImageRect.origin.x = self.size.width - frameSize.width;
                                            newImageRect.origin.y = faceRect.origin.y - (frameSize.height - faceRect.size.height)/2;
                                        }else
                                            //左右上下都在中间
                                        {
                                            newImageRect.origin.x = faceRect.origin.x - (frameSize.width - faceRect.size.width)/2;
                                            newImageRect.origin.y = faceRect.origin.y - (frameSize.height - faceRect.size.height)/2;
                                        }
        }else
            //人脸超出相框（应该比较少见,nnd,直接用黄金分割吧）
        {
            CGFloat goldY = self.size.height*(1.0-goldDivisionPoint);
            CGFloat realityY = (goldY + frameSize.height) > self.size.height ? 0 : goldY;
            newImageRect = CGRectMake(abs(self.size.width - frameSize.width)/2, realityY, frameSize.width, frameSize.height);
        }
    }else{
        //按照黄金分割原则对图片进行剪裁
        CGFloat goldY = self.size.height*(1.0-goldDivisionPoint);
        CGFloat realityY = (goldY + frameSize.height) > self.size.height ? 0 : goldY;
        newImageRect = CGRectMake(abs(self.size.width - frameSize.width)/2, realityY, frameSize.width, frameSize.height);
    }

    return newImageRect;

}

- (CGRect)faceDetectWithAccurary:(NSString *)accurary{

    CGRect faceRect = CGRectZero;
    //Create a CIImage version of your photo
    CIImage* image = [CIImage imageWithCGImage:self.CGImage];

    //create a face detector
    //此处是CIDetectorAccuracyHigh，若用于real-time的人脸检测，则用CIDetectorAccuracyLow，更快
    NSDictionary  *opts = [NSDictionary dictionaryWithObject:accurary
                                                      forKey:CIDetectorAccuracy];
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:opts];

    //Pull out the features of the face and loop through them

    NSArray* features = [detector featuresInImage:image];

    if ([features count]==0) {
        NSLog(@">>>>> 人脸监测【失败】啦 ～！！！");

    }else{
        NSLog(@">>>>> 人脸监测【成功】～！！！>>>>>> ");
        CIFeature *feature = (CIFeature *)[features objectAtIndex:0];
        faceRect = feature.bounds;
    }

    if (!CGRectEqualToRect(faceRect, CGRectZero)) {

        //人脸检测后区域的默认原点坐标为左下角，需要调整为左上角
        faceRect.origin.y = self.size.height - faceRect.origin.y - faceRect.size.height - faceDetectMargin;
    }
    
    return faceRect;
    
}

#pragma mark - Util

- (CGRect)newImageRectAfterFaceDetect:(CGSize)frameSize Accurary:(NSString *)accurary{

    CGRect faceRect = [self faceDetectWithAccurary:accurary];

    return [self newImageRectWithFaceRect:faceRect FrameSize:frameSize];
    
}

- (UIImage *)_subImageForFaceFeatures:(NSArray *)faceFeatures size:(CGSize)size
{
    CGRect fixedRect = CGRectMake(MAXFLOAT, MAXFLOAT, 0, 0);
    CGFloat rightBorder = 0, bottomBorder = 0;
    for (CIFaceFeature *faceFeature in faceFeatures){
        CGRect oneRect = faceFeature.bounds;
        oneRect.origin.y = size.height - oneRect.origin.y - oneRect.size.height;

        fixedRect.origin.x = MIN(oneRect.origin.x, fixedRect.origin.x);
        fixedRect.origin.y = MIN(oneRect.origin.y, fixedRect.origin.y);

        rightBorder = MAX(oneRect.origin.x + oneRect.size.width, rightBorder);
        bottomBorder = MAX(oneRect.origin.y + oneRect.size.height, bottomBorder);
    }

    fixedRect.size.width = rightBorder - fixedRect.origin.x;
    fixedRect.size.height = bottomBorder - fixedRect.origin.y;

    CGPoint fixedCenter = CGPointMake(fixedRect.origin.x + fixedRect.size.width / 2.0,
                                      fixedRect.origin.y + fixedRect.size.height / 2.0);
    CGPoint offset = CGPointZero;
    CGSize finalSize = size;
    if (size.width / size.height > self.size.width / self.size.height) {
        //move horizonal
        finalSize.height = self.size.height;
        finalSize.width = size.width/size.height * finalSize.height;
        fixedCenter.x = finalSize.width / size.width * fixedCenter.x;
        fixedCenter.y = finalSize.width / size.width * fixedCenter.y;

        offset.x = fixedCenter.x - self.size.width * 0.5;
        if (offset.x < 0) {
            offset.x = 0;
        } else if (offset.x + self.size.width > finalSize.width) {
            offset.x = finalSize.width - self.size.width;
        }
        offset.x = - offset.x;
    } else {
        //move vertical
        finalSize.width = self.size.width;
        finalSize.height = size.height/size.width * finalSize.width;
        fixedCenter.x = finalSize.width / size.width * fixedCenter.x;
        fixedCenter.y = finalSize.width / size.width * fixedCenter.y;

        offset.y = fixedCenter.y - self.size.height * (1-GOLDEN_RATIO);
        if (offset.y < 0) {
            offset.y = 0;
        } else if (offset.y + self.size.height > finalSize.height){
            offset.y = finalSize.height = self.size.height;
        }
        offset.y = - offset.y;
    }

    CGRect finalRect = CGRectApplyAffineTransform(CGRectMake(offset.x, offset.y, finalSize.width, finalSize.height),
                                                  CGAffineTransformMakeScale(self.scale, self.scale));
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], finalRect);
    UIImage *subImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);

    return subImage;
}

+ (NSArray *)_faceFeaturesInImage:(UIImage *)image accuracy:(BFAccuracy)accurary
{
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    NSString *accuraryStr = (accurary == kBFAccuracyLow) ? CIDetectorAccuracyLow : CIDetectorAccuracyHigh;
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil
                                              options:@{CIDetectorAccuracy: accuraryStr}];
    
    return [detector featuresInImage:ciImage];
}

@end
