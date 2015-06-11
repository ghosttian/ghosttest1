//
//  GinNetworkUtils.m
//  GinNetwork
//
//  Created by joeqiwang on 14-11-27.
//  Copyright (c) 2014年 weishi. All rights reserved.
//

#import "GinNetworkUtils.h"
#import "UIDevice+Hardware.h"
#import "Reachability.h"
#import <CommonCrypto/CommonDigest.h>
#include <spawn.h>

static const char * __net_jb_app = NULL;

@implementation GinNetworkUtils

+ (NSString *)getUserAgent
{
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    UIDevice *device = [UIDevice currentDevice];
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (%@; %@; %@ %@; %@)", @"Weishi", [GinNetworkUtils getAppVersion], [device model], [device hardwareDescription], [device systemName], [device systemVersion], locale];
    return userAgent;
}

+ (NSString *)getMacAddress
{
    return [[UIDevice currentDevice] macaddress];
}

+ (NSString *)getAppVersion
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *appVersion = nil;
    NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    if (marketingVersionNumber && developmentVersionNumber) {
        if ([marketingVersionNumber isEqualToString:developmentVersionNumber]) {
            appVersion = marketingVersionNumber;
        } else {
            appVersion = [NSString stringWithFormat:@"%@ rv:%@",marketingVersionNumber,developmentVersionNumber];
        }
    } else {
        appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
    }
    return  appVersion;
}

+ (NSString *)getChannelName
{
    NSString * channelName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ChannelName"];
    if (!channelName)
    {
        channelName = @"其它";
    }
    return channelName;
}

+ (BOOL)isJailBroken
{
    static const char * __net_jb_apps[] =
    {
        "/Application/Cydia.app",
        "/Application/limera1n.app",
        "/Application/greenpois0n.app",
        "/Application/blackra1n.app",
        "/Application/blacksn0w.app",
        "/Application/redsn0w.app",
        NULL
    };
    
    __net_jb_app = NULL;
    
    // method 1
    for ( int i = 0; __net_jb_apps[i]; ++i )
    {
        if ( [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:__net_jb_apps[i]]] )
        {
            __net_jb_app = __net_jb_apps[i];
            return YES;
        }
    }
    
    // method 2
    if ( [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"] )
    {
        return YES;
    }
    
    // method 3
    pid_t pid;
    const char * args[] = {"ls", NULL};
    int ret = posix_spawn(&pid, "/bin/ls", NULL, NULL, (char* const*)args, NULL);
    if (0 == ret)
    {
        return YES;
    }
    
    return NO;
}

+ (NSString*)md5String:(NSString*)srcString
{
    const char *cStr = [srcString UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (BOOL)isNetWorkAvaible
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]==kNotReachable){
        return NO;
    }else{
        return YES;
    }
}

+ (BOOL)isWifi
{
    BOOL isWifi = NO;
    if ([GinNetworkUtils isNetWorkAvaible])
    {
        isWifi = [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable;
    }
    return isWifi;
}

/*
 *****获取FileSHA值
 */
+ (NSString*)getFileSHA:(NSString*)strPath
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:strPath];
    CC_SHA1_CTX sha;
    CC_SHA1_Init (&sha);
    BOOL done = NO;
    while(!done) {
        NSData* fileData = [handle readDataOfLength:256];
        CC_SHA1_Update(&sha, [fileData bytes], [fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Final(digest, &sha);
    NSString* FileSHA_ = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          digest[0], digest[1],
                          digest[2], digest[3],
                          digest[4], digest[5],
                          digest[6], digest[7],
                          digest[8], digest[9],
                          digest[10],digest[11],
                          digest[12],digest[13],
                          digest[14],digest[15],
                          digest[16],digest[17],
                          digest[18],digest[19]];
    return  FileSHA_;
}

/*
 *****获取FileMD5值
 */
+ (NSString*)getFileMD5:(NSString*)strPath
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:strPath];
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength: 256 ];
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* MD5_ = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                      digest[0], digest[1],
                      digest[2], digest[3],
                      digest[4], digest[5],
                      digest[6], digest[7],
                      digest[8], digest[9],
                      digest[10], digest[11],
                      digest[12], digest[13],
                      digest[14], digest[15]];
    
    return  MD5_;
}

/*
 *****获取FileMD5值 by NSData
 */
+ (NSString*)getFileMD5ByNSData:(NSData *)vData
{
    if (!vData || vData.length <= 0) {
        return nil;
    }
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    int offset = 0;
    int len = vData.length;
    int perLen = 256;
    while(!done)
    {
        int remain = len - offset;
        int readLen = perLen;
        if (remain < readLen) {
            readLen = remain;
        }
        NSRange range = NSMakeRange(offset, readLen);
        NSData* fileData = [vData subdataWithRange:range];
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
        if( readLen < perLen ) {
            done = YES;
        }
        offset += perLen;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* MD5_ = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                      digest[0], digest[1],
                      digest[2], digest[3],
                      digest[4], digest[5],
                      digest[6], digest[7],
                      digest[8], digest[9],
                      digest[10], digest[11],
                      digest[12], digest[13],
                      digest[14], digest[15]];
    
    return  MD5_;
}

@end
