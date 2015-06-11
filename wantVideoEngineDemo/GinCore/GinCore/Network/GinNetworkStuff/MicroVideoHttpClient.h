//
//  MicroVideoHttpClient.h
//  microChannel
//
//  Created by aidenluo on 7/19/13.
//  Copyright (c) 2013 wbdev. All rights reserved.
//

#import "AFHTTPClient.h"
#import "MicroVideoQueryResult.h"

@class KeychainItemWrapper;
@interface MicroVideoHttpClient : AFHTTPClient

@property (nonatomic, strong) KeychainItemWrapper *wrapper;
@property (nonatomic, assign) BOOL isNeedServerIp;
@property (nonatomic, strong) NSArray *serverIPArr;
@property (nonatomic, assign) BOOL isJailBroken;

- (instancetype)initWithBaseURL:(NSURL *)url;
- (void)setBaseParamters:(AFHTTPClient*)toSetClient;
- (NSDictionary*)getBaseParamters;//网络请求底层cooki等参数
- (NSDictionary*)getBaseHeaderCheckLoginStatus;//网络请求底层cooki等参数
- (void)getPath:(NSString *)path
 withParameters:(NSDictionary *)parameters
        success:(void (^)(MicroVideoQueryResult *result))success
        failure:(void (^)(NSError *error))failure;

- (void)postPath:(NSString *)path
  withParameters:(NSDictionary *)parameters
         success:(void (^)(MicroVideoQueryResult *result))success
         failure:(void (^)(NSError *error))failure;

//当需要判断request是哪个时使用
- (void)postPath:(NSString *)path
  withParameters:(NSDictionary *)parameters
        userInfo:(NSDictionary *)userInfo
         success:(void (^)(AFHTTPRequestOperation *operation, id result))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)cancelAllGetHTTPOperationsWithPath:(NSString *)path;

- (void)cancelAllPosttHTTPOperationsWithPath:(NSString *)path;

- (void)cancelHTTPOperationByOperationID:(NSString*)operationID;

// 上传文本文件
- (void)postTextFileWithPath:(NSString *)path
                withFileData:(NSData *)fileData
              withParameters:(NSDictionary *)parameters
                     success:(void (^)(MicroVideoQueryResult *result))success
                     failure:(void (^)(NSError *error))failure;

//上传图片
- (void)postImgWithPath:(NSString *)path
         withParameters:(NSDictionary *)parameters
                success:(void (^)(MicroVideoQueryResult *result))success
                failure:(void (^)(NSError *error))failure;

//上传视频
- (void)postVideoWithPath:(NSString *)path
            withVideoData:(NSData *)videoData
           withParameters:(NSDictionary *)parameters
                  success:(void (^)(MicroVideoQueryResult *result))success
                  failure:(void (^)(NSError *error))failure;

- (NSString*)genToKey:(NSString*)inStr;

- (void)publishDataWithPath:(NSString*)path
             withParameters:(NSDictionary *)parameters
                    success:(void (^)(MicroVideoQueryResult *result))success
                    failure:(void (^)(NSError *error))failure;

- (NSString *)userIdentifier;   //根据accountInfo中数据计算出来的用户标识

- (NSMutableDictionary*)formatParameters:(NSDictionary*)parameters time:(int)time;

- (NSString*)getMacString;

// override this method to handle specific errors
- (void)checkError:(AFHTTPRequestOperation*)operation path:(NSString *)path error:(NSError *)error time:(int)time;

//判断微信token失败，微信token不对的时候会返回改错误码---子类重载
- (BOOL)checkWeixinTokenError:(NSError*)error api:(NSString*)api;

- (NSString *)tokenMd5Str:(NSString *)inStr;

@end
