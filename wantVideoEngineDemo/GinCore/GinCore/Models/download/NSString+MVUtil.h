//
//  NSString+MVUtil.h
//  microChannel
//
//  Created by 孔令山 on 12/1/13.
//  Copyright (c) 2013 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define KDocumentsPath   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define KCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define kResouceFolder @"editresource"
#define kConfigInfoFolder @"configinfo"
#define kLocalStorage @"localstorage"
#define kWebCacheFolder @"com.tencent.microvision"
#define kSwipNavImageCacheFolder @"SwipNavImageCache"

#define KResourcePath [KCachesPath stringByAppendingPathComponent:kResouceFolder]
#define KConfigFilePath [KCachesPath stringByAppendingPathComponent:kConfigInfoFolder]
#define KCookiesPath [KCachesPath stringByAppendingPathComponent:kLocalStorage]
#define KWebCachePath [KCachesPath stringByAppendingPathComponent:kWebCacheFolder]


@interface NSString (MVUtil)

+ (NSString*)getResourcePathWithUrl:(NSString*)url;
+ (NSString *)getResourceBaseFolderPath;
+ (UIImage*)getResourceImageWithUrl:(NSString*)url;

+ (NSString *)getResourcePathIfExistWithURL:(NSString *)url;

+ (BOOL)isValidUrl:(NSString*)url;
+ (NSString *)getDownloadUrl:(NSString*)url;//如果需要下载则返回下载url，否则返回nil

@end
