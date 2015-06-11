//
//  GinLoggerModuleFilter.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinLoggerModuleFilter.h"
#import "LogEvent.h"
#import "GinLog.h"

//// define arrays with specific module file names, then we can activate log by module
//static char* const kUploadModuleFiles[] = {
//    "GinUploadSoldier.m", "GinUploadStrategyBase.m", "GinVideoUploadByFTN.mm", "GinUploadStrategyByHTTP.m", "GinUploadCoachBase.m", "GinUploadCoachChangeSizeBySpeed.m", "GinUploadCoachSharkFin.m", "GinUploadUtil.mm", nil
//};
//
//static char* const kWatterFlowModuleFiles[] = {
//    "GinDetailViewController.m", "GinNewWaterFlowViewController.m", "GinWaterFlowViewController.m", nil
//};

static int const kModuleActivationMap[] = {
    1, //LogModuleVideoEdit
    1, //LogModuleVideoUpload
    1, //LogModuleVideoDownload
    1, //LogModuleWriteOperation
    1, //LogModulePrivateMessage
    1, //LogModuleUIWaterFlow
    1, //LogModuleUIDetailPage
    1, //LogModuleLogin
    1, //LogModuleCommonDebug
    1, //LogModuleGeneralCatchedException
    1, //LogModuleMessage
    1, //LogModuleCommon
    1, //LogModuleChannel
    1, //LogModuleTag
    1, //LogModuleDelegateJump
    1, //LogModuleUserProfile
    1, //LogModuleMandatoryReport
    1, //LogModuleShare
    1, //LogModuleEmblem
    1, //LogModuleDataArchive
    1, //LogModuleAppCrash
    1, //LogModuleAnniversary
};

// to notify user which modlue this log belongs to
NSString *const kVideoEditModulePrefix          =   @"MODULE_VIDEO_EDIT";
NSString *const kVideoUploadModulePrefix        =   @"MODULE_UPLOAD";
NSString *const kVideoDownloadModulePrefix      =   @"MODULE_DOWNLOAD";
NSString *const kWriteOperationModulePrefix     =   @"MODULE_WRITE_OPERATION";
NSString *const kPrivateMessageModulePrefix     =   @"MODULE_PRIVATE_MESSAGE";
NSString *const kMessageModulePrefix            =   @"MODULE_MESSAGE";
NSString *const kChannelModulePrefix            =   @"MODULE_CHANNEL";
NSString *const kTagModulePrefix                =   @"MODULE_TAG";
NSString *const kUserProfileModulePrefix        =   @"MODULE_USER_PROFILE";
NSString *const kDelegateJumpPrefix             =   @"MODULE_DELEGATE_JUMP";
NSString *const kUIWaterFlowPrefix              =   @"MODULE_UI_WATERFLOW";
NSString *const kUIDetailPagePrefix             =   @"MODULE_UI_DETAIL_PAGE";
NSString *const kLoginPrefix                    =   @"MODULE_LOGIN";
NSString *const kCommonDebugPrefix              =   @"MODULE_COMMON_DEBUG";
NSString *const kGeneralCatchedExceptionPrefix  =   @"MODULE_GENERAL_CATCHED_EXCEPTION";
NSString *const kCommonPrefix                   =   @"MODULE_COMMON";
NSString *const kMandatoryReportModulePrefix    =   @"MODULE_MANDATORY_REPORT";
NSString *const kShareModulePrefix              =   @"MODULE_SHARE";
NSString *const kEmblemModulePrefix             =   @"MODULE_EMBLEM";
NSString *const kDataArchivePrefix              =   @"MODULE_DATA_ARCHIVE";
NSString *const kAppCrashPrefix                 =   @"MODULE_APP_CRASH";
NSString *const kAnniversaryPrefix              =   @"MODULE_ANNIVERSARY";


@implementation GinLoggerModuleFilter

- (BOOL)decide:(LogEvent**)logEvent
{
    // 该module的log是enable的
    if (1 == kModuleActivationMap[(*logEvent).moduleType-1])
    {
        (*logEvent).moduleName = [self getModuleNameWithModuleType:(*logEvent).moduleType];
        return NO;
    }
    
    return YES;
}

- (NSString *)getModuleNameWithModuleType:(LogModuleType)aModuleType
{
    NSString* retVal = nil;
    
    switch (aModuleType)
    {
        case LogModuleVideoEdit:
        {
            retVal = kVideoEditModulePrefix;
        }
            break;
        case LogModuleVideoUpload:
        {
            retVal = kVideoUploadModulePrefix;
        }
            break;
        case LogModuleVideoDownload:
        {
            retVal = kVideoDownloadModulePrefix;
        }
            break;
        case LogModuleWriteOperation:
        {
            retVal = kWriteOperationModulePrefix;
        }
            break;
        case LogModulePrivateMessage:
        {
            retVal = kPrivateMessageModulePrefix;
        }
            break;
        case LogModuleUIWaterFlow:
        {
            retVal = kUIWaterFlowPrefix;
        }
            break;
        case LogModuleUIDetailPage:
        {
            retVal = kUIDetailPagePrefix;
        }
            break;
        case LogModuleLogin:
        {
            retVal = kLoginPrefix;
        }
            break;
        case LogModuleCommonDebug:
        {
            retVal = kCommonDebugPrefix;
        }
            break;
        case LogModuleGeneralCatchedException:
        {
            retVal = kGeneralCatchedExceptionPrefix;
        }
            break;
        case LogModuleMessage:
        {
            retVal = kMessageModulePrefix;
        }
            break;
        case LogModuleCommon:
        {
            retVal = kCommonPrefix;
        }
            break;
        case LogModuleChannel:
        {
            retVal = kChannelModulePrefix;
        }
            break;
        case LogModuleTag:
        {
            retVal = kTagModulePrefix;
        }
            break;
        case LogModuleDelegateJump:
        {
            retVal = kDelegateJumpPrefix;
        }
            break;
        case LogModuleUserProfile:
        {
            retVal = kUserProfileModulePrefix;
        }
            break;
        case LogModuleMandatoryReport:
        {
            retVal = kMandatoryReportModulePrefix;
        }
            break;
        case LogModuleShare:
        {
            retVal = kShareModulePrefix;
        }
            break;
        case LogModuleEmblem:
        {
            retVal = kEmblemModulePrefix;
        }
            break;
        case LogModuleDataArchive:
        {
            retVal = kDataArchivePrefix;
            break;
        }
        case LogModuleAppCrash:
        {
            retVal = kAppCrashPrefix;
            break;
        }
        case LogModuleAnniversary:
        {
            retVal = kAnniversaryPrefix;
            break;
        }
        default:
        {
            retVal = @"MODULE_UNKNOW";
        }
            break;
    }
    return retVal;
}

@end
