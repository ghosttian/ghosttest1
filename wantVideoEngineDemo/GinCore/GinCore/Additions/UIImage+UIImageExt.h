//
//  UIImage+UIImageExt.h
//  Gin
//
//  Created by wbdev on 13-4-12.
//  Copyright (c) 2013年 Gin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageExt)

//通过颜色创建图片
+ (UIImage *)imageWithColor: (UIColor *) color;
+ (UIImage *)imageWithColor: (UIColor *) color size:(CGSize)size;
- (UIImage*)cropImgToSize: (CGFloat)width height:(CGFloat)height toCropImg:(UIImage*)sImg;
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;
//裁剪图片到subImageSize，x，y是起始裁剪坐标
- (UIImage *)cropToSize:(CGSize)subImageSize offx:(CGFloat)x offy:(CGFloat)y;
//旋转图片至正方向，且现在图片宽高最大值为size
-(id)scaleAndRotateImage:(NSInteger)size withOritation:(NSInteger)oritation;

+ (UIImage *)imageWithContentFile:(NSString *)imageName;
+ (id)imageWithCache:(NSString*)imageName;

@end
