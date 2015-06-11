//
//  VideoExtensionHttpClient.m
//  GinCore
//
//  Created by joeqiwang on 14-12-17.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import "VideoExtensionHttpClient.h"
#import "UIAlertView+BlockAddition.h"
#import "KeychainItemWrapper.h"

const int kWeixintokenExpire    =   -14;     //微信token失效（每隔2消失失效，需要刷新token）
const int kweiXinTokenError     =   -15;     //微信token校验失败
const int kSinaWeibokenExpire   =   -19;     //sinatoken失效（每隔2小时失效，需要刷新token）
const int kSinaWeiboTokenError  =   -20;     //sina token校验失
extern NSString *const NetworkAPIBaseUrl;
extern NSString *const KMICRO_VIDEO_API_APPLY_UPLOAD_LOG_FILE;
extern NSString *const KMICRO_VIDEO_API_UPLOAD_LOG_FILE;

@implementation VideoExtensionHttpClient

+ (VideoExtensionHttpClient*)sharedInstance
{
    static dispatch_once_t onceToken;
    static VideoExtensionHttpClient* instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:NetworkAPIBaseUrl]];
    });
    
    return instance;
}

- (void)checkError:(AFHTTPRequestOperation*)operation path:(NSString *)path error:(NSError *)error time:(int)time
{
    [super checkError:operation path:path error:error time:time];
    
    // 因为申请上传日志和上传日志已经放到GinCore，而不能进行token刷新了，所以这两个接口不用尽心提示
    if ([path isEqualToString:KMICRO_VIDEO_API_APPLY_UPLOAD_LOG_FILE] ||
        [path isEqualToString:KMICRO_VIDEO_API_UPLOAD_LOG_FILE])
    {
        return;
    }
    
    if (kWeixintokenExpire == error.code ||
        kweiXinTokenError == error.code ||
        kSinaWeibokenExpire == error.code ||
        kSinaWeiboTokenError == error.code)
    {
        [[UIAlertView alertViewWithTitle:@"登陆状态失效，请重新进入微视"
                                 message:@""
                       cancelButtonTitle:@"确定"
                       otherButtonTitles:NULL
                               onDismiss:^(NSInteger buttonIndex){
                               }
                                onCancel:^{
                                }] show];
    }
}

@end
