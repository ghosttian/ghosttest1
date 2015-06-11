//
//  GinUploadVideoDef.h
//  GinCore
//
//  Created by joeqiwang on 14-12-24.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#ifndef GinCore_GinUploadVideoDef_h
#define GinCore_GinUploadVideoDef_h

#define WEISHI_APPLAY_UPLOAD_PROGRESS             (0.15)
#define WEISHI_UPLOAD_VOIDEO_PROGRESS             (0.83)
#define WEISHI_PUBLISH_WEISHI_PROGRESS            (0.10)

typedef enum _VideoRateType{
    kVideoRateHigh = 1,
    kVideoRateMiddle,
    kVideoRateLower
}VideoRateType;

typedef enum{
    UP_STEP_APPLY = 0,
    UP_STEP_UPLOAD,
    UP_STEP_FINISH,
    UP_STEP_PUBLISH
}FtnUploadStep;

typedef enum
{
    kGinVideoUploadPreApply             = 1,
    kGinVideoUploadApply                = 2,
    kGinVideoUploadVideo                = 4,
    kGinVideoUploadFinished             = 8,    // before this stage are main stages
    kGinVideoUploadDuringNetworkShift   = 64,
    kGinVideoUploadSuspend              = 128,
    kGinVideoUploadNOTUsed              = -1
}GinVideoUploadStage;


typedef enum eSendingBarStatus{
    eSendingDefault,
    esendingPictures,
    esendingMovie,
    eSendingFail,
    eSendingSucc,
    eSendingPause,//暂停上传
    eSendingDelete,//删除长视频
    eCompositeFail,//视频合成失败
    eCompositing,//视频合成中
}eSendingBarStatus;


typedef enum
{
    kGinUploadStrategyFTN = 0,
    kGinUploadStrategyHTTP = 1
}GinUploadStrategyType;

#endif
