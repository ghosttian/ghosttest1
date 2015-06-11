//
//  GinLog.h
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GinLoggerDef.h"


#pragma mark MACROS

// NOTE: some MACROS just used for test, if huidu or upload to appstore pls commented it
//#define TEST_ENVIRONMENT

extern void glog(const char* fileName, const char* funcName, int line, int logLevel, LogModuleType moduleType, NSString *fmt, ...);

#ifdef YES

#define GFATAL(ModuleType, ...)     glog(__FILE__, __FUNCTION__, __LINE__, kFatalValue, ModuleType, __VA_ARGS__);
#define GCRITICAL(ModuleType, ...)  glog(__FILE__, __FUNCTION__, __LINE__, kCriticalValue, ModuleType, __VA_ARGS__);
#define GERROR(ModuleType, ...)     glog(__FILE__, __FUNCTION__, __LINE__, kErrorValue, ModuleType, __VA_ARGS__);
#define GWARN(ModuleType, ...)      glog(__FILE__, __FUNCTION__, __LINE__, kWarnValue, ModuleType, __VA_ARGS__);
#define GINFO(ModuleType, ...)      glog(__FILE__, __FUNCTION__, __LINE__, kInfoValue, ModuleType, __VA_ARGS__);
#define GDEBUG(ModuleType, ...)     glog(__FILE__, __FUNCTION__, __LINE__, kDebugValue, ModuleType, __VA_ARGS__);

#else

#define GFATAL(ModuleType, ...)     do{} while(0);
#define GCRITICAL(ModuleType, ...)  do{} while(0);
#define GERROR(ModuleType, ...)     do{} while(0);
#define GWARN(ModuleType, ...)      do{} while(0);
#define GINFO(ModuleType, ...)      do{} while(0);
#define GDEBUG(ModuleType, ...)     do{} while(0);

#endif