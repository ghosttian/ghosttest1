//
//  MVVideoEffectModel.h
//  microChannel
//
//  Created by aidenluo on 8/29/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "MVWaterMarkFactory.h"
#import "MVVideoCommonDefine.h"
#import <AVFoundation/AVAsset.h>

@interface MVVideoEffectModel : NSObject

@property(nonatomic, strong) NSArray    *combineAssets;
@property(nonatomic, strong) AVAsset    *originAsset;
@property(nonatomic, copy) NSString     *originVideoPath;//原视频
@property(nonatomic, copy) NSString     *effectVideoPath;//特效处理视频，仅包含video
@property(nonatomic, copy) NSString     *beautyVideoPath;//美颜处理视频, 仅包含video
@property(nonatomic, copy) NSString     *finalVideoPath;//最终视频，包含video,audio

@property(nonatomic, copy) NSString     *musicPath;    //配乐
@property(nonatomic, copy) NSString     *albumMusicPath; //动态影集配乐
@property(nonatomic, getter = isMusicEnable) BOOL   musicEnable;

@property(nonatomic, assign) CGFloat    musicVolume;
@property(nonatomic, assign) BOOL       isSilent;
@property(nonatomic, assign) BOOL       removeOriginAudio;
@property(nonatomic, assign) MVCompositingDataVideoSourceType videoSourceType;
@property (nonatomic, assign) float videoSourceTypePickFromLibraryBitrate;

@property(nonatomic, assign) ShootVideoType videoShootType; //上传使用
@property(nonatomic, assign) MVCompositiongDataVideoType videoType; //长短视频类型

@property(nonatomic, assign) NSTimeInterval     selectCapImageTime;//选择封面时间

@property (nonatomic, copy) NSString    *watermarkID;//水印ID
@property (nonatomic, copy) NSString    *filterID; //特效ID
@property (nonatomic, copy) NSString    *beautyFilterID; //美颜ID
@property (nonatomic, copy) NSString    *musicID;//音乐ID
@property (nonatomic, copy) NSString    *albumMusicID; // 动态影集音乐ID

@property(nonatomic, copy) NSString     *albumName; //动态影集名称
@property(nonatomic, copy) NSString     *filterName; //特效
@property(nonatomic, copy) NSString     *musicName;  //音乐名称
@property(nonatomic, copy) NSString     *albumMusicName; //动态影集音乐名称
@property(nonatomic, copy) NSString     *waterMarkName; //水印名称

//特效的配置信息
@property(nonatomic, strong) NSDictionary *effectUserData;

//美颜的特效配置
@property(nonatomic, strong) NSDictionary *beautyUserData;

//音乐的配置
@property(nonatomic, strong) NSDictionary *musicUserData;
@property(nonatomic, strong) NSDictionary *albumMusicUserData;

//水印的配置
@property(nonatomic, strong) NSDictionary *waterMarkUserData;

//@property(nonatomic, strong) MVWaterMarkView *waterMarkView;


- (instancetype)init;

//+ (void)setEffectModelWithDraftVideoData:(GinDraftVideoData*) draftVideoData effectModel:(MVVideoEffectModel*)effectModel;


@end
