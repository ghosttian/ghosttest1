//
//  UIImage+UIImageExt.m
//  Gin
//
//  Created by wbdev on 13-4-12.
//  Copyright (c) 2013年 Gin. All rights reserved.
//

#import "UIImage+UIImageExt.h"
#import "SDImageCache.h"

@implementation UIImage (UIImageExt)

+ (UIImage *) imageWithColor: (UIColor *) color
{
    CGRect rect = CGRectMake(0.0f,0.0f,40.0f,30.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)imageWithColor: (UIColor *) color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f,0.0f,size.width,size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

//裁剪图片到subImageSize，x，y是起始裁剪坐标
- (UIImage *)cropToSize:(CGSize)subImageSize offx:(CGFloat)x offy:(CGFloat)y
{
    //定义裁剪的区域相对于原图片的位置
    CGRect subImageRect = CGRectMake(x, y, subImageSize.width, subImageSize.height);
    CGImageRef imageRef = self.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, subImageRect);
    UIGraphicsBeginImageContext(subImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, subImageRect, subImageRef);
    UIImage* subImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    //返回裁剪的部分图像
    return subImage;
}

- (UIImage*)cropImgToSize: (CGFloat)width height:(CGFloat)height toCropImg:(UIImage*)sImg
{
    CGFloat sw = sImg.size.width;
    CGFloat sh = sImg.size.height;
    
    CGFloat destW = 0;
    CGFloat destH = 0;
    if (sw > sh) {
        destH = height;
        destW = sw * destH / sh;
    }else{
        destW = width;
        destH = sh * destW / sw;
    }
    
    UIImage *destImg = [sImg scaleToSize:sImg size:CGSizeMake(destW, destH)];
    CGFloat offx = 0;
    CGFloat offy = 0;
    if (destH > destW) {
        offx = 0;
        offy = (destH - height)/2;
    }else{
        offx = (destW - width)/2;
        offy = 0;
    }
    return [destImg cropToSize:CGSizeMake(width, height) offx:offx offy:offy];
}

//旋转图片至正方向，且现在图片宽高最大值为size
-(id)scaleAndRotateImage:(NSInteger)size withOritation:(NSInteger)oritation
{
    int kMaxResolution = size; // Or whatever
    CGImageRef imgRef = self.CGImage;
	
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
	
    if(width <=0.0 || height <= 0.0){
        return nil;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
	
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = self.imageOrientation;
    if (oritation > -1) {
        orient = oritation;//从相册来的图片
    }
    switch(orient) {
			
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
			
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
			
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
			
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
			
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
    }
	
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
	
    CGContextConcatCTM(context, transform);
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return imageCopy;
}

+ (UIImage *)imageWithContentFile:(NSString *)imageName
{
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:imageName ofType:@"png"]];
    if (image == nil) {
        NSString *imageNameHD = [NSString stringWithFormat:@"%@@2x",imageName];
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:imageNameHD ofType:@"png"]]; 
    }
    if (image == nil) {
        NSString *imageNameSD = [NSString stringWithFormat:@"%@@3x",imageName];
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:imageNameSD ofType:@"png"]];
    }
    return image;
}

+(id)imageWithCache:(NSString*)imageName
{
    //去调.png后缀
    NSRange range = [imageName rangeOfString:@".png"];
    if (range.location < imageName.length) {
        imageName = [imageName substringToIndex:range.location];
    }
    //去掉.jpg后缀
    NSString *picType = @"png";
    range = [imageName rangeOfString:@".jpg"];
    if (range.location < imageName.length) {
        picType = @"jpg";
        imageName = [imageName substringToIndex:range.location];
    }
    
    //去掉.gif后缀
    range = [imageName rangeOfString:@".gif"];
    if (range.location < imageName.length) {
        picType = @"gif";
        imageName = [imageName substringToIndex:range.location];
    }
    
    //统一使用不带@2x来生成图及作为cache的key,确保cache唯一
    range = [imageName rangeOfString:@"@2x"];
    if (range.location < imageName.length) {
        //去掉@2x
        imageName = [imageName substringToIndex:range.location];
        
    }
    //统一使用不带@3x来生成图及作为cache的key,确保cache唯一
    range = [imageName rangeOfString:@"@3x"];
    if (range.location!= NSNotFound && range.location < imageName.length) {
        //去掉@2x
        imageName = [imageName substringToIndex:range.location];
        
    }
    ////
    UIImage * image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imageName];
    if (!image) {
        NSString *atType = @"@2x";
        if([UIScreen mainScreen].scale >=3.0f){
            atType = @"@3x";
        }
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@%@", imageName,atType] ofType:picType]];
        if (!image && [atType isEqualToString:@"@3x"]) {
            image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@%@", imageName,@"@2x"] ofType:picType]];
        }
        if (!image) {
            image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:imageName ofType:picType]];
        }
        if (image) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:imageName toDisk:NO];
        }
    }
    return image;
}
@end
