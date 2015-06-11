//
//  GinLoggerDef.h
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

typedef enum
{
    kOffValue = 0,
    kFatalValue = 1,
    kCriticalValue = 3,
    kErrorValue = 4,
    kWarnValue = 9,
    kInfoValue = 16,
    kDebugValue = 25,
    kAllValue = 2014
}LogLevelType;

typedef NS_ENUM(NSInteger, LogErrorType)
{
    kLogErrorAll         = 0,
    kLogErrorDebug       = 1,
    kLogErrorInfo        = 2,
    kLogErrorWarn        = 3,
    kLogErrorError       = 4,
    kLogErrorFatal       = 5,
    kLogErrorOff         = 6,
};

typedef NS_ENUM(NSInteger, LogModuleType)
{
    LogModuleVideoEdit                  = 1,
    LogModuleVideoUpload                = 2,
    LogModuleVideoDownload              = 3,
    LogModuleWriteOperation             = 4,
    LogModulePrivateMessage             = 5,
    LogModuleUIWaterFlow                = 6,
    LogModuleUIDetailPage               = 7,
    LogModuleLogin                      = 8,
    LogModuleCommonDebug                = 9,      // if you want to print your log for debug objective use this value
    LogModuleGeneralCatchedException    = 10,
    LogModuleMessage                    = 11,
    LogModuleCommon                     = 12,
    LogModuleChannel                    = 13,
    LogModuleTag                        = 14,
    LogModuleDelegateJump               = 15,
    LogModuleUserProfile                = 16,
    LogModuleMandatoryReport            = 17,
    LogModuleShare                      = 18,
    LogModuleEmblem                     = 19,
    LogModuleDataArchive                = 20,
    LogModuleAppCrash                   = 21,
    LogModuleAnniversary                = 22
};
