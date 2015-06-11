//
//  NSString+MVUtil.m
//  microChannel
//
//  Created by 孔令山 on 12/1/13.
//  Copyright (c) 2013 wbdev. All rights reserved.
//

#import "NSString+Util.h"

#if !__has_feature(objc_arc)
#error ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

static NSString * _resourceBaseFolderPath;

@implementation NSString (Util)

+ (NSString*)getResourcePathWithUrl:(NSString*)url
{
    NSString* fileExtension = [url pathExtension];
    NSString* fileName = [url lastPathComponent];
    
    if (fileExtension.length > 0) {
        fileName = [NSString stringWithFormat:@"%lu.%@", (unsigned long)[[url description] hash], fileExtension];
    } else {
        fileName = [NSString stringWithFormat:@"%lu", (unsigned long)[[url description] hash]];
    }
    
	if (!_resourceBaseFolderPath) {
		_resourceBaseFolderPath = [self getResourceBaseFolderPath];
	}

	NSString* path = [_resourceBaseFolderPath stringByAppendingPathComponent:fileName];
    return path;
}

+ (NSString *)getResourcePathIfExistWithURL:(NSString *)url
{
	NSString *path = [[NSBundle mainBundle] pathForResource:[url lastPathComponent] ofType:nil];
	if (path.length <= 0) {
		path = [self getResourcePathWithUrl:url]; //cache目录hash路径
		if (![[[NSFileManager alloc] init] fileExistsAtPath:path]) {
			if ([url isAbsolutePath] && [[NSFileManager defaultManager] fileExistsAtPath:url]  ) { //兼容绝对路径
				path = url;
			} else {
				path = nil;
			}
		}
	}
	return path;
}

+ (NSString *)getResourceBaseFolderPath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:KResourcePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:KResourcePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
	return KResourcePath;
}

+ (UIImage*)getResourceImageWithUrl:(NSString*)url{
    NSString* path = [NSString getResourcePathWithUrl:url];
    UIImage *image  = [UIImage imageWithContentsOfFile:path];
    return image;
}

+ (BOOL)isValidUrl:(NSString*)url
{
    if ([url hasPrefix:@"http"]) {
        return YES;
    }
    return NO;
}

+ (NSString *)getDownloadUrl:(NSString*)url;//如果需要下载则返回下载url，否则返回nil
{
    if ([NSString isValidUrl:url]) {
        NSString* fileName = [url lastPathComponent];
        NSString* builtInFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSString* filePath = [NSString getResourcePathWithUrl:url];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath] && ![[NSFileManager defaultManager] fileExistsAtPath:builtInFilePath]) {
            return url;
        }
    }
    
    return nil;
}
@end
