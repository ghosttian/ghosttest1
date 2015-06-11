//
//  GinHttpCommonDefine.h
//  GinCore
//
//  Created by leizhu on 14/12/26.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import <Foundation/Foundation.h>

//上报php错误模块
extern NSString *const kNetWorkError1003Module;
extern NSString *const kNetWorkError1001Module;
extern NSString *const kNetWorkError1009Module;
extern NSString *const kNetWorkError1005Module;
extern NSString *const kLoginErrorModule;
extern NSString *const kRegisterErrorModule;
extern NSString *const kApplyUploadErrorModule;
extern NSString *const kUploadVideoErrorMudule;
extern NSString *const kpublishErrorModule;
extern NSString *const kwechatLoginErrorModule;
extern NSString *const kTMcacheErrorModule;
extern NSString *const kdraftErrorModule;
extern NSString *const kDownloadMp4Module;
extern NSString *const kPlayModule;

extern int const kUnloginErroCode;
extern BOOL isExtension;


@interface GinHttpCommonDefine : NSObject

@end
