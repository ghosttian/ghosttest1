//
//  GinUploadRequiredInfo.m
//  microChannel
//
//  Created by wangqi on 14-2-17.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinUploadRequiredInfo.h"

@implementation GinUploadRequiredInfo

- (void)dealloc
{
}

- (NSString*)description
{
    NSString *retVal = [NSString stringWithFormat:@"duration=%f; videoRate=%d; imageAddr=%p; videpPath=%@; msgID=%@; title=%@; uploadedOffset=%llu; fid=%@; vid=%@; checkKey=%@", self.VideoDuration, self.VideoRate, self.CoverImage, self.VideoPath, self.MsgID, self.Title, self.uploadedOffset, self.fid, self.vid, self.checkKey];
    return retVal;
}

- (id)copyWithZone:(NSZone *)zone
{
    GinUploadRequiredInfo *info = [[[self class] allocWithZone:zone] init];

    info.VideoDuration = self.VideoDuration;
    info.VideoRate = self.VideoRate;
    info.CoverImage = self.CoverImage;
    info.VideoPath = self.VideoPath;
    info.MsgID = self.MsgID;
    info.Title = self.Title;
    info.isAnniversary = self.isAnniversary;
    info.shortVideoOrLongVideo = self.shortVideoOrLongVideo;
    info.videoSize = self.videoSize;
    info.uploadedOffset = self.uploadedOffset;
    info.requestID = self.requestID;
    info.fid = self.fid;
    info.vid = self.vid;
    info.checkKey = self.checkKey;
    info.uploadStage = self.uploadStage;

    return info;
}

@end
