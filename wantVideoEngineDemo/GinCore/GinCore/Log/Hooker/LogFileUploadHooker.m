//
//  LogFileUploadHooker.m
//  microChannel
//
//  Created by joeqiwang on 14-5-7.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "LogFileUploadHooker.h"
#import "LogEvent.h"
#import "GinRootLogger.h"
#import "Reachability.h"
#import "MicroVideoNetworkImp.h"
#import "MicroVideoQueryResult.h"
#import "NSString+CommonUse.h"
#import "NSString+MD5.h"
#import "NSMutableDictionary+NilObject.h"
#import "NSDictionary+Additions.h"
#import "GinLogDataAccessGuard.h"
#import "GinLogUtils.h"
#import "GinJSONUtils.h"
#import "GinNetworkUtils.h"


extern int const HTTP_REQUEST_TIMEOUT_ERROR_CODE;
extern int const NETWORK_SHIFT_TO_WWLAN_ERROR_CODE;
extern int const NETWORK_SHIFT_TO_NO_NETWORK_ERROR_CODE;

extern NSString *const kLogFolderPath;
extern NSString *const kDefaultLogFileName;
extern NSString *const kBackupSuffix;
extern NSString *const kMandatoryReportModulePrefix;

#pragma mark - Constant

const int kMaxRetryNum                              = (1);
const int kMaxUploadLogNum                          = (10);
const int kUploadLogFileSize                        = (512);
NSString *const kEncryptSuffix                      = @"2014mv_log0513";

#pragma mark - private implementation

@interface LogFileUploadHooker()

@property (nonatomic, assign) BOOL isUploadAllowed;
@property (nonatomic, assign) int applyRetryNum;
@property (nonatomic, assign) int uploadRetryNum;
@property (nonatomic, copy) NSString *origfileName;
@property (nonatomic, copy) NSString *uploadFilePath;
@property (nonatomic, copy) NSString *uploadFileName;
@property (nonatomic, copy) NSString *queryString;
@property (nonatomic, copy) NSString *tokenString;

@end

@implementation LogFileUploadHooker

#pragma mark - public methods

- (id)initWithOriginalFileName:(NSString *)oriFileName
{
    if (self = [super init])
    {
        self.origfileName = oriFileName;
#ifndef kBuildAppForAppStore
        self.isUploadAllowed = YES;
#else
        self.isUploadAllowed = [GlobalConfiguration sharedConfiguration].isMandatoryUploadGLog;
#endif
    }
    
    return self;
}

- (void)doLogFileUpload
{
    // 如果不允许日志上传
    if (!self.isUploadAllowed)
    {
        return;
    }
    
    NSString* versionStr = [GinLogUtils weishiVersion];
    // 生成query string
    NSString *queryStr = [NSString stringWithFormat:@"%@_%@_%@_%@", self.logEvent.moduleName, versionStr, self.logEvent.fileName, [self.logEvent.lineNumber stringValue]];
    // 设置query string
    self.queryString = queryStr;
    
    if ([self checkQueryStringExclusive])
    {
        // 申请log file上传
        [self applyUploadLogFile];
    }
}

#pragma mark - private methods

- (BOOL)checkQueryStringExclusive
{
    if ([NSString isEmptyString:self.queryString])
    {
        return NO;
    }
    
    // 如果是根据白名单强制用户上传的log文件，不需要进行error是否上报过的判断
    if ([self.queryString hasPrefix:kMandatoryReportModulePrefix])
    {
        return YES;
    }
    
    NSArray *errorsArr = [[GinLogDataAccessGuard sharedInstance] getAllItems];
    
    if (errorsArr)
    {
        for (NSString *item in errorsArr)
        {
            // 这个queryString的error已经发生过了，不是exclusive的
            if ([self.queryString isEqualToString:item])
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)markQueryString
{
    // 如果是根据白名单强制用户上传的log文件，不需要进行error是否上报过的判断
    if ([self.queryString hasPrefix:kMandatoryReportModulePrefix])
    {
        return;
    }
    
    [[GinLogDataAccessGuard sharedInstance] insertItem:self.queryString];
}

#pragma mark - apply upload log file operation
- (void)applyUploadLogFile
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *contStr = [[NSDictionary dictionaryWithObject:self.queryString forKey:@"querystring"] gin_JSONString];
    NSString *crcStr = [self getCrcString:contStr];
    [params setObjectOrNil:contStr forKey:@"content"];
    [params setObjectOrNil:crcStr forKey:@"crc"];
    
    // 进行log文件申请上传的网络请求
    [MicroVideoNetworkImp applyLogFileUpload:params success:^(MicroVideoQueryResult* result)
     {
         [self applyUploadLogFileSucceeded:result];
     }
                                        fail:^(NSError *error)
     {
         [self applyUploadLogFileFailed:error];
     }];
}

- (void)applyUploadLogFileSucceeded:(MicroVideoQueryResult *)result
{
    self.tokenString = [[result data] ginStringValueForKey:@"token"];
    
    int uploadCode = [[result data] ginIntValueForKey:@"enabled"];
    // 成功，代表需要上传
    if (1 == uploadCode)
    {
        [self setupUploadLogFile];
    }
    // 0代表不需要上传，上传操作结束
}

- (void)applyUploadLogFileFailed:(NSError *)error
{
    NSInteger errCode = error.code;

    // 如果因为当前没有网络连接就不重试了
    if (HTTP_REQUEST_TIMEOUT_ERROR_CODE == errCode ||
        NETWORK_SHIFT_TO_WWLAN_ERROR_CODE == errCode ||
        NETWORK_SHIFT_TO_NO_NETWORK_ERROR_CODE == errCode)
    {
        return;
    }
    else
    {
        if (self.applyRetryNum < kMaxRetryNum)
        {
            self.applyRetryNum++;
            // 重试
            [self applyUploadLogFile];
        }
    }
}

// 生成待上传的日志文件
- (void)setupUploadLogFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *folderPath = [cachesDirectory stringByAppendingPathComponent:kLogFolderPath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", folderPath, self.origfileName];
    NSString *backupFilePath = [NSString stringWithFormat:@"%@%@", filePath, kBackupSuffix];

    // 如果文件不存在，返回失败
    if (![fileManager fileExistsAtPath:filePath])
    {
        return;
    }
    
    NSString *weishiID = [GinLogUtils getUserID];
    if ([NSString isEmptyString:weishiID])
    {
        weishiID = @"anonymousUser";
    }
    
    // to create several NSDateFormatter instances is too expensive for performance cost.
    static NSDateFormatter *formatter = nil;
    
    if (nil == formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    
    NSString* timeStampStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *uploadFileName = [NSString stringWithFormat:@"%@_%@_%@_%@_upload.txt", self.queryString, [self getConnectionType], weishiID, timeStampStr];
    // 设置上传文件名
    self.uploadFileName = uploadFileName;
    NSString *uploadFilePath = [NSString stringWithFormat:@"%@/%@", folderPath, uploadFileName];
    // 设置上传文件路径
    self.uploadFilePath = uploadFilePath;
    
    [fileManager createFileAtPath:uploadFilePath contents:nil attributes:nil];
    
    // setup upload File，因为涉及到很多文件的读写操作所以放到单独的线程做
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{@autoreleasepool{
        // 文件操作前wait，避免文件操作的时候继续执行append使读写文件操作数据不一致
        dispatch_semaphore_wait([GinRootLogger defaultLogger].freezeSemAphore, DISPATCH_TIME_FOREVER);
        NSFileHandle *origFileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        NSFileHandle *backupHandle = [NSFileHandle fileHandleForReadingAtPath:backupFilePath];
        NSFileHandle *newFileHandle = [NSFileHandle fileHandleForWritingAtPath:uploadFilePath];
        
        unsigned long long origFileSize = [origFileHandle seekToEndOfFile];
        unsigned long long maxUploadFileSize = 1024 * kUploadLogFileSize;
        
        NSData *dataBuffer = nil;
        // To be honest, for my coding career, I have written plenty of messy code, but the below fragment is the only one smelled like shit...
        // 原文件大小大于可以上传的最大size,截出maxUploadFileSize的内容上传
        if (origFileSize > maxUploadFileSize)
        {
            unsigned long long startPoint = origFileSize - maxUploadFileSize;
            [origFileHandle seekToFileOffset:startPoint];
            dataBuffer = [origFileHandle readDataOfLength:maxUploadFileSize];
            [newFileHandle seekToFileOffset:0];
            [newFileHandle writeData:dataBuffer];
            
            dataBuffer = nil;
        }// 原文件小于kMaxUploadFileSize
        else
        {
            // 如果存在backup文件，把backup文件的后面部分拼接到原文件开始处，然后上传;否则直接上传待上传文件
            if ([fileManager fileExistsAtPath:backupFilePath])
            {
                newFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:uploadFilePath];
                unsigned long long gapSize = maxUploadFileSize - origFileSize;
                unsigned long long backupFileSize = [backupHandle seekToEndOfFile];
                
                if (gapSize >= backupFileSize)
                {
                    [backupHandle seekToFileOffset:0];
                    dataBuffer = [backupHandle readDataToEndOfFile];
                    [newFileHandle seekToFileOffset:0];
                    // 先把backupFile的数据写入uploaded文件
                    [newFileHandle writeData:dataBuffer];
                    [origFileHandle seekToFileOffset:0];
                    dataBuffer = [origFileHandle readDataToEndOfFile];
                    [newFileHandle seekToEndOfFile];
                    // 再把log文件中的内容写入
                    [newFileHandle writeData:dataBuffer];
                    dataBuffer = nil;
                }
                else
                {
                    unsigned long long startPoint = backupFileSize - gapSize;
                    [backupHandle seekToFileOffset:startPoint];
                    dataBuffer = [backupHandle readDataOfLength:gapSize];
                    [newFileHandle seekToFileOffset:0];
                    // 先把backupFile中gap部分的数据写入uploaded文件
                    [newFileHandle writeData:dataBuffer];
                    [origFileHandle seekToFileOffset:0];
                    dataBuffer = [origFileHandle readDataToEndOfFile];
                    [newFileHandle seekToEndOfFile];
                    // 再把log文件中的内容写入
                    [newFileHandle writeData:dataBuffer];
                    dataBuffer = nil;
                }
            }// 不存在backup文件，就直接上传原文件
            else
            {
                [fileManager removeItemAtPath:uploadFilePath error:nil];
                [fileManager copyItemAtPath:filePath toPath:uploadFilePath error:nil];
            }
        }
        // 文件操作完成可以让GinLoggerFileAppender继续append log了
        dispatch_semaphore_signal([GinRootLogger defaultLogger].freezeSemAphore);
        // close files
        @try
        {
            [origFileHandle synchronizeFile];
            [origFileHandle closeFile];
        }
        @finally
        {
            origFileHandle = nil;
        }
        @try
        {
            [backupHandle synchronizeFile];
            [backupHandle closeFile];
        }
        @finally
        {
            backupHandle = nil;
        }
        @try
        {
            [newFileHandle synchronizeFile];
            [newFileHandle closeFile];
        }
        @finally
        {
            newFileHandle = nil;
        }
        // 开始上传log文件
        [self uploadLogFile];
    }});
}

#pragma mark - log file upload operation
- (void)uploadLogFile
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObjectOrNil:self.tokenString forKey:@"token"];
    [params setObjectOrNil:self.queryString forKey:@"querystring"];
    [params setObjectOrNil:self.uploadFileName forKey:@"filename"];
    
    NSFileHandle *newFileHandle = [NSFileHandle fileHandleForReadingAtPath:self.uploadFilePath];
    NSData *logData = [newFileHandle readDataToEndOfFile];
    // 进行log file上传的网络请求
    [MicroVideoNetworkImp uploadLogFile:logData uploadParams:params success:^(MicroVideoQueryResult* result)
    {
        [self uploadLogFileSucceeded:result];
    }
                                   fail:^(NSError *error)
    {
        [self uploadLogFileFailed:error];
    }];
}

- (void)uploadLogFileSucceeded:(MicroVideoQueryResult *)result
{
    NSInteger retCode = result.ret;
    
    // 上传成功了
    if (0 == retCode)
    {
        // 删除待上传的文件
        [[NSFileManager defaultManager] removeItemAtPath:self.uploadFilePath error:nil];
        // 将该queryString标记到已经上报过的error
        [self markQueryString];
    }
}

- (void)uploadLogFileFailed:(NSError *)error
{
    NSInteger errCode = error.code;
    
    // 如果因为当前没有网络连接就不重试了
    if (HTTP_REQUEST_TIMEOUT_ERROR_CODE == errCode ||
        NETWORK_SHIFT_TO_WWLAN_ERROR_CODE == errCode ||
        NETWORK_SHIFT_TO_NO_NETWORK_ERROR_CODE == errCode)
    {
        return;
    }
    else
    {
        if (self.uploadRetryNum < kMaxRetryNum)
        {
            self.uploadRetryNum++;
            // 重试
            [self uploadLogFile];
        }
    }
}

#pragma mark - help function

- (NSString *)getCrcString:(NSString *)contStr
{
    NSString *retVal = nil;
    NSString *tmpStr = [contStr stringByAppendingString:kEncryptSuffix];
    retVal = [tmpStr MD5Hash];
    retVal = [retVal substringWithRange:NSMakeRange(9, 8)];
    return retVal;
}

- (NSString *)getConnectionType
{
    BOOL isWifi = NO;
    NSString *retVal = @"unknow";
    if ([GinNetworkUtils isNetWorkAvaible])
    {
        isWifi = ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
        if (!isWifi)
        {
            retVal = @"2G/3G";
        }
        else
        {
            retVal = @"WIFI";
        }
    }
    return retVal;
}

@end
