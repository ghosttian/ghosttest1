//
//  MVVideoCommonDefine.h
//  microChannel
//
//  Created by aidenluo on 5/6/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

typedef NS_ENUM(NSInteger, ShootVideoType)
{
    ShootVideoTypeShortVideo,
    ShootVideoTypeLongVideo,
    ShootVideoTypeInitiateContinuableVideo,
    ShootVideoTypeAttendContinualeVideo,
};

typedef NS_ENUM(NSInteger, MVCompositiongDataVideoType){
    MVCompositiongDataVideoShortType = 0,  //8秒钟原视频(短视频)
    MVCompositiongDataVideoLongType = 1    //长视频
};

typedef NS_ENUM(NSInteger, MVCompositingDataVideoSourceType) {
    MVCompositingDataVideoSourceTypeDefault = 0,	    //默认值
    MVCompositingDataVideoSourceTypePhotosMerged = 1,      //来自图片合成视频
    MVCompositingDataVideoSourceTypePickFromLibrary = 2,   //来自本地拾取视频
    MVCompositingDataVideoSourceTypePhotosCombine = 3,  //视频拼接
};

