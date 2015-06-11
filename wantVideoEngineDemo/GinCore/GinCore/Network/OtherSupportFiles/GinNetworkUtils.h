//
//  GinNetworkUtils.h
//  GinNetwork
//
//  Created by wangqi on 14-11-27.
//  Copyright (c) 2014年 weishi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GinNetworkUtils : NSObject

+ (NSString *)getUserAgent;

+ (NSString *)getMacAddress;

+ (NSString *)getAppVersion;

+ (NSString *)getChannelName;

+ (BOOL)isJailBroken;

+ (NSString *)md5String:(NSString *)srcString;

+ (BOOL)isNetWorkAvaible;

+ (BOOL)isWifi;

+ (NSString*)getFileSHA:(NSString*)strPath;

+ (NSString*)getFileMD5:(NSString*)strPath;

+ (NSString*)getFileMD5ByNSData:(NSData *)vData;

@end
