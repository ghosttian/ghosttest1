//
//  GinUploadStrategyByHTTPVideoExtension.m
//  GinCore
//
//  Created by joeqiwang on 14-12-25.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import "GinUploadStrategyByHTTPVideoExtension.h"
#import "VideoExtensionHttpClient.h"
#import "UIAlertView+BlockAddition.h"
#import "MicroVideoNetworkImp.h"
#import "GinLog.h"

@implementation GinUploadStrategyByHTTPVideoExtension

- (void)suspendUploadVideo
{
    if (self.requestID != nil && [self.requestID isKindOfClass:[NSString class]])
    {
        GINFO(LogModuleVideoUpload, @"suspend video upload, request id is: %@", self.requestID);
        [[VideoExtensionHttpClient sharedInstance] cancelHTTPOperationByOperationID:self.requestID];
    }
}

- (void)displayWarningWithText:(NSString*)wanring
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIAlertView alertViewWithTitle:wanring
                                 message:@""
                       cancelButtonTitle:@"确定"
                       otherButtonTitles:NULL
                               onDismiss:^(NSInteger buttonIndex){
                               }
                                onCancel:^{
                                }] show];
        
    });
}

- (void)generalUploadApplyWithParameters:(NSDictionary*)params
{
    if (ShootVideoTypeShortVideo == self.VideoType)
    {
        [MicroVideoNetworkImp applyUpload:params success:^(MicroVideoQueryResult* result)
         {
             [self applyUploadRequestSucceeded:result];
         }
                                     fail:^(NSError *error)
         {
             [self applyUploadRequestFailed:error];
         }];
    }
    else if (ShootVideoTypeLongVideo == self.VideoType)
    {
        [MicroVideoNetworkImp applyLongVideoUpload:params success:^(MicroVideoQueryResult* result)
         {
             [self applyUploadRequestSucceeded:result];
         }
                                              fail:^(NSError *error)
         {
             [self applyUploadRequestFailed:error];
         }];
    }
}

- (void)generalUploadVideoWithVideoData:(NSData*)uploadData andParameters:(NSDictionary*)params
{
    self.requestStartDate = [NSDate date];
    if (ShootVideoTypeShortVideo == self.VideoType)
    {
        [MicroVideoNetworkImp uploadVideo4Weishi:uploadData uploadParams:params success:^(MicroVideoQueryResult* result)
         {
             [self videoUploadRequestSucceeded:result];
         }
                                            fail:^(NSError *error)
         {
             [self videoUploadRequestFailed:error];
         }];
    }
    else if (ShootVideoTypeLongVideo == self.VideoType)
    {
        [MicroVideoNetworkImp uploadLongVideo4Weishi:uploadData uploadParams:params success:^(MicroVideoQueryResult* result)
         {
             [self videoUploadRequestSucceeded:result];
         }
                                                fail:^(NSError *error)
         {
             [self videoUploadRequestFailed:error];
         }];
    }
}

@end
