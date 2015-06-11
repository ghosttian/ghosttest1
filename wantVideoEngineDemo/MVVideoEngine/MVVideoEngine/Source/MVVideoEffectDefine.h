//
//  MVVideoEffectDefine.h
//  microChannel
//
//  Created by eson on 14-9-3.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#ifndef microChannel_MVVideoEffectDefine_h
#define microChannel_MVVideoEffectDefine_h

static NSString * const kMVVideoEffectPlayerPlayVideoEndNotification = @"kMVVideoEffectPlayerPlayVideoEndNotification";

static NSString * const kMVVideoEffectParserValueSelfRefer = @"#";
static NSString * const kMVVideoEffectParserValuePercentFlag = @"%";

static NSString * const kMVVideoEffectParserKeyUserData = @"userdata";
static NSString * const kMVVideoEffectParserKeyFilterData = @"filterdata";

static NSString * const kMVVideoEffectParserKeyStageArray = @"stage_array";
static NSString * const kMVVideoEffectParserKeyAnimationPath = @"animation_path";
static NSString * const kMVVideoEffectParserKeyResourceMap = @"resource_map";
static NSString * const kMVVideoEffectParserKeyFilterConfig = @"filter_config";

static NSString * const kMVVideoEffectParserKeyURL = @"url";
static NSString * const kMVVideoEffectParserKeyWatermark = @"watermarks";
static NSString * const kMVVideoEffectParserKeyResourceID = @"resource_id";
static NSString * const kMVVideoEffectParserKeyType = @"type";
static NSString * const kMVVideoEffectParserKeyVideo = @"video";
static NSString * const kMVVideoEffectParserKeyPicture = @"picture";
static NSString * const kMVVideoEffectParserKeyCurve = @"curve";
static NSString * const kMVVideoEffectParserKeyInputID = @"input_id";

static NSString * const kMVVideoEffectParserKeyTimeRange = @"time_range";
static NSString * const kMVVideoEffectParserKeyStageID = @"stage_id";
static NSString * const kMVVideoEffectParserKeyFilterID = @"filter_id";
static NSString * const kMVVideoEffectParserKeyFilterType = @"filtertype"; //简单滤镜，美颜色，老电影之类的
static NSString * const kMVVideoEffectParserKeyLogoTime = @"logo_time";

static NSString * const kMVVideoEffectParserKeyCut = @"cut";

static NSString * const kMVVideoEffectParserKeyLength = @"length";
static NSString * const kMVVideoEffectParserKeyRefer = @"refer";
static NSString * const kMVVideoEffectParserKeySpeed = @"speed";
static NSString * const kMVVideoEffectParserKeyStart = @"start";
static NSString * const kMVVideoEffectParserKeyVideoStart = @"video_start";
    
static CFTimeInterval const kMVVideoEffectProcessingBufferMinGapTime = 0.01;
static CFTimeInterval const kMVVideoEffectStaticFrameCompositionMinDuration = 0.25; //最小定帧TimeRange，保证至少有一个buffer
static CFTimeInterval const kMVVideoEffectTimeRangeSpeedMinThreshold = 0.1001; //最小速度，小于这个值为定帧

static NSInteger const kMVVideoEffectTimeLineFilterID = 10000; //无滤镜
static NSInteger const kMVVideoEffectCombineMovieFilterID = 10002;// 叠加视频的滤镜ID
static NSInteger const kMVVideoEffectCombineDirectingMovieFilterID = 10010;// 10010蒙板指导视频滤镜ID
static NSInteger const kMVVideoEffectCombineLightingMovieFilterID = 11210;// 光照效果滤镜ID

static NSInteger const kMVVideoEffectCombineBlurMovieFilterID = 10003;
static NSInteger const kMVVideoEffectCombineSCBMovieFilterID = 10008;
static NSInteger const kMVVideoEffectCombineRadialBlurMovieFilterID = 10013;
static NSInteger const kMVVideoEffectCombineCurveRGBMovieFilterID = 11100;
static NSInteger const kMVVideoEffectCombineAdvancedCurveRGBMovieFilterID = 11200;

typedef void(^MVVideoEffectVideoProcessCompletionBlock)(NSString *path, NSError *error);

//配乐使用
static NSString * const kMVVideoEffectSelectedMusicNotification = @"kMVVideoEffectSelectedMusicNotification";
static NSString * const kMVVideoEffectNoMusicNotification = @"kMVVideoEffectNoMusicNotification";


typedef enum {
    MVEffectVideoCompositionTrackPreferredTrackIDOriginVideo = 1000, //原始视频
    MVEffectVideoCompositionTrackPreferredTrackIDOriginAudio,        //原始音频
    MVEffectVideoCompositionTrackPreferredTrackIDMixMusicAudio,      //背景音乐音频
} MVEffectVideoCompositionTrackPreferredTrackID;


#endif
