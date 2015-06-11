//
//  GinUploadResult.h
//  microChannel
//
//  Created by jozeli on 13-8-7.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GinUploadVideoDef.h"

#define     AU_CHECKKEY      @"checkkey"
#define     AU_EXISTS        @"exists"
#define     AU_FID           @"fid"
#define     AU_S             @"s"
#define     AU_SERVERIP      @"serverip"
#define     AU_SERVERPORT    @"serverport"
#define     AU_VID           @"vid"
#define     AU_UIN           @"uin"
#define     AU_EM            @"em"
#define     AU_MSG           @"msg"

@interface GinUploadResult : NSObject

@property(nonatomic, assign) int em;
@property(nonatomic, copy) NSString *msg;
@property(nonatomic, copy) NSString *s;
@property(nonatomic, copy) NSString *serverip;
@property(nonatomic, assign) int port;
@property(nonatomic, copy) NSString *checkkey;
@property(nonatomic, assign) BOOL exists;
@property(nonatomic, copy) NSString *uin;
@property(nonatomic, copy) NSString *vid;
@property(nonatomic, copy) NSString *fid;
@property(nonatomic, copy) NSString *msgID;
@property(nonatomic, copy) NSString *requestID;
@property(nonatomic, copy) NSString *fileKey;
@property(nonatomic, copy) NSString *longVideoURL;
@property(nonatomic, assign) unsigned long long offset;
@property(nonatomic, assign) int vlen;
@property(nonatomic, assign) FtnUploadStep vUpStep;
@property(nonatomic, copy) NSString *path;

@property(nonatomic, copy) NSString *sha;
@property(nonatomic, copy) NSString *md5;

@property(nonatomic, assign) int errcode;
@property(nonatomic, strong) NSError *error;

@property(nonatomic, assign) VideoRateType voideRateType;

- (NSString*)simpleDescription;

@end
