//
//  MicroVideoNetworkImp.h
//  GinNetwork
//
//  Created by wangqi on 14-11-11.
//  Copyright (c) 2014年 weishi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MicroVideoSuccess)(id result);
typedef void (^MicroVideoFail)(NSError* error);

@interface MicroVideoNetworkImp : NSObject

// log file申请上传
+ (void)applyLogFileUpload:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail;

// log file文件上传接口
+ (void)uploadLogFile:(NSData *)data uploadParams:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail;

// 短视频申请上传
+ (void)applyUpload:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail;

//视频上传接口
+ (void)uploadVideo4Weishi:(NSData *)data uploadParams:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail;

// 长视频申请上传接口
+ (void)applyLongVideoUpload:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail;

// 长视频上传接口
+ (void)uploadLongVideo4Weishi:(NSData *)data uploadParams:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail;

// 取消长视频上传
+ (void)postCancelUpLoadLongVideo:(NSDictionary *)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail;

//上传图片
+ (void)postImageParams:(NSDictionary*)param success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail;

//发表广播（原创、评论、赞、回复）
+ (void)postPublishParams:(NSDictionary*)param success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail;

//热门标签列表
+ (void)getHotTagsWithSuccess:(MicroVideoSuccess)success fail:(MicroVideoFail)fail;

+ (void)getLbsInfo:(NSDictionary*)params success:(MicroVideoSuccess)success fail:(MicroVideoFail)fail;


@end
