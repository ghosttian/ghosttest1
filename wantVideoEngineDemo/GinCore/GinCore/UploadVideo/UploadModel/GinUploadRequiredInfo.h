//
//  GinUploadRequiredInfo.h
//  microChannel
//
//  Created by wangqi on 14-2-17.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MVVideoCommonDefine.h"
#import "GinUploadVideoDef.h"

// Entity class为视频上传封装数据
@interface GinUploadRequiredInfo : NSObject

@property (nonatomic, assign) CGFloat VideoDuration;
@property (nonatomic, assign) VideoRateType VideoRate;
@property (nonatomic, strong) UIImage* CoverImage;
@property (nonatomic, copy) NSString* VideoPath;
@property (nonatomic, copy) NSString* MsgID;        // just available for long video upload
@property (nonatomic, copy) NSString* Title;        // just available for long video upload
@property (nonatomic, assign) BOOL isAnniversary;
@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, assign) MVCompositiongDataVideoType shortVideoOrLongVideo;
@property (nonatomic, assign) unsigned long long uploadedOffset;
@property (nonatomic, copy) NSString *requestID;
@property (nonatomic, copy) NSString *fid;
@property (nonatomic, copy) NSString *vid;
@property (nonatomic, copy) NSString *checkKey;
@property (nonatomic, assign) FtnUploadStep uploadStage;

- (NSString*)description;

@end

