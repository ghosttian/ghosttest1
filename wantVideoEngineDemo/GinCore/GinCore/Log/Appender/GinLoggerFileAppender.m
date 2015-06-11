//
//  GinLoggerFileAppender.m
//  microChannel
//
//  Created by joeqiwang on 14-4-14.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinLoggerFileAppender.h"
#import "NSString+CommonUse.h"
#import "GinLoggerLevelFilter.h"
#import "GinLoggerLayout.h"
#import "GinLoggerModuleFilter.h"
#import "GinLoggerDef.h"
#import "GinRootLogger.h"
#import "LogEvent.h"
#import "LogLevel.h"
#import "LogFileUploadHooker.h"

const int kDefaultFileAppenderSeverity                      = kAllValue;
const unsigned long long kFileSizeThreshold                 = (1024*1024);      // 1MB
const int kLogEventBufferThreshold                          = (10);
const int kLogEventBufferWaitingTime                        = (1);

NSString* const kLogFolderPath                          = @"com.share.log";
NSString* const kDefaultLogFileName                     = @"weishi_local_log_file.txt";
NSString* const kBackupSuffix                           = @".backup";
NSString* const kFileAppenderSyncQueue                  = @"com.weishi.fileAppender.syncQueue";
NSString* const kFileAppenderAsyncQueue                 = @"com.weishi.fileAppender.asyncQueue";

@interface GinLoggerFileAppender()
{
    unsigned long long _preFileSize;
}

@property (nonatomic, copy) NSString* fileName;
@property (nonatomic, copy) NSString* filePath;
@property (nonatomic, strong) NSFileHandle* fileHandle;
@property (nonatomic, strong) NSMutableArray* logEventBuffer;
#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic, strong) dispatch_queue_t asyncQueue;
@property (nonatomic, strong) dispatch_source_t watchDog;
#else
@property (nonatomic, assign) dispatch_queue_t syncQueue;
@property (nonatomic, assign) dispatch_queue_t asyncQueue;
@property (nonatomic, assign) dispatch_source_t watchDog;
#endif
@end

@implementation GinLoggerFileAppender

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    dispatch_release(self.watchDog);
    self.watchDog = nil;
    dispatch_release(self.syncQueue);
    self.syncQueue = nil;
    dispatch_release(self.asyncQueue);
    self.asyncQueue = nil;
#endif
    if (NO == self.isImmediatelyFlush)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

+ (GinLoggerFileAppender*)defaultFileAppender
{
    static GinLoggerFileAppender *_sharedInstance;
    if (!_sharedInstance)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _sharedInstance = [[GinLoggerFileAppender alloc] initWithFileName:kDefaultLogFileName];
            [_sharedInstance setupDefaultFileAppenderSettings];
        });
    }
    
    return _sharedInstance;
}

- (id)initWithFileName:(NSString*)fileName
{
    if (self = [super init])
    {
        self.isImmediatelyFlush = NO;
        self.fileName = fileName;
        self.logEventBuffer = [NSMutableArray array];
        self.syncQueue = dispatch_queue_create([kFileAppenderSyncQueue UTF8String] , DISPATCH_QUEUE_SERIAL);
        self.asyncQueue = dispatch_queue_create([kFileAppenderAsyncQueue UTF8String] , DISPATCH_QUEUE_CONCURRENT);
#if !OS_OBJECT_USE_OBJC
        dispatch_retain(self.syncQueue);
        dispatch_retain(self.asyncQueue);
#endif
        if (NO == self.isImmediatelyFlush)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flushLogBufferToFile) name:UIApplicationWillTerminateNotification object:nil];
        }
        [self setupFileHandle:fileName];
    }
    
    return self;
}

- (void)append:(LogEvent*)logEvent
{
    if (nil == logEvent)
    {
        return;
    }
    
    BOOL needUploadLogFile = [logEvent.level severityIsGreaterThanOrEqualTo:[LogLevel criticalLevel]];

    dispatch_async(self.syncQueue, ^{
        // 下列情况会freeze append的操作：
        // 1. 生成待上传文件时
        dispatch_semaphore_wait([GinRootLogger defaultLogger].freezeSemAphore, DISPATCH_TIME_FOREVER);
        
        // 防止在打印log中途，log文件被删除的情况
        [self checkFileExist];
        NSString *tmpStr = nil;
        if (YES == self.isImmediatelyFlush)
        {
            tmpStr = [self.layout format:logEvent];
            tmpStr = [NSString stringWithFormat:@"%@%s", tmpStr, "\n"];
            if (![NSString isEmptyString:tmpStr])
            {
                // 检查log文件大小是否已经超过限制
                [self checkFileSize];
                [self write:tmpStr];
                if (needUploadLogFile)
                {
                    // 开始log文件上传
                    [self startUploadLogFileProcessWithLogEvent:logEvent];
                }
            }
        }// buffer机制
        else
        {
            [self.logEventBuffer addObject:logEvent];

            if ([self.logEventBuffer count] > kLogEventBufferThreshold)
            {
                // 将buffer中的内容写入文件
                [self flushLogBufferToFile];
            }
            
            if (YES == needUploadLogFile)
            {
                // 把buffer里面的log刷入文件中
                [self flushLogBufferToFile];
                // 开始log文件上传
                [self startUploadLogFileProcessWithLogEvent:logEvent];
            }
            [self killWatchDog];
            self.watchDog = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.syncQueue);
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(self.watchDog);
#endif
            dispatch_source_set_timer(self.watchDog,
                                      dispatch_time(DISPATCH_TIME_NOW, kLogEventBufferWaitingTime*NSEC_PER_SEC),
                                      DISPATCH_TIME_FOREVER,
                                      0);
            dispatch_source_set_event_handler(self.watchDog, ^{
                [self flushLogBufferToFile];
                // 确保不会被重复执行
                [self killWatchDog];
            });
            dispatch_resume(self.watchDog);
        }
        dispatch_semaphore_signal([GinRootLogger defaultLogger].freezeSemAphore);
    });
}

- (void)write:(NSString*)logString
{
    // 如果string为空
    if ([NSString isEmptyString:logString])
    {
        return;
    }
    
    // using barrier_async to return immediately
    dispatch_barrier_async(self.asyncQueue, ^{
        @try
        {
            _preFileSize = [self.fileHandle seekToEndOfFile];
            [self.fileHandle writeData:[logString dataUsingEncoding:NSUnicodeStringEncoding]];
        }
        @catch (NSException *exception)
        {
        }
    });

}

- (void)closeFile
{
    @try
    {
        [self.fileHandle synchronizeFile];
        [self.fileHandle closeFile];
    }
    @finally
    {
        _preFileSize = 0;
        self.fileHandle = nil;
    }
}

#pragma mark - private methods

- (void)startUploadLogFileProcessWithLogEvent:(LogEvent *)logEvent
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        LogFileUploadHooker *uploadHooker = [[LogFileUploadHooker alloc]initWithOriginalFileName:self.fileName];
        uploadHooker.logEvent = logEvent;
        [uploadHooker doLogFileUpload];
    });
}

- (void)setupDefaultFileAppenderSettings
{
    [self appendFilter:[[GinLoggerLevelFilter alloc] initWithLevelValue:kDefaultFileAppenderSeverity]];
    [self appendFilter:[[GinLoggerModuleFilter alloc] init]];
}

- (void)setupFileHandle:(NSString*)aFileName
{
    if ([NSString isEmptyString:aFileName])
    {
        self.fileHandle = nil;
    }
    else
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *folderPath = [cachesDirectory stringByAppendingPathComponent:kLogFolderPath];

        // 如果文件夹不存在，创建文件夹
        if (![fileManager fileExistsAtPath:folderPath])
        {
            NSError *error = nil;
            [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
        }
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", folderPath, aFileName];
        // 设置log文件的路径
        self.filePath = filePath;
        
        // if file doesn't exist, try to create the file
        if (![fileManager fileExistsAtPath:filePath])
        {
            // if the we cannot create the file, raise a FileNotFoundException
            if (![fileManager createFileAtPath:filePath contents:nil attributes:nil])
            {
                [NSException raise:@"FileNotFoundException" format:@"Couldn't create a file at %@", filePath];
            }
        }
        
        // open a file handle to the file
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    // set the new file handle, so the file size is 0
    _preFileSize = 0;
}

- (void)checkFileSize
{
    BOOL isExceed = _preFileSize > kFileSizeThreshold ? YES : NO;
    
    if (isExceed)
    {
        [self backupLogFile];
    }
}

- (void)checkFileExist
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.filePath])
    {
        [self setupFileHandle:self.fileName];
    }
}

- (void)backupLogFile
{
    if (![NSString isEmptyString:self.fileName])
    {
        [self closeFile];
        
        NSError *error = nil;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString* backupFileName = [NSString stringWithFormat:@"%@%@", self.filePath, kBackupSuffix];
        
        // 如果backup文件已经存在就删除旧的backup文件
        if ([fileMgr fileExistsAtPath:backupFileName])
        {
            [fileMgr removeItemAtPath:backupFileName error:&error];
        }
        error = nil;
        // 将文件重命名为backup文件
        [[NSFileManager defaultManager] moveItemAtPath:self.filePath toPath:backupFileName error:&error];
        
        // 重命名backup文件成功
        if (nil == error)
        {
            [self setupFileHandle:self.fileName];
        }
    }
}

- (NSString*)convertLogEventBufferToString
{
    if (0 == [self.logEventBuffer count])
    {
        return nil;
    }
    
    NSString *retVal = @"";
    NSString *tmpStr;
    NSArray *tmpArray = [self.logEventBuffer copy];
    [self.logEventBuffer removeAllObjects];
    
    for(int i=0; i<tmpArray.count; i++)
    {
        tmpStr = [self.layout format:tmpArray[i]];
        tmpStr = [NSString stringWithFormat:@"%@%s", tmpStr, "\n"];
        retVal = [retVal stringByAppendingString:tmpStr];
    }
    
    return retVal;
}

- (void)flushLogBufferToFile
{
    dispatch_async(self.syncQueue, ^{
        if ([self.logEventBuffer count])
        {
            NSString *tmpStr = [self convertLogEventBufferToString];
            if (![NSString isEmptyString:tmpStr])
            {
                // 检查log文件大小是否已经超过限制
                [self checkFileSize];
                [self write:tmpStr];
            }
        }
    });
}

- (void)killWatchDog
{
    if (self.watchDog)
    {
        dispatch_source_cancel(self.watchDog);
#if !OS_OBJECT_USE_OBJC
        dispatch_release(self.watchDog);
#endif
        self.watchDog = nil;
    }
}

@end
