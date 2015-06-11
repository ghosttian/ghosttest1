//
//  MVVideoEffectDefines.h
//  microChannel
//
//  Created by alankong on 9/5/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#ifndef microChannel_MVVideoEffectDefines_h
#define microChannel_MVVideoEffectDefines_h

//系统配置id
typedef enum {
    MVConfigurationInvalid = -1, //非法配置
    MVConfigurationNone = 1, //无滤镜,无水印,无主题,关闭原音无配乐
    MVConfigurationClose = 2, //关闭原音
    MVConfigurationAddition = 3, //选择库
    MVConfigurationSystemMax = 10,
} MVConfigurationSystem;

//logo config id
#define kMVConfigurationLogoForNormalVideo    100
#define kMVConfigurationLogoForAnonymousVideo 110

//取一组配置
typedef enum {
    MVConfigGroupTypeWatermark = 1,
    MVConfigGroupTypeMusic = 2
} MVConfigGroupType;

//
#define kConfigMusics           @"musics"
#define kConfigFilters          @"filters"
#define kConfigWatermarks       @"watermarks"
#define kConfigBeauty           @"whiteeffect"//美颜

#define kConfigLongMusics       @"longmusics"
#define kConfigLongFilters      @"longfilters"
#define kConfigLongWatermarks   @"longwatermarks"
#define kConfigLongBeauty       @"longwhiteffect" //长视频美颜

#define kConfigPhotoFilters     @"photowhiteeffect" //影集滤镜

#define kConfigLogo             @"logo"
#define kConfigVersion          @"version"
#define kConfigLibEnable        @"libenable"//素材音乐库扩展开关

//配置groupID
#define kConfigGroupIDDefault       @"default"//默认
#define kConfigGroupIDDownloaded    @"downloaded"//下载过的,用户相关
#define kConfigGroupIDRecent        @"recent"//使用过的,用户相关
//#define kConfigGroupIDExtend        @"extend"//素材库扩展（无效了）

//#define kConfigGroupIDLongMusicRecent @"longmusicrecent" //长视频音乐最近使用
//#define kconfigGroupIDLongWaterMarkRecent @"longwatermarkrecent" //长视频水印最近使用

#endif
