//
//  GinSettingUtil.m
//  microChannel
//
//  Created by jozeli on 13-6-5.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinSettingUtil.h"
#import "GinMD5Util.h"

@implementation GinSettingUtil

+ (UIImage *)imageFromUIColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f,0.0f,1.0f,1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return colorImage;
}

+ (BOOL)isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    for (int i = 0; i < string.length; i ++) {
        unichar cha = [string characterAtIndex:i];
        if(!isblank(cha)){
            return NO;
        }
    }
    return YES;
}

+(NSString *)getMd5StrWithOriginString:(NSString *)str time:(NSString *)r
{    
    NSString *toMd5 = str;
    NSString *firstMD5 = [GinMD5Util md5String:toMd5];
    firstMD5 = [firstMD5 lowercaseString];
    NSInteger md5BytesPerPart = 8;
    NSInteger md5Parts = ceil(firstMD5.length*1.0/md5BytesPerPart);
    NSInteger mixBytesPerPart = ceil(r.length*1.0/md5Parts);
    NSString *secondSrc = nil;
    for (int i = 0; i < md5Parts; ++i) {
        NSInteger md5Start = i * md5BytesPerPart;
        NSInteger mixStart = i * mixBytesPerPart;
        mixBytesPerPart = r.length - i *mixBytesPerPart < mixBytesPerPart ? r.length - i *mixBytesPerPart : mixBytesPerPart;
        NSRange firstRange = NSMakeRange(md5Start, md5BytesPerPart);
        NSRange secondRange = NSMakeRange(mixStart, mixBytesPerPart);
        
        if (firstRange.length > 0 && secondRange.length > 0) {
            if (secondSrc) {
                secondSrc = [NSString stringWithFormat:@"%@%@%@", secondSrc, [firstMD5 substringWithRange:firstRange], [r substringWithRange:secondRange]];
            }else{
                secondSrc = [NSString stringWithFormat:@"%@%@", [firstMD5 substringWithRange:firstRange], [r substringWithRange:secondRange]];
            }
        }
        
    }

    secondSrc = [GinMD5Util md5String:secondSrc];
    secondSrc = [secondSrc lowercaseString];
    return secondSrc;
}
@end

