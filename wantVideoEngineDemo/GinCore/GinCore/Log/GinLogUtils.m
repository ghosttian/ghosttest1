//
//  GinLogUtils.m
//  GinCore
//
//  Created by joeqiwang on 14-12-17.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import "GinLogUtils.h"
#import "GinAccountInfo.h"

@implementation GinLogUtils

+ (NSString *)weishiVersion
{
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    if(version!=nil)
    {
        return version;
    }
    return @"1.0.0";
}

+ (NSString *)getUserID
{
    NSString * user;
    if ([[GinAccountInfo sharedAccountInfo] isLogin])
    {
        user = [[GinAccountInfo sharedAccountInfo] qqId];
        if (!user)
        {
            user = [GinAccountInfo sharedAccountInfo].wbUserInfo.weiShiId;
        }
    }
    
    return user;
}

@end
