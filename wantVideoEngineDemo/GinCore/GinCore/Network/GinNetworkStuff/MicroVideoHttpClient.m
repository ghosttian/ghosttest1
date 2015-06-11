//
//  MicroVideoHttpClient.m
//  microChannel
//
//  Created by aidenluo on 7/19/13.
//  Copyright (c) 2013 wbdev. All rights reserved.
//

#import "MicroVideoHttpClient.h"
#import "AFJSONRequestOperation.h"
#import <UIKit/UIKit.h>
#import "GinAccountInfo.h"
#import "Reachability.h"
#import "KeychainItemWrapper.h"
#import "NSMutableDictionary+NilObject.h"
#import "GinNetworkUtils.h"
#import "NSDictionary+Additions.h"
#import "UIAlertView+BlockAddition.h"

#define kKillErrorCode -17//服务器下发的自杀code
#define kNeedSinaWeiboLogin

int const kHttpRequestCancelledError        = -999; // http请求被主动cancelled返回的错误
int const kErrCodeNetWorkUnavaible          = 1;
int const kReqTimeOutInterval               = 15;


// 短视频上传接口
static NSString *const MICRO_VIDEO_API_APPLY_UPLOAD             =   @"video/applyVideo.php";
static NSString *const MICRO_VIDEO_API_UPLOAD_VIDEO             =   @"video/uploadVideo.php";
// 长视频上传接口
static NSString *const MICRO_VIDEO_API_APPLY_UPLOAD_LONG_VIDEO  =   @"video/applyLongVideo.php";
static NSString *const MICRO_VIDEO_API_UPLOAD_LONG_VIDEO        =   @"video/uploadLongVideo.php";
static NSString *const MICRO_VIDEO_API_APP_CONSOLE              =   @"info/console.php";


NSString *const NetworkAPIDomain                         =   @"http://wsi.qq.com";
NSString *const NetworkAPIBaseUrl                        =   @"http://wsi.qq.com/weishi";
static NSString *const kUserDeviceIdServiceName                 =   @"kUserDeviceIdServiceName";
static NSString *const kDeviceUUID                              =   @"kDeviceUUID";
static NSString *const kUniqueDataId                            =   @"kUniqueDataId";
static NSString *const kLogReportModule                         =   @"module";

extern CFTypeRef kSecAttrService;

@interface MicroVideoHttpClient()
@property (nonatomic, copy)NSString *macStr;
@end


@implementation MicroVideoHttpClient

- (void)dealloc
{
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self)
    {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        self.wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"MicroVideoHttpClientPassword" accessGroup:nil];
        
        [self.wrapper setObject:@"MY_APP_CREDENTIALS" forKey:(__bridge id)kSecAttrService];
        [self setBaseParamters:self];
    }
    return self;
}

- (void)setBaseParamters:(AFHTTPClient*)toSetClient
{
    NSDictionary *params = [self getBaseParamters];
    [toSetClient setDefaultHeader:@"Referer" value:[params objectForKey:@"Referer"]];
    [toSetClient setDefaultHeader:@"Cookie" value:[params objectForKey:@"Cookie"]];
    [toSetClient setDefaultHeader:@"User-Agent" value:[params objectForKey:@"User-Agent"]];
    [toSetClient setDefaultHeader:@"Accept" value:[params objectForKey:@"Accept"]];
}

- (NSDictionary*)getBaseParamters//网络请求底层cooki等参数
{
    NSMutableDictionary *paras = [NSMutableDictionary dictionaryWithCapacity:4];
    [paras setObjectOrNil:NetworkAPIDomain forKey:@"Referer"];
    [paras setObjectOrNil:[GinNetworkUtils getUserAgent] forKey:@"User-Agent"];
    [paras setObjectOrNil:@"application/json" forKey:@"Accept"];
    
    NSString *cookieStr = [self generateCookieStringByAccountInfo];
    [paras setObjectOrNil:cookieStr forKey:@"Cookie"];
    
    return paras;
}

- (void)getPath:(NSString *)path
 withParameters:(NSDictionary *)parameters
        success:(void (^)(MicroVideoQueryResult *result))success
        failure:(void (^)(NSError *error))failure
{
    if (![self checkNetWork])
    {
        NSError *err = [NSError errorWithDomain:@"no netWork aviable" code:kErrCodeNetWorkUnavaible userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"no netWork aviable",NSLocalizedDescriptionKey,nil]];
        failure(err);
        return;
    }
    int time = (int)[[NSDate date]timeIntervalSince1970];
    [self getPath:path
       parameters:[self formatParameters:parameters time:time]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              MicroVideoQueryResult* result = [[MicroVideoQueryResult alloc] initWithDictionary:responseObject];
              NSError *err = [self formatError:responseObject atPath:path];
              
              if (![self checkResultArc:operation.response.allHeaderFields joson:operation.responseString time:time path:path error:err] || result.errCode != 0) {
                  
                  //处理错误
                  [self checkError:operation path:path error:err time:time];
                  
                  if ([self checkWeixinTokenError:err api:path]) {
                      //再次调用接口
                      [self getPath:path withParameters:parameters success:success failure:failure];
                      return;
                  }
                  
                  failure(err);
              }else{
                  success(result);
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              //处理错误
              [self checkError:operation path:path error:error time:time];
              
              if ([self checkWeixinTokenError:error api:path]) {
                  //再次调用接口
                  [self getPath:path withParameters:parameters success:success failure:failure];
                  return;
              }
              failure(error);
          }];
}

- (void)postPath:(NSString *)path
  withParameters:(NSDictionary *)parameters
         success:(void (^)(MicroVideoQueryResult *result))success
         failure:(void (^)(NSError *error))failure
{
    NSString * apiUrl = path;
    int time = (int)[[NSDate date]timeIntervalSince1970];
    NSDictionary * dicGetParam = [self formatPostParameters:parameters time:time];
    path = [self makePostLogPath:path time:time params:dicGetParam];
    
    // 视频的request id是整个文件的md5 string
    if ([parameters objectForKey:@"requestid"] && ([apiUrl isEqualToString:MICRO_VIDEO_API_APPLY_UPLOAD] || [apiUrl isEqualToString:MICRO_VIDEO_API_APPLY_UPLOAD_LONG_VIDEO]))
    {
        path = [NSString stringWithFormat:@"%@&requestID=%@", path, [parameters ginStringValueForKey:@"requestid"]];
    }
    
    [self postPath:path
        parameters:[self setWTkParameter:parameters getParams:dicGetParam path:apiUrl]
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               MicroVideoQueryResult* result = [[MicroVideoQueryResult alloc] initWithDictionary:responseObject];
               NSError *err = [self formatError:responseObject atPath:path];
               // 如果HTTP请求被主动cancelled
               if ([operation isCancelled])
               {
                   err = [NSError errorWithDomain:@"" code:kHttpRequestCancelledError userInfo:responseObject];
                   failure(err);
                   return;
               }
               
               if (![self checkResultArc:operation.response.allHeaderFields joson:operation.responseString time:time path:path error:err] || result.errCode != 0) {
                   //处理错误
                   [self checkError:operation path:path error:err time:time];
                   
                   if ([self checkWeixinTokenError:err api:path]) {
                       //再次调用接口
                       [self postPath:path withParameters:parameters success:success failure:failure];
                       return;
                   }
                   
                   failure(err);
               }else{
                   success(result);
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if ([operation isCancelled])
               {
                   error = [NSError errorWithDomain:@"" code:kHttpRequestCancelledError userInfo:nil];
                   failure(error);
                   return;
               }
               
               //处理错误
               [self checkError:operation path:path error:error time:time];
               
               if ([self checkWeixinTokenError:error api:path]) {
                   //再次调用接口
                   [self postPath:path withParameters:parameters success:success failure:failure];
                   return;
               }
               
               failure(error);
           }];
}

- (void)postPath:(NSString *)path
  withParameters:(NSDictionary *)parameters
        userInfo:(NSDictionary *)userInfo
         success:(void (^)(AFHTTPRequestOperation *operation, id result))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString * apiUrl = path;
    int time = (int)[[NSDate date]timeIntervalSince1970];
    NSDictionary * dicGetParam = [self formatPostParameters:parameters time:time];
    path = [self makePostLogPath:path time:time params:dicGetParam];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:[self setWTkParameter:parameters getParams:dicGetParam path:apiUrl]];
    //TODO设置timeout为15秒
    [request setTimeoutInterval:kReqTimeOutInterval];
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    operation.userInfo = userInfo;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger errorCode = [[responseObject objectForKey:@"errcode"] integerValue];
        NSError *err = [self formatError:responseObject atPath:path];
        
        if (![self checkResultArc:operation.response.allHeaderFields joson:operation.responseString time:time path:path error:err] || errorCode!= 0) {
            
            //处理错误
            [self checkError:operation path:path error:err time:time];
            
            if ([self checkWeixinTokenError:err api:path]) {
                //再次调用接口
                [self postPath:path withParameters:parameters userInfo:userInfo success:success failure:failure];
                return;
            }
            
            failure(operation, err);
        }else{
            success(operation, [responseObject objectForKey:@"data"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //处理错误
        [self checkError:operation path:path error:error time:time];
        
        if ([self checkWeixinTokenError:error api:path]) {
            //再次调用接口
            [self postPath:path withParameters:parameters userInfo:userInfo success:success failure:failure];
            return;
        }
        
        failure(operation, error);
        
    }];
    [self enqueueHTTPRequestOperation:operation];
}

// 上传文本文件
- (void)postTextFileWithPath:(NSString *)path
                withFileData:(NSData *)fileData
              withParameters:(NSDictionary *)parameters
                     success:(void (^)(MicroVideoQueryResult *result))success
                     failure:(void (^)(NSError *error))failure
{
    int time = (int)[[NSDate date]timeIntervalSince1970];
    NSDictionary * dicGetParam = [self formatPostParameters:parameters time:time];
    parameters = [self setWTkParameter:[self formatParameters:parameters time:time] getParams:nil path:path];
    path = [self makePostLogPath:path time:time params:dicGetParam];
    
    if (![parameters isKindOfClass:[NSDictionary class]] || !fileData)
    {
        NSError *err = [NSError errorWithDomain:@"parameter erro" code:-2 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"parameter error or video error",NSLocalizedDescriptionKey,nil]];
        failure(err);
        return;
    }
    
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:path parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:fileData name:@"data" fileName:@"logFile.txt" mimeType:@"text/plain"];
    }];
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *err = nil;
        MicroVideoQueryResult* result = [[MicroVideoQueryResult alloc] initWithDictionary:responseObject];
        err = [self formatError:responseObject atPath:path];
        if (![self checkResultArc:operation.response.allHeaderFields joson:operation.responseString time:time path:path error:err] || result.errCode != 0) {
            
            //处理错误
            [self checkError:operation path:path error:err time:time];
            if ([self checkWeixinTokenError:err api:path]) {
                //再次调用接口
                [self postTextFileWithPath:path withFileData:fileData withParameters:parameters success:success failure:failure];
                return;
            }
            
            failure(err);
        }else{
            success(result);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //处理错误
        [self checkError:operation path:path error:error time:time];
        
        if ([self checkWeixinTokenError:error api:path]) {
            //再次调用接口
            [self postTextFileWithPath:path withFileData:fileData withParameters:parameters success:success failure:failure];
            return;
        }
        
        failure(error);
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

//上传图片
- (void)postImgWithPath:(NSString *)path
         withParameters:(NSDictionary *)parameters
                success:(void (^)(MicroVideoQueryResult *result))success
                failure:(void (^)(NSError *error))failure
{
    if (![self checkNetWork]) {
        NSError *err = [NSError errorWithDomain:@"no netWork aviable" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"no netWork aviable",NSLocalizedDescriptionKey,nil]];
        failure(err);
        return;
    }
    
    int time = (int)[[NSDate date]timeIntervalSince1970];
    
    parameters = [self setWTkParameter:[self formatParameters:parameters time:time] getParams:nil path:path];
    
    for (NSString* key in [parameters keyEnumerator]) {
        id val = [parameters objectForKey:key];
        if ([val isKindOfClass:[UIImage class]]) {
            NSData* imageData = UIImageJPEGRepresentation((UIImage*)val, 0.6);
            NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:path parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                [formData appendPartWithFileData: imageData name:@"image" fileName:@"gin.png" mimeType:@"image/jpg"];
            }];
            AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSError *err = [self formatError:responseObject atPath:path];
                
                MicroVideoQueryResult* result = [[MicroVideoQueryResult alloc] initWithDictionary:responseObject];
                if (![self checkResultArc:operation.response.allHeaderFields joson:operation.responseString time:time path:path error:err] || result.errCode != 0) {
                    //处理错误
                    [self checkError:operation path:path error:err time:time];
                    
                    if ([self checkWeixinTokenError:err api:path]) {
                        //再次调用接口
                        [self postImgWithPath:path withParameters:parameters success:success failure:failure];
                        return;
                    }
                    
                    failure(err);
                }else{
                    success(result);
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //处理错误
                [self checkError:operation path:path error:error time:time];
                
                if ([self checkWeixinTokenError:error api:path]) {
                    //再次调用接口
                    [self postImgWithPath:path withParameters:parameters success:success failure:failure];
                    return;
                }
                
                failure(error);
            }];
            
            [operation start];
            return;
        }
        else {
        }
    }
}


//上传视频
- (void)postVideoWithPath:(NSString *)path
            withVideoData:(NSData *)videoData
           withParameters:(NSDictionary *)parameters
                  success:(void (^)(MicroVideoQueryResult *result))success
                  failure:(void (^)(NSError *error))failure
{
    int time = (int)[[NSDate date]timeIntervalSince1970];
    NSDictionary * dicGetParam = [self formatPostParameters:parameters time:time];
    NSString *tmpPath = path;
    parameters = [self setWTkParameter:[self formatParameters:parameters time:time] getParams:nil path:path];
    
    path = [self makePostLogPath:path time:time params:dicGetParam];
    
    // 视频的request id是整个文件的md5 string
    if ([parameters objectForKey:@"requestid"] && ([tmpPath isEqualToString:MICRO_VIDEO_API_UPLOAD_VIDEO] || [tmpPath isEqualToString:MICRO_VIDEO_API_UPLOAD_LONG_VIDEO]))
    {
        path = [NSString stringWithFormat:@"%@&requestID=%@", path, [parameters ginStringValueForKey:@"requestid"]];
    }
    
    if (![parameters isKindOfClass:[NSDictionary class]] || !videoData) {
        NSError *err = [NSError errorWithDomain:@"parameter erro" code:-2 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"parameter error or video error",NSLocalizedDescriptionKey,nil]];
        failure(err);
        return;
    }
    
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:path parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:videoData name:@"data" fileName:@"video.mp4" mimeType:@"video/mp4"];
    }];
    // set timeout to 30s
    [request setTimeoutInterval:30];
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *err = nil;
        // 如果HTTP请求被主动cancelled
        if ([operation isCancelled])
        {
            err = [NSError errorWithDomain:@"" code:kHttpRequestCancelledError userInfo:responseObject];
            failure(err);
            return;
        }
        
        MicroVideoQueryResult* result = [[MicroVideoQueryResult alloc] initWithDictionary:responseObject];
        err = [self formatError:responseObject atPath:path];
        if (![self checkResultArc:operation.response.allHeaderFields joson:operation.responseString time:time path:path error:err] || result.errCode != 0) {
            //处理错误
            [self checkError:operation path:path error:err time:time];
            
            if ([self checkWeixinTokenError:err api:path]) {
                //再次调用接口
                [self postVideoWithPath:path withVideoData:videoData withParameters:parameters success:success failure:failure];
                return;
            }
            
            failure(err);
        }else{
            success(result);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // 如果HTTP请求被主动cancelled
        if ([operation isCancelled])
        {
            error = [NSError errorWithDomain:@"" code:kHttpRequestCancelledError userInfo:nil];
            failure(error);
            return;
        }
        //处理错误
        [self checkError:operation path:path error:error time:time];
        if ([self checkWeixinTokenError:error api:path]) {
            //再次调用接口
            [self postVideoWithPath:path withVideoData:videoData withParameters:parameters success:success failure:failure];
            return;
        }
        failure(error);
    }];
    
    [self enqueueHTTPRequestOperation:operation];
    return;
}

- (void)publishDataWithPath:(NSString*)path
             withParameters:(NSDictionary *)parameters
                    success:(void (^)(MicroVideoQueryResult *result))success
                    failure:(void (^)(NSError *error))failure;
{
    if (![self checkNetWork]) {
        NSError *err = [NSError errorWithDomain:@"no netWork aviable" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"no netWork aviable",NSLocalizedDescriptionKey,nil]];
        failure(err);
        return;
    }
    
    int time = (int)[[NSDate date]timeIntervalSince1970];
    
    parameters = [self setWTkParameter:[self formatParameters:parameters time:time] getParams:nil path:path];
    
    {
        id val = [parameters objectForKey:@"image"];
        NSData *video = [parameters objectForKey:@"video"];
        if ([val isKindOfClass:[UIImage class]]) {
            NSData* imageData = UIImageJPEGRepresentation((UIImage*)val, 0.6);
            NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:path parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                [formData appendPartWithFileData: imageData name:@"image" fileName:@"gin.png" mimeType:@"image/jpg"];
                [formData appendPartWithFileData:video name:@"video" fileName:@"vido" mimeType:@"video/mp4"];
            }];
            AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                MicroVideoQueryResult* result = [[MicroVideoQueryResult alloc] initWithDictionary:responseObject];
                NSError *err = [self formatError:responseObject atPath:path];
                
                if (![self checkResultArc:operation.response.allHeaderFields joson:operation.responseString time:time path:path error:err] || result.errCode != 0) {
                    //处理错误
                    [self checkError:operation path:path error:err time:time];
                    
                    if ([self checkWeixinTokenError:err api:path]) {
                        //再次调用接口
                        [self publishDataWithPath:path withParameters:parameters success:success failure:failure];
                        return;
                    }
                    
                    failure(err);
                }else{
                    success(result);
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                //处理错误
                [self checkError:operation path:path error:error time:time];
                
                if ([self checkWeixinTokenError:error api:path]) {
                    //再次调用接口
                    [self publishDataWithPath:path withParameters:parameters success:success failure:failure];
                    return;
                }
                
                failure(error);
                
            }];
            
            [operation start];
            return;
        }
        else {
        }
    }
    
}
- (void)cancelAllGetHTTPOperationsWithPath:(NSString *)path
{
    [self cancelAllHTTPOperationsWithMethod:@"GET" path:path];
}

- (void)cancelAllPosttHTTPOperationsWithPath:(NSString *)path
{
    [self cancelAllHTTPOperationsWithMethod:@"POST" path:path];
}

- (void)cancelHTTPOperationByOperationID:(NSString*)operationID
{
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            continue;
        }
        
        NSString *pathString = [[[(AFHTTPRequestOperation *)operation request] URL] absoluteString];
        
        BOOL isContainItem = [pathString hasSuffix:operationID];
        
        if (isContainItem)
        {
            [operation cancel];
            return;
        }
    }
}

- (NSString *)urlSchemeString
{
    return [NSString stringWithFormat:@"weishib%@", kUserDeviceIdServiceName];
}

- (NSString*)getMacString
{
    if (self.macStr)
    {
        return self.macStr;
    }
    
    NSString *devc = [self.wrapper objectForKey:(__bridge NSString*)kSecValueData];
    
    if (!devc || devc.length < 1)
    {
        devc = [self _getMacString];
        [self.wrapper setObject:devc forKey:(__bridge NSString*)kSecValueData];
    }
    self.macStr = devc;
    return self.macStr;
}

//网络请求底层cooki等参数
- (NSDictionary*)getBaseHeaderCheckLoginStatus
{
    NSDictionary *dict=[self getBaseParamters];
    NSMutableDictionary *headers=[NSMutableDictionary dictionaryWithDictionary:dict];
    GinAccountInfo *account = [GinAccountInfo sharedAccountInfo];
    if(!account.isLogin&&[headers objectForKey:@"Cookie"]!=nil){
        [headers removeObjectForKey:@"Cookie"];
    }
    return headers;
}

- (NSString*)_getMacString
{
    
    NSString *devc = nil;
    if ([[UIDevice currentDevice]systemVersion].floatValue >= 6.0) {
        
        devc = [[NSUserDefaults standardUserDefaults]objectForKey:kDeviceUUID];
        if (!devc) {
            NSUUID *uuid = [[NSUUID alloc]init];
            devc = [uuid UUIDString];
        }
        
        self.macStr = devc;
        
    }else{
        if (!self.macStr) {
            
            devc = [GinNetworkUtils getMacAddress];
            NSArray *arr = [devc componentsSeparatedByString:@":"];
            NSString *str = nil;
            for (NSString *subStr in arr) {
                if (!str) {
                    str = subStr;
                }else{
                    str = [str stringByAppendingString: subStr];
                }
            }
            
            NSString *dateId = [[NSUserDefaults standardUserDefaults]objectForKey:kUniqueDataId];
            if (!dateId) {
                dateId = [NSString stringWithFormat:@"%d", (int)[[NSDate date]timeIntervalSince1970]];
            }
            
            self.macStr = [NSString stringWithFormat:@"%@_%@", str, dateId];
        }
        
        devc = self.macStr;
    }
    
    return devc;
    
}

// 登陆态参数格式化
- (NSMutableDictionary*)formatParameters:(NSDictionary*)parameters time:(int)time
{
    NSMutableDictionary* param = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if ([param objectForKey:@"g_tk"] == nil)
    {
        NSString *token = [self genToKey:[self getTokenStr]];
        if (token) {
            [param setObject:[self genToKey:[self getTokenStr]] forKey:@"g_tk"];
        }
    }
    
    [param setObject:[NSString stringWithFormat:@"%d", time] forKey:@"r"];
    [param setObject:[NSString stringWithFormat:@"i%@", [GinNetworkUtils getAppVersion]] forKey:@"v"];
    NSString *devc = [self getMacString];
    if (devc) {
        [param setObject:devc forKey:@"rid"];
    }
    [param setObject:[NSString stringWithFormat:@"%@", [[Reachability reachabilityForInternetConnection] currentNetWorkString]] forKey:@"g_net"];
    [param setObject:[GinNetworkUtils getChannelName] forKey:@"g_channel"];
    /////jailbreak 不越狱不传
    if(self.isJailBroken)
    {
        [param setObject:@"1" forKey:@"jflag"];
    }
    
    return param;
}

// post 方法的get参数添加
- (NSMutableDictionary*)formatPostParameters:(NSDictionary*)parameters time:(int)time
{
    NSMutableDictionary* param = [NSMutableDictionary dictionary];
    if ([param objectForKey:@"g_tk"] == nil)
    {
        NSString *token = [self genToKey:[self getTokenStr]];
        if (token) {
            [param setObject:[self genToKey:[self getTokenStr]] forKey:@"g_tk"];
        }
    }
    
    [param setObject:[NSString stringWithFormat:@"%d", time] forKey:@"r"];
    [param setObject:[NSString stringWithFormat:@"i%@", [GinNetworkUtils getAppVersion]] forKey:@"v"];
    
    NSString *devc = [self getMacString];
    if (devc) {
        [param setObject:devc forKey:@"rid"];
    }
    [param setObject:[NSString stringWithFormat:@"%@", [[Reachability reachabilityForInternetConnection] currentNetWorkString]] forKey:@"g_net"];
    [param setObject:[GinNetworkUtils getChannelName] forKey:@"g_channel"];
    
    if([param objectForKey:kLogReportModule])
    {
        [param setObject:[param objectForKey:kLogReportModule] forKey:kLogReportModule];
    }
    
    /////jailbreak 不越狱不传
    if(self.isJailBroken){
        [param setObject:@"1" forKey:@"jflag"];
    }
    
    return param;
}

- (NSError*)formatError:(NSDictionary*)responseObject atPath:(NSString*)path
{
    return [NSError errorWithDomain:path
                               code:[[responseObject objectForKey:@"errcode"] integerValue]
                           userInfo:responseObject];
}

//生成tk，用户接口校验
- (NSString*) genToKey:(NSString*)inStr
{
    if (nil == inStr) {
        return nil;
    }
    
    int hash = 5381;
    const char *ch = [inStr cStringUsingEncoding:NSASCIIStringEncoding];
    for (int i = 0; i < strlen(ch); ++i) {
        hash = (int)((hash << 5 & 0x7fffffff) + ch[i] + hash);
    }
    hash = hash & 0x7fffffff;
    return [NSString stringWithFormat:@"%d", hash];
}

- (NSString *)getTokenStr
{
    GinAccountInfo *account = [GinAccountInfo sharedAccountInfo];
    if (account.loginType == 1)
    {
        if (account.psKey && account.psKey.length > 0) {
            return account.psKey;
        }
        else if (account.sKey && account.sKey.length > 0)
        {
            return account.sKey;
        }
        else if(account.lsKey && account.lsKey)
        {
            return account.lsKey;
        }
    }
    else if (account.loginType == eShareQQ || account.loginType == eShareWeiChatFriend)
    {
        if(account.openId)
        {
            return account.openId;
        }
        else
        {
            return nil;
        }
    }
    else if (eShareSinaWeiBo == account.loginType)
    {
        if(account.sinaWeiboLoginDic.count > 0)
        {
            NSRange range = [[self defaultValueForHeader:@"Cookie"]rangeOfString:@"expire_time"];
            if (range.length > 0)
            {
                [self setBaseParamters:self];
            }
            return [self tokenMd5Str:account.token];
        }
        else if(account.openId)
        {
            return account.openId;
        }
        else
        {
            return nil;
        }
    }
    
    return nil;
}

- (NSString *)userIdentifier
{
    NSString *tokenStr = [self getTokenStr];
    return [self genToKey:tokenStr];
}

//增加post接口相关的w_tk
- (NSDictionary*)setWTkParameter:(NSDictionary*)param getParams:(NSDictionary*)getParams path:(NSString*)apiPath
{
    if (![self isNeedWtkParam:apiPath])
    {
        return param;
    }
    GinAccountInfo *accountInfo = [GinAccountInfo sharedAccountInfo];
    NSString *account;
    if (accountInfo.qqId && accountInfo.loginType == eWeishi)
    {
        account = accountInfo.qqId;
    }
    else if (accountInfo.wbUserInfo.weiShiId && accountInfo.loginType == eShareSinaWeiBo)
    {
        account = accountInfo.wbUserInfo.weiShiId;
    }
    else if(accountInfo.openId)
    {
        account = accountInfo.openId;
    }
    
    NSString *api = [apiPath lastPathComponent];
    NSRange range = [api rangeOfString:@".php"];
    api = [api substringToIndex:range.location];
    
    range = [apiPath rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *subStr = [apiPath substringToIndex:range.location];
    subStr = [subStr lastPathComponent];
    NSString *op = [NSString stringWithFormat:@"%@_%@", subStr, api];
    
    NSString *version = nil;
    NSString *r = nil;
    
    if (getParams)
    {
        version = [getParams objectForKey:@"v"];
        r = [getParams objectForKey:@"r"];
    }
    else
    {
        version = [param objectForKey:@"v"];
        r = [param objectForKey:@"r"];
    }
    
    NSString *w_tk = [self getPostTk:account api:op version:version time:r];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithDictionary:param];
    if (w_tk)
    {
        [parameters setObject:w_tk forKey:@"w_tk"];
    }
    
    return parameters;
}

- (NSString*)getPostTk:(NSString*)account api:(NSString*)op version:(NSString*)v time:(NSString*)r
{
    if (!account || !op || !v || !r) {
        return nil;
    }
    
    NSString *toMd5 = [NSString stringWithFormat:@"%@_%@_%@", v, account, op];
    NSString *firstMD5 = [GinNetworkUtils md5String:toMd5];
    firstMD5 = [firstMD5 lowercaseString];
    NSInteger md5BytesPerPart = 8;
    NSInteger md5Parts = ceil(firstMD5.length*1.0/md5BytesPerPart);
    NSInteger mixBytesPerPart = ceil(r.length*1.0/md5Parts);
    NSString *secondSrc = nil;
    for (int i = 0; i < md5Parts; ++i) {
        NSInteger md5Start = i * md5BytesPerPart;
        NSInteger mixStart = i * mixBytesPerPart;
        mixBytesPerPart = r.length - i *mixBytesPerPart < mixBytesPerPart ? r.length - i *mixBytesPerPart : mixBytesPerPart;
        NSRange firstRange = NSMakeRange(md5Start, md5BytesPerPart);
        NSRange secondRange = NSMakeRange(mixStart, mixBytesPerPart);
        
        if (firstRange.length > 0 && secondRange.length > 0) {
            if (secondSrc) {
                secondSrc = [NSString stringWithFormat:@"%@%@%@", secondSrc, [firstMD5 substringWithRange:firstRange], [r substringWithRange:secondRange]];
            }else{
                secondSrc = [NSString stringWithFormat:@"%@%@", [firstMD5 substringWithRange:firstRange], [r substringWithRange:secondRange]];
            }
        }
        
    }
    
    secondSrc = [GinNetworkUtils md5String:secondSrc];
    secondSrc = [secondSrc lowercaseString];
    return secondSrc;
}

-(BOOL)isNeedWtkParam:(NSString*)path
{
    //和服务器同学商量了，所有了的接口都加上wtk，不需要的他们不做校验
    return YES;
}

-(BOOL)isNeedcheckResultArc:(NSString*)path
{
    return YES;
}

//校验服务器返回的crc字符串
- (BOOL)checkResultArc:(NSDictionary*)headDic joson:(NSString*)jsonstr time:(int)time path:(NSString*)path error:(NSError*)err
{
    if (![headDic isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    if ([self isNeedcheckResultArc:path]) {
        NSString *str = [GinNetworkUtils md5String:[NSString stringWithFormat:@"%@_%@_%d_03o121s108r114a101v105h", jsonstr, [self getMacString], time]];
        if (str && str.length > 8) {
            str = [str substringToIndex:8];
        }
        str = [str lowercaseString];
        if ([str isEqualToString:[headDic objectForKey:@"Mvcrc"]]) {
            if (kKillErrorCode == err.code) {
                //需要自杀
                NSDictionary *tipDic = [err.userInfo objectForKey:@"tips"];
                NSString *errStr = nil;
                if ([tipDic isKindOfClass:[NSDictionary class]]) {
                    errStr = [tipDic objectForKey:@"content"];
                }else{
                    errStr = @"对不起，发生错误，需要重起应用";
                }
                
                [[UIAlertView alertViewWithTitle:errStr
                                         message:@""
                               cancelButtonTitle:@"确定"
                               otherButtonTitles:NULL
                                       onDismiss:^(NSInteger buttonIndex){
                                       }
                                        onCancel:^{
                                        }] show];
            }
            return YES;
        }else{
            if (jsonstr.length > 1024) {
                jsonstr = [jsonstr substringToIndex:1023];
            }
            
            if ([path isEqualToString:MICRO_VIDEO_API_APP_CONSOLE]) {
                return NO;
            }
            return YES;
        }
    }else{
        return YES;
    }
    
}

//检查网络
- (BOOL)checkNetWork
{
    return [GinNetworkUtils isNetWorkAvaible];
}

//判断微信token失败，微信token不对的时候会返回改错误码---子类重载
- (BOOL)checkWeixinTokenError:(NSError*)error api:(NSString*)api
{
    return NO;
}

//错误处理
- (void)checkError:(AFHTTPRequestOperation*)operation path:(NSString *)path error:(NSError *)error time:(int)time
{
    [self checkResultArc:operation.response.allHeaderFields
                   joson:operation.responseString
                    time:time
                    path:path
                   error:error];
    
}

//无法定位到服务器
- (void)checkNetWorkError1003:(NSError*)error api:(NSString*)api url:(NSString*)url
{
}

- (NSString *)makePostLogPath:(NSString *)path time:(NSInteger)time params:(NSDictionary *)params
{
    return [path stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(params, self.stringEncoding)];
}

- (NSString *)tokenMd5Str:(NSString *)inStr
{
    if (!inStr) {
        return nil;
    }
    NSString *md5Str = [GinNetworkUtils md5String:inStr];
    NSString *ret = [md5Str lowercaseString];
    NSRange range = NSMakeRange(8, 8);
    ret = [ret substringWithRange:range];
    return ret;
}

#pragma mark - help function

- (NSString *)generateCookieStringByAccountInfo
{
    NSString *retVal;
    
    GinAccountInfo *account = [GinAccountInfo sharedAccountInfo];
    int loginType = 1;
    switch (account.loginType) {
        case eWeishi:
            loginType = 1;
            break;
        case eShareQQ:
        case eShareQZone:
            loginType = 3;
            break;
        case eShareWeiChatFriend:
        case eShareWeiChatTimeLine:
            loginType = 2;
            break;
#ifdef kNeedSinaWeiboLogin
        case eShareSinaWeiBo:
        {
            loginType = 4;
        }
            break;
#endif
        default:
            break;
    }
    
    if (account.loginType == eWeishi)
    {
        if(account.lsKey && account.qqId)
        {
            retVal = [NSString stringWithFormat:@"lskey=%@;skey=%@;luin=o0%@;uin=o0%@;logintype=%d;ws_uid=%@",account.lsKey,account.sKey,account.qqId,account.qqId,loginType,account.wbUserInfo.weiShiId];
        }
    }
#ifdef kNeedSinaWeiboLogin
    else if (account.loginType == eShareSinaWeiBo)
    {
        if(account != nil && account.wbUserInfo.weiShiId  && account.sinaWeiboLoginDic.count > 0)
        {
            NSMutableString *cooki = [[NSMutableString alloc]init];
            for (NSString *key in account.sinaWeiboLoginDic) {
                if (![key isEqualToString:@"ws_a_rftoken"]) {
                    [cooki appendFormat:@"%@%@=%@", (cooki.length > 0 ? @";" : @""), key, [account.sinaWeiboLoginDic objectForKey:key]];
                }
            }
            
            [cooki appendFormat:@"%@ws_uid=%@;arc=%@", (cooki.length > 0 ? @";" : @""), account.wbUserInfo.weiShiId, [self tokenMd5Str:account.token]];
            retVal = cooki;
            
        }
        else if(account != nil && account.token && account.openId && account.tokenExpire)
        {
            
            retVal = [NSString stringWithFormat:@"access_token=%@;weibo_uid=%@;expire_time=%@;logintype=%d",account.token,account.openId, account.tokenExpire, loginType];
        }
    }
#endif
    else{
        if(account != nil && account.openId && account.token)
        {
            if (account.loginType == eShareWeiChatFriend || account.loginType == eShareWeiChatTimeLine)
            {
                retVal = [NSString stringWithFormat:@"token=%@;openid=%@;logintype=%d;ws_uid=%@;expire=%@",account.token,account.openId,loginType, account.wbUserInfo.weiShiId, account.tokenExpire];
            }
            else
            {
                retVal = [NSString stringWithFormat:@"token=%@;openid=%@;logintype=%d;ws_uid=%@",account.token,account.openId,loginType, account.wbUserInfo.weiShiId];
            }
        }
    }
    
    return retVal;
}

@end
