//
//  GinUploadStrategyByHTTP.h
//  microChannel
//
//  Created by joeqiwang on 14-1-13.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinUploadStrategyBase.h"
#import "GinUploadResult.h"
#import "MicroVideoQueryResult.h"
#import "GinHttpCommonDefine.h"
//#import "GinVideoUploadProgress.h"

//NSString *const kLoginErrorModule = @"login";
//NSString *const kRegisterErrorModule = @"register";
//NSString *const kApplyUploadErrorModule = @"apply_upload";
//NSString *const kUploadVideoErrorMudule = @"upload_video";
//NSString *const kpublishErrorModule = @"publish";
//NSString *const kwechatLoginErrorModule = @"wechatLogin";
//NSString *const kTMcacheErrorModule = @"TMcacheErrorModule";
//NSString *const kdraftErrorModule = @"draftModule";
//NSString *const kDownloadMp4Module = @"download";
//NSString *const kPlayModule = @"play";


@interface GinUploadStrategyByHTTP : GinUploadStrategyBase

@property (nonatomic, copy) NSString *requestID;    // 把md5用作短视频的request id，来进行cancel操作
@property (nonatomic, strong) NSDate *requestStartDate;

- (void)applyUploadRequestSucceeded:(MicroVideoQueryResult*)result;

- (void)applyUploadRequestFailed:(NSError*)error;

- (void)videoUploadRequestSucceeded:(MicroVideoQueryResult*)result;

- (void)videoUploadRequestFailed:(NSError*)error;

// the methods which derived class need to override
- (void)displayWarningWithText:(NSString*)wanring;

- (void)generalUploadApplyWithParameters:(NSDictionary*)params;

- (void)generalUploadVideoWithVideoData:(NSData*)uploadData andParameters:(NSDictionary*)params;

- (void)reportUploadVideoErrorWithUID:(NSString*)uid andError:(NSError*)error andVideoType:(int)videoType;

- (void)reportUploadVideoLogFailedWithUploadAlgorithm:(int)uploadAlg andError:(NSError*)error andVideoType:(int)videoType;

- (void)reportUploadVideoLogWithElapseTime:(long)elapse andPackageSize:(unsigned long long)size andUploadAlgorithm:(int)uploadAlg;

- (void)logInModule:(NSString*)module description:(NSString*)des errorLevel:(NSInteger)level errorCode:(NSInteger)errCode command:(NSString*)cmd;

@end