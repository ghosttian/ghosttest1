//
//  GinCoreDefines.h
//  microChannel
//
//  Created by leizhu on 14-11-12.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GinCoreDefines : NSObject

#define SCREEN_WIDTH                    ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT                   ([[UIScreen mainScreen] bounds].size.height)

#define IOSVERSIONISABOVE8     (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
#define IOSVERSIONISABOVE7     (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
#define IOSVERSIONISABOVE6     (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_5_1)
#define APPGROUPID              @"group.com.tencent.microvision"
@end
