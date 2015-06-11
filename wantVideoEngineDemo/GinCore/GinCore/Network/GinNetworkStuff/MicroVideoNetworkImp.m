//
//  MicroVideoNetworkImp.m
//  GinNetwork
//
//  Created by wangqi on 14-11-11.
//  Copyright (c) 2014年 weishi. All rights reserved.
//

#import "MicroVideoNetworkImp.h"
#import "VideoExtensionHttpClient.h"
#import "NSDictionary+Additions.h"

// log file上传接口
NSString *const KMICRO_VIDEO_API_APPLY_UPLOAD_LOG_FILE           =   @"info/applyLogFile.php";
NSString *const KMICRO_VIDEO_API_UPLOAD_LOG_FILE                 =   @"info/uploadLogFile.php";
// 短视频上传接口
NSString *const KMICRO_VIDEO_API_APPLY_UPLOAD                    =   @"video/applyVideo.php";
NSString *const KMICRO_VIDEO_API_UPLOAD_VIDEO                    =   @"video/uploadVideo.php";
// 长视频上传接口
NSString *const KMICRO_VIDEO_API_APPLY_UPLOAD_LONG_VIDEO         =   @"video/applyLongVideo.php";
NSString *const KMICRO_VIDEO_API_UPLOAD_LONG_VIDEO               =   @"video/uploadLongVideo.php";
//取消长视频上传
NSString *const KMICRO_VIDEO_API_CANCEL_LONG_VIDEO               =   @"video/cancelLongVideo.php";
// 封面上传
NSString *const KMICRO_VIDEO_API_UPLOAD_HEAD_PIC                 =   @"upload/image.php";
// 视频发布
NSString *const KMICRO_VIDEO_API_PUBLISH                         =   @"t/publish.php";

NSString *const KMICRO_VIDEO_API_HOT_TAG                         =   @"tag/hotTag.php";  //热门标签列表

NSString *const KMICRO_VIDEO_API_LBSINFO                         =   @"t/lbs.php";

@implementation MicroVideoNetworkImp

// log file申请上传
+ (void)applyLogFileUpload:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail
{
    [[VideoExtensionHttpClient sharedInstance] postPath:KMICRO_VIDEO_API_APPLY_UPLOAD_LOG_FILE withParameters:params success:^(MicroVideoQueryResult *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

// log file文件上传接口
+ (void)uploadLogFile:(NSData *)data uploadParams:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail
{
    
    [[VideoExtensionHttpClient sharedInstance] postTextFileWithPath:KMICRO_VIDEO_API_UPLOAD_LOG_FILE withFileData:data
                                                 withParameters:params success:^(MicroVideoQueryResult *result) {
                                                     if (success)
                                                     {
                                                         success(result);
                                                     }
                                                 } failure:^(NSError *error) {
                                                     if (fail)
                                                     {
                                                         fail(error);
                                                     }
                                                 }];
}

// 申请上传接口
+ (void)applyUpload:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail
{
    [[VideoExtensionHttpClient sharedInstance] postPath:KMICRO_VIDEO_API_APPLY_UPLOAD withParameters:params success:^(MicroVideoQueryResult *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

//视频上传接口
+ (void)uploadVideo4Weishi:(NSData *)data uploadParams:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail
{
    [[VideoExtensionHttpClient sharedInstance] postVideoWithPath:KMICRO_VIDEO_API_UPLOAD_VIDEO withVideoData:data withParameters:params success:^(MicroVideoQueryResult *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

// 长视频申请上传接口
+ (void)applyLongVideoUpload:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail
{
    [[VideoExtensionHttpClient sharedInstance] postPath:KMICRO_VIDEO_API_APPLY_UPLOAD_LONG_VIDEO withParameters:params success:^(MicroVideoQueryResult *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

// 长视频上传接口
+ (void)uploadLongVideo4Weishi:(NSData *)data uploadParams:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail
{
    [[VideoExtensionHttpClient sharedInstance] postVideoWithPath:KMICRO_VIDEO_API_UPLOAD_LONG_VIDEO withVideoData:data withParameters:params success:^(MicroVideoQueryResult *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

// 取消长视频上传
+ (void)postCancelUpLoadLongVideo:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail
{
    [[VideoExtensionHttpClient sharedInstance] postPath:KMICRO_VIDEO_API_CANCEL_LONG_VIDEO withParameters:params success:^(MicroVideoQueryResult *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

//上传图片
+ (void)postImageParams:(NSDictionary*)param success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail
{
    [[VideoExtensionHttpClient sharedInstance] postImgWithPath:KMICRO_VIDEO_API_UPLOAD_HEAD_PIC
                                            withParameters:param
                                                   success:^(MicroVideoQueryResult *result) {
                                                       
                                                       NSMutableArray *entities = [NSMutableArray array];
                                                       NSString* picurl = [result.data ginStringValueForKey:@"url"];
                                                       if(picurl)
                                                       {
                                                           [entities addObject:picurl];
                                                       }
                                                       result.arrayInfo = entities;
                                                       success(result);
                                                       
                                                   }
                                                   failure:^(NSError *error) {
                                                       fail(error);
                                                   }];
    
}

//发表广播（原创、评论、赞、回复）
+ (void)postPublishParams:(NSDictionary*)param success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:param];
    
    [[VideoExtensionHttpClient sharedInstance] postPath:KMICRO_VIDEO_API_PUBLISH withParameters:dic success:^(MicroVideoQueryResult *result) {
        success(result);
//        if ([GinVerifyManager shareInstance].failBlock == fail)
//        {
//            [[GinVerifyManager shareInstance] setResult:kCodeSuccess withUrl:nil];
//        }
    } failure:^(NSError *error) {
//        if (error.code == -16)
//        {
//            if ([GinVerifyManager shareInstance].failBlock != fail && [[GinVerifyManager shareInstance] inVerify])
//            {
//                fail(error);
//            }
//            else
//            {
//                [GinVerifyManager shareInstance].successBlock = success;
//                [GinVerifyManager shareInstance].failBlock = fail;
//                [GinVerifyManager shareInstance].savedParams = param;
//                [GinVerifyManager shareInstance].error = error;
//                
//                NSDictionary *data = [[error userInfo] objectForKey:@"data"];
//                NSString *url = [data objectForKey:@"url"];
//                [[GinVerifyManager shareInstance] showVerifyController:url];
//                [GinVerifyManager shareInstance].submitBLock = ^(NSMutableDictionary *dic, void (^successBlock)(id result),void (^failBlock)(NSError* error)){
//                    [MicroVideoAPIManager postPublishParams:dic success:successBlock fail:failBlock];
//                } ;
//            }
//        }
//        else
//        {
//            if ([GinVerifyManager shareInstance].failBlock == fail)
//            {
//                [[GinVerifyManager shareInstance] setResult:kCodeSuccess withUrl:nil];
//            }
//            fail(error);
//        }
        fail(error);
    }];
}

//热门标签列表
+ (void)getHotTagsWithSuccess:(MicroVideoSuccess)success fail:(MicroVideoFail)fail {
    [[VideoExtensionHttpClient sharedInstance] getPath:KMICRO_VIDEO_API_HOT_TAG withParameters:nil success:^(MicroVideoQueryResult *result) {
        if (![result.data isKindOfClass:[NSDictionary class]]) {
            return;
        }
        if (success) {
            success(result.data);
        }
    } failure:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

//根据经纬度获取地理位置信息
+ (void)getLbsInfo:(NSDictionary*)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail
{
    [[VideoExtensionHttpClient sharedInstance] getPath:KMICRO_VIDEO_API_LBSINFO withParameters:params success:^(MicroVideoQueryResult *result) {
        if (success) {
            NSString * address = [result.data objectForKey:@"name"];
            success(address);
        }
    } failure:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

@end
