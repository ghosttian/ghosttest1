//
//  GinUploadStrategyDynamicChangePackageSize.m
//  microChannel
//
//  Created by joeqiwang on 14-1-13.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinUploadStrategyByHTTP.h"
//#import "GinUploadUtil.h"
#import "Reachability.h"
#import "GinUploadRequiredInfo.h"
#import "GinLog.h"
#import "NSMutableDictionary+NilObject.h"
#import "GinAccountInfo.h"
#import "NSDictionary+Additions.h"
#import "GinUserDefaultKey.h"
#import "VideoExtensionHttpClient.h"
#import "GinHttpCommonDefine.h"


//#import "CommonDefine.h"
//#import "MicroVideoAPIManager.h"
//#import "MVVideoFileManager.h"

#import "NSString+CharCounter.h"
#import "GinUploadCoachBase.h"
#import "GinUploadCoachChangeSizeBySpeed.h"
#import "GinUploadCoachSharkFin.h"
#import "GinNetworkUtils.h"
#import "NSString+CommonUse.h"

//extern int const kUnloginErroCode;
extern int const kHttpRequestCancelledError;
//extern NSString *const kApplyUploadErrorModule;
//extern NSString *const kUploadVideoErrorMudule;

#pragma mark -MACROS
// 错误代码的异常处理参见： http://km.oa.com/group/weishi/articles/show/175925
// Server responds errors
NSString *const LOGIN_INVALID                                      = @"login_invalid";                                // errorCode:-1
NSString *const NO_PRIVILEGE                                       = @"no_privilege";                                 // errorCode:-5
NSString *const UPLOAD_PARAMETERS_INVALID                          = @"upload_parameters_invalid";                    // errorCode:-6
NSString *const VIDEO_SIZE_EXCEED                                  = @"video_size_exceed";                            // errorCode:-101
NSString *const UPLOAD_PROTOCOL_INVALID                            = @"upload_protocol_invalid";                      // errorCode:-102
NSString *const VIDEO_SIZE_INVALID                                 = @"video_size_invalid";                           // errorCode:-136
NSString *const VIDEO_MD5_INVALID                                  = @"video_md5_invalid";                            // errorCode:-137
NSString *const VIDEO_SHA_INVALID                                  = @"video_sha_invalid";                            // errorCode:-138
// General errors
NSString *const VIDEO_PARAMETERS_INVALID                           = @"video_parameters_invalid";                     // errorCode:-164
NSString *const HTTP_REQUEST_TIMEOUT                               = @"http_request_timeout";                         // errorCode:-1001
NSString *const RESPONSE_PARAMETERS_INVALID_ERROR                  = @"response_parameters_invalid_error";            // errorCode:-166
NSString *const UPLOAD_VIDEO_SERVER_RESPONSE_ERROR                 = @"upload_video_server_response_error";           // errorCode:-167
NSString *const UPLOAD_SUSPEND_FAKE_ERROR                          = @"upload_suspend_fake_error";                    // errorCode:-168

// Server responds errors' code
int const NO_PRIVILEGE_ERROR_CODE                                  = -5;
int const UPLOAD_PARAMETERS_INVALID_ERROR_CODE                     = -6;
int const VIDEO_SIZE_EXCEED_ERROR_CODE                             = -101;
int const UPLOAD_PROTOCOL_INVALID_ERROR_CODE                       = -102;
int const VIDEO_SIZE_INVALID_ERROR_CODE                            = -136;
int const VIDEO_MD5_INVALID_ERROR_CODE                             = -137;
int const VIDEO_SHA_INVALID_ERROR_CODE                             = -138;
// General errors' code
int const VIDEO_PARAMETERS_INVALID_ERROR_CODE                      = -164;
int const RESPONSE_PARAMETERS_INVALID_ERROR_CODE                   = -166;
int const UPLOAD_VIDEO_SERVER_RESPONSE_ERROR_CODE                  = -167;
int const UPLOAD_SUSPEND_FAKE_ERROR_CODE                           = -168;
int const HTTP_REQUEST_TIMEOUT_ERROR_CODE                          = -1001;
int const NETWORK_SHIFT_TO_WWLAN_ERROR_CODE                        = -1005;
int const NETWORK_SHIFT_TO_NO_NETWORK_ERROR_CODE                   = -1009;

// 网络切换的等待时间
int const kNetworkShiftVacuumPeriod                                 = 15;
int const kMaxTitleLength                                           = 21;

#pragma mark -CONSTANTS

typedef enum
{
    kUploadCoachSamePackageSize = 0,
    kUploadCoachChangePackageSizeBySpeedRange = 1,
    kUploadCoachSharkFin = 2
}GinUploadCoachType;    // 上传分片大小计算的模式

#pragma mark -private class extension

@interface GinUploadStrategyByHTTP()
{
    unsigned long long _fileSize;                       // 单位为bytes
    unsigned long long _packageSize;                    // 单位为bytes
    CGFloat _duration;
    VideoRateType _rateType;
    int _applyUploadRetryCount;
    int _uploadVideoRetryCount;
    int _totalRetryCount;
    int _uploadAlgorithm;
    NSTimeInterval _uploadTimeForPreviousRequest;
    NSTimeInterval _uploadVideoTotalConsumedTime;
}

@property (nonatomic, assign) unsigned long long uploadedOffset;        // 单位为bytes
@property (nonatomic, assign) int resetUpload;
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, copy) NSString *fid;          // 短视频上传使用fid
@property (nonatomic, copy) NSString *vid;          // 长视频上传使用vid
@property (nonatomic, copy) NSString *title;        // 长视频上传成功后在腾讯视频显示的title
@property (nonatomic, copy) NSString *longVideoURL;     // 长视频上传成功后，腾讯视频的URL
@property (nonatomic, strong) NSTimer* watchDog;        // 网络切换真空时间，不重试的watchDog
@property (nonatomic, copy) NSError *error;
@property (nonatomic, copy) NSString *checkKey; // 用于长视频申请上传成功后返回的checkkey
@property (nonatomic, copy) NSString *msgID;    // 用于长视频申请上传时传输的tweetID
@property (nonatomic, assign) BOOL isAnniversary;
@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, assign) MVCompositiongDataVideoType shortVideoOrLongVideo;

@end


@implementation GinUploadStrategyByHTTP

#pragma mark -public methods

- (void)dealloc
{
}

- (id)init
{
    if (self = [super init])
    {
#ifdef kUnofficalStatCollect
        [self createUploadCoachFactoryMethodByQQ];
#else
        NSNumber *uploadSubType = [[NSUserDefaults standardUserDefaults] objectForKey:WeishiUploadSubType];
        [self createUploadCoachFactoryMethodByType:uploadSubType.intValue];
#endif
    }
    
    return self;
}

- (void)uploadVideoWithRequiredInfo:(GinUploadRequiredInfo*)info
{
    // super会设置一些property的初始值
    [super uploadVideoWithRequiredInfo:info];
    
    GINFO(LogModuleVideoUpload, @"start to upload video task, required info is: %@", [info description]);

    self.shouldDisplayProgress = YES;
    
    self.isAnniversary = info.isAnniversary;
    self.shortVideoOrLongVideo = info.shortVideoOrLongVideo;
    self.videoSize = info.videoSize;
    self.videoPath = info.VideoPath;
    _duration = info.VideoDuration;

    // check the video's duration and file
    if ([self checkVideoFileMessedUp])
    {
        return;
    }
    
    // 初始化instance variables
    if (info.VideoRate >= kVideoRateHigh && info.VideoRate <= kVideoRateLower)
    {
        _rateType = info.VideoRate;
    }
    else
    {
        _rateType = kVideoRateHigh;
    }
    
    // 初始化private properties
    NSFileManager *fileMgr = nil;
    fileMgr = [NSFileManager defaultManager];
    NSDictionary *attr =[fileMgr attributesOfItemAtPath:self.videoPath error:nil];
    // 获取文件大小
    _fileSize = [[attr objectForKey:NSFileSize] unsignedLongLongValue];
    attr = nil;
    
    GINFO(LogModuleVideoUpload, @"video file size is: %llu", _fileSize);
    
    if (ShootVideoTypeLongVideo == self.VideoType)
    {
        self.msgID = info.MsgID;
    }
    else
    {
        self.msgID = nil;
    }
    
    if (ShootVideoTypeLongVideo == self.VideoType)
    {
        self.title = info.Title;
        if ([NSString calculateCharCounterFor:self.title] > kMaxTitleLength)
        {
            int cutIndex = (int)[NSString calculateSubStringLength:self.title length:kMaxTitleLength-1];
            self.title = [NSString stringWithFormat:@"%@...", [self.title substringToIndex:cutIndex]];
        }
    }
    else
    {
        self.title = nil;
    }
    
    // 设置uploadCoach中记录的文件总大小
    self.uploadCoach.totalSize = _fileSize;
    
    // 开始进行applyUpload
    [self startUploadApply];
}

- (void)continueUploadVideoWithModel:(GinUploadRequiredInfo *)model
{
    // super会设置一些property的初始值
    [super continueUploadVideoWithModel:model];
    GINFO(LogModuleVideoUpload, @"continue upload video task, model is: %@; the video type is: %d", model, self.VideoType);
    self.shouldDisplayProgress = YES;
    
    self.shortVideoOrLongVideo = model.shortVideoOrLongVideo;
    self.isAnniversary = model.isAnniversary;
    self.videoPath = model.VideoPath;
    _rateType = model.VideoRate;
    _duration = model.VideoDuration;
    
    // 初始化private properties
    if (ShootVideoTypeLongVideo == self.VideoType)
    {
        self.msgID = model.MsgID;
    }
    
    NSError *error = nil;
    NSFileManager *fileMgr = nil;
    fileMgr = [NSFileManager defaultManager];
    NSDictionary *attr =[fileMgr attributesOfItemAtPath:self.videoPath error:&error];
    // 设置文件大小
    _fileSize = [[attr objectForKey:NSFileSize] unsignedLongLongValue];

    GINFO(LogModuleVideoUpload, @"absolute path of video is: %@, the video size is: %llu, the file attributes are: %@, the error is: %@", self.videoPath, _fileSize, attr, error);
    attr = nil;

    if (ShootVideoTypeLongVideo == self.VideoType)
    {
        self.title = model.Title;
        
        if ([NSString calculateCharCounterFor:self.title] > kMaxTitleLength)
        {
            int cutIndex = (int)[NSString calculateSubStringLength:self.title length:kMaxTitleLength-1];
            self.title = [NSString stringWithFormat:@"%@...", [self.title substringToIndex:cutIndex]];
        }
    }
    else
    {
        self.title = nil;
    }
    
    self.uploadedOffset = model.uploadedOffset;
    
    // 设置uploadCoach中记录的文件总大小
    self.uploadCoach.totalSize = _fileSize;
    // 设置视频的request id
    self.requestID = model.requestID;
    
    if (kGinVideoUploadVideo == self.uploadStage)
    {
        self.fid = model.fid;
        self.vid = model.vid;
        self.checkKey = model.checkKey;
        
        [self startUploadVideo];
    }
    else
    {
        // check the video's duration and file
        if ([self checkVideoFileMessedUp])
        {
            return;
        }
        [self startUploadApply];
    }
}

// postpone to derived class to implement
- (void)suspendUploadVideo
{
}

#pragma mark -private methods
- (BOOL)checkVideoFileMessedUp
{
    NSFileHandle *videoFile = nil;
    videoFile = [NSFileHandle fileHandleForReadingAtPath:self.videoPath];
    // 参数合法性检验
    if (!videoFile || _duration < 1)
    {
        GFATAL(LogModuleVideoUpload, @"video data is invalid, video file is at: %@; video duration is: %f; video type is: %d, video file is:%p", self.videoPath, _duration, self.VideoType, videoFile);
        
        [self displayWarningWithText:@"视频数据异常，请重启微视再试"];
        
        self.error = [[NSError alloc] initWithDomain:VIDEO_PARAMETERS_INVALID code:VIDEO_PARAMETERS_INVALID_ERROR_CODE userInfo:nil];
        
        [self uploadFailedAtPreApplyStage];
        
        [videoFile closeFile];
        videoFile = nil;
        
        return YES;
    }
    
    [videoFile closeFile];
    videoFile = nil;
    
    return NO;
}

// 创建uploadCoach来决定，上传策略中的分片大小如何计算
- (void)createUploadCoachFactoryMethodByType:(int)coachType
{
    switch (coachType)
    {
        case kUploadCoachSamePackageSize:
        {
            self.uploadCoach = [[GinUploadCoachBase alloc] init];
            GINFO(LogModuleVideoUpload, @"using SAME package size strategy to upload video.");
        }
            break;
        case kUploadCoachChangePackageSizeBySpeedRange:
        {
            self.uploadCoach = [[GinUploadCoachChangeSizeBySpeed alloc] init];
            GINFO(LogModuleVideoUpload, @"using DYNAMIC package size strategy to upload video.");
        }
            break;
        case kUploadCoachSharkFin:
        {
            self.uploadCoach = [[GinUploadCoachSharkFin alloc] init];
            GINFO(LogModuleVideoUpload, @"using SHARK FIN strategy to upload video.");
        }
            break;
        default:
        {
            self.uploadCoach = [[GinUploadCoachChangeSizeBySpeed alloc] init];
            GINFO(LogModuleVideoUpload, @"using DYNAMIC package size strategy to upload video.");
        }
            break;
    }
}

- (void)createUploadCoachFactoryMethodByQQ
{
    NSString *QQNumStr = [GinAccountInfo sharedAccountInfo].qqId;
    long long QQNum = [QQNumStr longLongValue];
    
    if ([NSString isEmptyString:QQNumStr])
    {
        self.uploadCoach = [[GinUploadCoachChangeSizeBySpeed alloc] init];
        _uploadAlgorithm = kUploadCoachChangePackageSizeBySpeedRange;
        GINFO(LogModuleVideoUpload, @"using DYNAMIC package size strategy to upload video.");
        return;
    }
    
    if (0 == QQNum%2)
    {
        self.uploadCoach = [[GinUploadCoachChangeSizeBySpeed alloc] init];
        _uploadAlgorithm = kUploadCoachChangePackageSizeBySpeedRange;
        GINFO(LogModuleVideoUpload, @"using DYNAMIC package size strategy to upload video.");
    }
    else
    {
        self.uploadCoach = [[GinUploadCoachSharkFin alloc] init];
        _uploadAlgorithm = kUploadCoachSharkFin;
        GINFO(LogModuleVideoUpload, @"using SHARK FIN strategy to upload video.");
    }
}

// 设置了uploadedOffset后，通知client
- (void)setUploadedOffset:(unsigned long long)Offset
{
    if (_uploadedOffset != Offset)
    {
        _uploadedOffset = Offset;
        [self notifyClientOffsetChanged];
    }
}

// 当flag为YES，让进度条采用根据预计时间的方式显示
- (void)setIsGorgeousDisplayProgress:(BOOL)flag
{  
    if (flag)
    {
        GINFO(LogModuleVideoUpload, @"set GorgeousDisplayProgress flag as: YES.");
        _isGorgeousDisplayProgress = flag;
        NSTimeInterval time = 0;
        // 在apply期间调用setIsGorgeousDisplayProgress，waitingTime为0，在每个分片开始时候调用时waitingTime也为0
        if (self.requestStartDate)
        {
            time = [[NSDate date] timeIntervalSinceDate:self.requestStartDate];
        }
        [self setUploadProgressWithStartOffset:0 NextOffset:self.uploadedOffset+_packageSize waitingTime:time];
    }
}

//---------------------------------------------------------
//-------------------申请上传逻辑----------------------------
//---------------------------------------------------------
- (void)startUploadApply
{
    GINFO(LogModuleVideoUpload, @"start to do upload apply.");
    _applyUploadRetryCount = 0;
    [self doUploadApply];
}

- (void)doUploadApply
{
    // 重置uploadedOffset
    self.uploadedOffset = 0;
    
    self.uploadStage = kGinVideoUploadApply;

    [self setUploadProgressWithNextPackageOffset:0];
    
    NSString *sha = [GinNetworkUtils getFileSHA:self.videoPath];
    NSString *md5 = [GinNetworkUtils getFileMD5:self.videoPath];
  
    // 视频设置md5为requestID来提供cancel功能
    self.requestID = md5;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // Setup参数
    [params setObjectOrNil:[NSNumber numberWithUnsignedLongLong:_fileSize] forKey:@"size"];
    [params setObjectOrNil:sha forKey:@"sha"];
    [params setObjectOrNil:md5 forKey:@"md5"];
    [params setObjectOrNil:[NSNumber numberWithFloat:_duration] forKey:@"duration"];
    [params setObjectOrNil:@"iphone" forKey:@"platform"];
    [params setObjectOrNil:[NSNumber numberWithInt:_rateType] forKey:@"vtype"];
    if (MVCompositiongDataVideoLongType == self.shortVideoOrLongVideo) {
        //长视频
        [params setObjectOrNil:[NSNumber numberWithInt:4] forKey:@"vtype"];
    }
    // 设置reqeust id作为cancel视频上传的唯一id
    [params setObjectOrNil:self.requestID forKey:@"requestid"];
    
    if (self.videoSize.width)
    {
        [params setObjectOrNil:[NSNumber numberWithFloat:self.videoSize.width] forKey:@"vwidth"];
    }
    if (self.videoSize.height)
    {
        [params setObjectOrNil:[NSNumber numberWithFloat:self.videoSize.height] forKey:@"vheight"];
    }
    
    if (ShootVideoTypeLongVideo == self.VideoType)
    {
        [params setObjectOrNil:self.msgID forKey:@"msgid"];
        if (![NSString isEmptyString:self.title])
        {
            [params setObjectOrNil:self.title forKey:@"title"];
        }
        else
        {
            [params setObjectOrNil:@"微视" forKey:@"title"];
        }
    }

    if (self.isAnniversary)
    {
        [params setObjectOrNil:@(1) forKey:@"anniversary"];
    }

    GINFO(LogModuleVideoUpload, @"the HTTP upload apply request is for video type: %d; parameters is: %@", self.VideoType, params);
    [self generalUploadApplyWithParameters:params];
}

// 封装短视频和长视频不同的逻辑在同一个申请上传
- (void)generalUploadApplyWithParameters:(NSDictionary*)params
{
    
}

- (void)applyUploadRequestSucceeded:(MicroVideoQueryResult*)result
{
    GINFO(LogModuleVideoUpload, @"server reponses with apply successful, data is: %@", result);
    NSDictionary *dataDict = result.data;

    // 如果成功就把延时操作取消掉
    [self killWatchDog];
    
    // server返回数据不合法
    if (nil == dataDict)
    {
        self.error = [NSError errorWithDomain:RESPONSE_PARAMETERS_INVALID_ERROR code:RESPONSE_PARAMETERS_INVALID_ERROR_CODE userInfo:dataDict];
        [self retryUploadApply];
        return;
    }
    
    int retCode = (int)result.ret;
    
    // 返回0，表示applyUpload请求成功
    if (0 == retCode)
    {
        if (ShootVideoTypeShortVideo == self.VideoType)
        {
            self.vid = nil;
            if ([dataDict ginStringValueForKey:@"fid"])
            {
                self.fid = [dataDict ginStringValueForKey:@"fid"];
            }
            else
            {
                self.error = [NSError errorWithDomain:RESPONSE_PARAMETERS_INVALID_ERROR code:RESPONSE_PARAMETERS_INVALID_ERROR_CODE userInfo:dataDict];
                [self retryUploadApply];
                return;
            }
        }
        else if (ShootVideoTypeLongVideo == self.VideoType)
        {
            self.fid = nil;
            if ([dataDict ginStringValueForKey:@"vid"])
            {
                self.vid = [dataDict ginStringValueForKey:@"vid"];
            }
            else
            {
                self.error = [NSError errorWithDomain:RESPONSE_PARAMETERS_INVALID_ERROR code:RESPONSE_PARAMETERS_INVALID_ERROR_CODE userInfo:dataDict];
                [self retryUploadApply];
                return;
            }
        }

        if (ShootVideoTypeLongVideo == self.VideoType)
        {
            if ([dataDict ginStringValueForKey:@"checkkey"])
            {
                self.checkKey = [dataDict ginStringValueForKey:@"checkkey"];
            }
            else
            {
                self.error = [NSError errorWithDomain:RESPONSE_PARAMETERS_INVALID_ERROR code:RESPONSE_PARAMETERS_INVALID_ERROR_CODE userInfo:dataDict];
                [self retryUploadApply];
                return;
            }
        }
        else
        {
            self.checkKey = nil;
        }

        // 申请上传成功，重置_resetUpload
        _resetUpload = 0;
        [self UploadApplySuccessful];
        // 申请上传成功，开始上传视频
        [self startUploadVideo];
    }
    else
    {
        [self composeErrorWithServerResponse:result];
        
        [self retryUploadApply];
    }
}

- (void)applyUploadRequestFailed:(NSError*)error
{
    GINFO(LogModuleVideoUpload, @"server responses with apply failed, error is: %@", error);
    int errCode = (int)error.code;
    
    // 如果是请求被cancel了
    if (kHttpRequestCancelledError == errCode)
    {
        self.uploadStage |= kGinVideoUploadSuspend;
        [self processCancelUploadVideo];
        return;
    }
    
    // 如果在网络切换时候产生无网真空期，我们需要延时retry
    if (NETWORK_SHIFT_TO_NO_NETWORK_ERROR_CODE == errCode || NETWORK_SHIFT_TO_WWLAN_ERROR_CODE == errCode ||
        HTTP_REQUEST_TIMEOUT_ERROR_CODE == errCode)
    {
        int retryWaitingTime = kNetworkShiftVacuumPeriod*pow(_applyUploadRetryCount+1, 2);
        
        NSNumber *retryNum =  (1==_resetUpload) ? [[NSUserDefaults standardUserDefaults] objectForKey:WeishiResetRetry] :
            [[NSUserDefaults standardUserDefaults] objectForKey:WeishiUploadRetry];
        int applyRetryNum = retryNum.intValue;
        
        if (_applyUploadRetryCount == applyRetryNum)
        {
            retryWaitingTime = 0;
        }
        self.error = error;
        [self killWatchDog];
        GINFO(LogModuleVideoUpload, @"network shifts period, delay upload apply retry after: %d seconds", retryWaitingTime);
        self.watchDog = [NSTimer scheduledTimerWithTimeInterval:retryWaitingTime target:self selector:@selector(retryUploadApply) userInfo:nil repeats:NO];
        return;
    }
    
    // 用户的登录态失效
    if (kUnloginErroCode == errCode)
    {
        self.error = [NSError errorWithDomain:LOGIN_INVALID code:kUnloginErroCode userInfo:[error userInfo]];
        [self uploadFailedAtApplyStage];
    }// 用户没有上传的权限
    else if (-5 == errCode)
    {
        self.error = [NSError errorWithDomain:NO_PRIVILEGE code:NO_PRIVILEGE_ERROR_CODE userInfo:[error userInfo]];
        [self uploadFailedAtApplyStage];
        
    }// video size超出限制
    else if (-101 == errCode)
    {
        self.error = [NSError errorWithDomain:VIDEO_SIZE_EXCEED code:VIDEO_SIZE_EXCEED_ERROR_CODE userInfo:[error userInfo]];
        [self uploadFailedAtApplyStage];
    }// video size参数不合法
    else if (-136 == errCode)
    {
        self.error = [NSError errorWithDomain:VIDEO_SIZE_INVALID code:VIDEO_SIZE_INVALID_ERROR_CODE userInfo:[error userInfo]];
        [self uploadFailedAtApplyStage];
    }// md5参数不合法
    else if (-137 == errCode)
    {
        self.error = [NSError errorWithDomain:VIDEO_MD5_INVALID code:VIDEO_MD5_INVALID_ERROR_CODE userInfo:[error userInfo]];
        [self uploadFailedAtApplyStage];
    }// sha参数不合法
    else if (-138 == errCode)
    {
        self.error = [NSError errorWithDomain:VIDEO_SHA_INVALID code:VIDEO_SHA_INVALID_ERROR_CODE userInfo:[error userInfo]];
        [self uploadFailedAtApplyStage];
    }
    // 其他类型的失败包括超时都一概处理retry
    else
    {
        self.error = error;
        [self retryUploadApply];
    }
}

- (void)retryUploadApply
{
    GWARN(LogModuleVideoUpload, @"RETRY UPLOAD APPLY with error: %@", self.error);
    
    NSString *specificID = nil;
    if (ShootVideoTypeShortVideo == self.VideoType)
    {
        specificID = self.fid;
    }
    else if (ShootVideoTypeLongVideo == self.VideoType)
    {
        specificID = self.vid;
    }
    // 上报过程中发生的错误
    [self reportUploadVideoErrorWithUID:specificID andError:self.error andVideoType:self.VideoType];
    
    NSNumber *resetApplyRetryNum = [[NSUserDefaults standardUserDefaults] objectForKey:WeishiResetRetry];
    NSNumber *applyRetryNum = [[NSUserDefaults standardUserDefaults] objectForKey:WeishiApplyRetry];
    
    int retryNum = (1==_resetUpload) ? resetApplyRetryNum.intValue: applyRetryNum.intValue;
    GINFO(LogModuleVideoUpload, @"retry upload apply, currently is: %d time; the max rety number is: %d", _applyUploadRetryCount, retryNum);
    if (_applyUploadRetryCount < retryNum)
    {
        _applyUploadRetryCount += 1;
        [self doUploadApply];
        
    }// retryCount达到最大值，直接上报错误结束上传服务
    else
    {
        // applyUpload失败
        [self uploadFailedAtApplyStage];
    }
}

//---------------------------------------------------------
//-------------------视频上传逻辑----------------------------
//---------------------------------------------------------
- (void)startUploadVideo
{
    GINFO(LogModuleVideoUpload, @"start to do video upload.");
    _uploadVideoRetryCount = 0;
    self.uploadStage = kGinVideoUploadVideo;
    [self doUploadVideo];
}

- (void)doUploadVideo
{
    // 上传之前先确定分包大小
    [self determinePackageSizeByCoach];
    
    // 设置进度条
    [self setUploadProgressWithNextPackageOffset:self.uploadedOffset+_packageSize];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    NSData* uploadData = nil;
    NSFileHandle *videoFile = nil;
    videoFile = [NSFileHandle fileHandleForReadingAtPath:self.videoPath];
    
    @try
    {
        if (videoFile)
        {
            [videoFile seekToFileOffset:self.uploadedOffset];
            uploadData = [videoFile readDataOfLength:_packageSize];
        }
        else
        {
            GCRITICAL(LogModuleVideoUpload, @"during uploading, the video file DISAPPEAR!");
        }
    }
    @catch(NSException *exception)
    {
        GCRITICAL(LogModuleVideoUpload, @"read video file data throw exception.");
    }
    @finally
    {
        [videoFile closeFile];
        videoFile = nil;
    }
    
    NSString* md5 = [GinNetworkUtils getFileMD5ByNSData:uploadData];
    
    // Setup参数
    if (ShootVideoTypeShortVideo == self.VideoType)
    {
        [params setObjectOrNil:self.fid forKey:@"fid"];
    }
    else if (ShootVideoTypeLongVideo == self.VideoType)
    {
        [params setObjectOrNil:self.vid forKey:@"vid"];
        [params setObjectOrNil:self.checkKey forKey:@"checkkey"];
    }
    
    if (self.isAnniversary)
    {
        [params setObjectOrNil:@(1) forKey:@"anniversary"];
    }
    
    [params setObjectOrNil:[NSNumber numberWithUnsignedLongLong:_packageSize] forKey:@"len"];
    [params setObjectOrNil:[NSNumber numberWithUnsignedLongLong:self.uploadedOffset] forKey:@"offset"];
    [params setObjectOrNil:md5 forKey:@"md5"];
    // 把原始文件的md5作为request id，只是为了可以cancel视频上传的操作
    [params setObjectOrNil:self.requestID forKey:@"requestid"];

    GINFO(LogModuleVideoUpload, @"video upload HTTP request for video type: %d; parameters are: %@, upload data is: %p", self.VideoType, params, uploadData);
    [self generalUploadVideoWithVideoData:uploadData andParameters:params];
}

// 封装短视频和长视频不同的逻辑在同一个视频上传
- (void)generalUploadVideoWithVideoData:(NSData*)uploadData andParameters:(NSDictionary*)params
{
    
}

- (void)videoUploadRequestSucceeded:(MicroVideoQueryResult*)result
{
    GINFO(LogModuleVideoUpload, @"video upload response with successful, video type is: %d; the data is: %@", self.VideoType, result);
    NSTimeInterval tmpTimeInterval = [[NSDate date] timeIntervalSinceDate:self.requestStartDate];
    int retCode = (int)result.ret;
    NSDictionary *dataDict = result.data;
    
    // 如果成功就把延时操作取消掉
    [self killWatchDog];

    
    if (nil == dataDict)
    {
        self.error = [NSError errorWithDomain:RESPONSE_PARAMETERS_INVALID_ERROR code:RESPONSE_PARAMETERS_INVALID_ERROR_CODE userInfo:dataDict];
        [self retryUploadVideo];
        return;
    }
    
    // 该片上传未成功，服务器返回失败
    if (retCode != 0)
    {
        [self composeErrorWithServerResponse:result];
        
        // 现在查看有没有reset域，如果有从applyUpload重新开始，若无则retry
        _resetUpload = 0;
        if ([dataDict objectForKey:@"reset"])
        {
            _resetUpload = (int)[dataDict ginIntegerValueForKey:@"reset"];
        }
        
        if (1 == _resetUpload)
        {
            [self doUploadApply];
            return;
        }
        
        [self retryUploadVideo];
        return;
    }

    // 下面的情况都是在retCode=0的前提下
    int finished = 0;
    unsigned long long tmpOffset = 0;
    // 1表示发送完成，0表示发送未完成
    if ([dataDict objectForKey:@"finish"])
    {
        finished = (int)[dataDict ginIntegerValueForKey:@"finish"];
    }
    else
    {
        // response的域不完整，应该error
        self.error = [NSError errorWithDomain:RESPONSE_PARAMETERS_INVALID_ERROR code:RESPONSE_PARAMETERS_INVALID_ERROR_CODE userInfo:dataDict];
        [self retryUploadVideo];
        return;
    }
    
    if ([dataDict objectForKey:@"offset"])
    {
        tmpOffset = [dataDict unsignedLongLongValueForKey:@"offset"];
        if (tmpOffset > _fileSize)
        {
            self.error = [NSError errorWithDomain:RESPONSE_PARAMETERS_INVALID_ERROR code:RESPONSE_PARAMETERS_INVALID_ERROR_CODE
                                         userInfo:dataDict];
            [self retryUploadVideo];
            return;
        }
    }
    else
    {
        // response的域不完整，应该error
        self.error = [NSError errorWithDomain:RESPONSE_PARAMETERS_INVALID_ERROR code:RESPONSE_PARAMETERS_INVALID_ERROR_CODE
                                     userInfo:dataDict];
        [self retryUploadVideo];
        return;
    }
    
    // 上传video整个结束
    if (1 == finished && tmpOffset == _fileSize)
    {
        _uploadTimeForPreviousRequest = tmpTimeInterval;
        _uploadVideoTotalConsumedTime += _uploadTimeForPreviousRequest;
        
        if (ShootVideoTypeShortVideo == self.VideoType)
        {
            if ([dataDict objectForKey:@"fid"])
            {
                if (![self.fid isEqualToString:[dataDict ginStringValueForKey:@"fid"]])
                {
                    GFATAL(LogModuleVideoUpload, @"the fid is invalid, previsou fid:%@, latest fid:%@", self.fid, [dataDict objectForKey:@"fid"]);
                }
                
                self.vid = nil;
            }
        }
        else if (ShootVideoTypeLongVideo == self.VideoType)
        {
            if ([dataDict objectForKey:@"vid"])
            {
                self.vid = [dataDict ginStringValueForKey:@"vid"];
                self.fid = nil;
            }
            if ([dataDict objectForKey:@"realurl"])
            {
                self.longVideoURL = [dataDict ginStringValueForKey:@"realurl"];
            }
            else
            {
                self.error = [NSError errorWithDomain:RESPONSE_PARAMETERS_INVALID_ERROR code:RESPONSE_PARAMETERS_INVALID_ERROR_CODE
                                             userInfo:dataDict];
                [self retryUploadVideo];
                return;
            }
        }
        
        self.uploadStage = kGinVideoUploadFinished;
        self.uploadedOffset = tmpOffset;
        // 设置上传进度
        [self setUploadProgressWithNextPackageOffset:_fileSize];
        [self UploadVideoSuccessful];
        return;
    }
    
    // 上传未完成，继续上传
    if (0 == finished)
    {
        self.uploadedOffset = tmpOffset;

        // 上一片上传成功，重置_uploadVideoRetryCount
        _uploadVideoRetryCount = 0;

        _uploadTimeForPreviousRequest = tmpTimeInterval;
        _uploadVideoTotalConsumedTime += _uploadTimeForPreviousRequest;

        [self doUploadVideo];
    }
}

- (void)videoUploadRequestFailed:(NSError*)error
{
    GINFO(LogModuleVideoUpload, @"video upload responses failed, video type is: %d; the error is: %@", self.VideoType, error);
    
    self.error = error;
    NSDictionary *retDict = [error userInfo];
    NSDictionary *dataDict = [retDict objectForKey:@"data"];
    _uploadTimeForPreviousRequest = 0;
    int errCode = (int)error.code;
    
    // 如果是请求被cancel了
    if (kHttpRequestCancelledError == errCode)
    {
        self.uploadStage |= kGinVideoUploadSuspend;
        [self processCancelUploadVideo];
        return;
    }
    
    // 如果在网络切换时候产生无网真空期，我们需要延时retry
    if (NETWORK_SHIFT_TO_NO_NETWORK_ERROR_CODE == errCode || NETWORK_SHIFT_TO_WWLAN_ERROR_CODE == errCode ||
        HTTP_REQUEST_TIMEOUT_ERROR_CODE == errCode)
    {
        int retryWaitingTime = kNetworkShiftVacuumPeriod*pow(_uploadVideoRetryCount+1, 2);

        NSNumber *uploadRetryNum = [[NSUserDefaults standardUserDefaults] objectForKey:WeishiUploadRetry];
        if (_uploadVideoRetryCount == uploadRetryNum.intValue)
        {
            retryWaitingTime = 0;
        }
        
        self.error = error;
        [self killWatchDog];
        GINFO(LogModuleVideoUpload, @"network shifts period, delay upload video retry after: %d seconds", retryWaitingTime);
        self.watchDog = [NSTimer scheduledTimerWithTimeInterval:retryWaitingTime target:self selector:@selector(retryUploadVideo) userInfo:nil repeats:NO];
        return;
    }

    // 现在查看有没有reset域，如果有从applyUpload重新开始，若无则retry
    _resetUpload = 0;
    if ([dataDict objectForKey:@"reset"])
    {
        _resetUpload = (int)[dataDict ginIntegerValueForKey:@"reset"];
    }
    
    if (1 == _resetUpload)
    {
        GINFO(LogModuleVideoUpload, @"server makes client to RESET upload video from upload apply.");
        [self retryUploadApply];
        return;
    }
    //reset域处理END
    
    // 用户的登录态失效
    if (kUnloginErroCode == errCode)
    {
        self.error = [NSError errorWithDomain:LOGIN_INVALID code:kUnloginErroCode userInfo:[error userInfo]];
        [self uploadFailedAtUploadVideoStage];
    }// 用户没有上传的权限
    else if (-5 == errCode)
    {
        self.error = [NSError errorWithDomain:NO_PRIVILEGE code:NO_PRIVILEGE_ERROR_CODE userInfo:retDict];
        [self uploadFailedAtUploadVideoStage];
        
    }// 上传参数不合法
    else if (-6 == errCode)
    {
        self.error = [NSError errorWithDomain:UPLOAD_PARAMETERS_INVALID code:UPLOAD_PARAMETERS_INVALID_ERROR_CODE userInfo:retDict];
        [self uploadFailedAtUploadVideoStage];
    }// 上传协议错误
    else if (-102 == errCode)
    {
        self.error = [NSError errorWithDomain:UPLOAD_PROTOCOL_INVALID code:UPLOAD_PROTOCOL_INVALID_ERROR_CODE userInfo:retDict];
        [self uploadFailedAtUploadVideoStage];
    }// 以下情况都是需要按照服务器端给出的offset重传
    else if (-103 == errCode || -105 == errCode || -106 == errCode || -107 == errCode || -111 == errCode
             || -112 == errCode || -113 == errCode || -117 == errCode || -118 == errCode || -121 == errCode
             || -125 == errCode || -126 == errCode || -146 == errCode)
    {
        if ([dataDict objectForKey:@"offset"])
        {
            self.uploadedOffset = [dataDict unsignedLongLongValueForKey:@"offset"];
        }
        else
        {
            self.error = [NSError errorWithDomain:RESPONSE_PARAMETERS_INVALID_ERROR code:RESPONSE_PARAMETERS_INVALID_ERROR_CODE userInfo:retDict];
        }
        [self retryUploadVideo];
    }// 其他情况直接retry
    else
    {
        if ([dataDict objectForKey:@"offset"])
        {
            self.uploadedOffset = [dataDict unsignedLongLongValueForKey:@"offset"];
        }
        else
        {
            self.error = [NSError errorWithDomain:RESPONSE_PARAMETERS_INVALID_ERROR code:RESPONSE_PARAMETERS_INVALID_ERROR_CODE userInfo:retDict];
        }
        
        [self retryUploadVideo];
    }
}

- (void)retryUploadVideo
{
    
    GWARN(LogModuleVideoUpload, @"RETRY UPLOAD VIDEO, error is: %@", self.error);
    NSString *specificID = nil;
    if (ShootVideoTypeShortVideo == self.VideoType)
    {
        specificID = self.fid;
    }
    else if (ShootVideoTypeLongVideo == self.VideoType)
    {
        specificID = self.vid;
    }
    // 上报错误
    [self reportUploadVideoErrorWithUID:specificID andError:self.error andVideoType:self.VideoType];
    
    NSNumber *uploadRetryNum = [[NSUserDefaults standardUserDefaults] objectForKey:WeishiUploadRetry];

    GINFO(LogModuleVideoUpload, @"retry upload video, currently is: %d time; the max rety number is: %d", _uploadVideoRetryCount, uploadRetryNum.intValue);
    if (_uploadVideoRetryCount < uploadRetryNum.intValue)
    {
        _totalRetryCount += 1;
        _uploadVideoRetryCount += 1;
        [self doUploadVideo];
    }// retryCount达到最大值，直接上报错误结束上传服务
    else
    {
        // uploadVideo失败
        [self uploadFailedAtUploadVideoStage];
    }
}

//---------------------------------------------------------
//-------------------上传结束处理逻辑-------------------------
//---------------------------------------------------------
- (void)uploadFailedAtPreApplyStage
{
    GinUploadResult* uploadResult = [[GinUploadResult alloc] init];
    uploadResult.voideRateType = _rateType;
    
    uploadResult.vUpStep = UP_STEP_APPLY;
    uploadResult.vid = self.vid;
    uploadResult.fid = self.fid;
    uploadResult.requestID = self.requestID;
    uploadResult.checkkey = self.checkKey;
    uploadResult.offset = 0;
    uploadResult.error = self.error;

    if (ShootVideoTypeLongVideo == self.VideoType)
    {
        uploadResult.msgID = self.msgID;
    }
    
    if (self.uploadStage & kGinVideoUploadSuspend)
    {
        uploadResult.error = [[NSError alloc] initWithDomain:UPLOAD_SUSPEND_FAKE_ERROR code:UPLOAD_SUSPEND_FAKE_ERROR_CODE userInfo:nil];
    }
    else
    {
        [self reportUploadVideoLogFailedWithUploadAlgorithm:_uploadAlgorithm andError:self.error andVideoType:self.VideoType];
    }

    [self killWatchDog];
    
    GERROR(LogModuleVideoUpload, @"upload video screwed up at PRE APPLY stage, the result is: %@", [uploadResult simpleDescription]);
    // for jail break error log collect
    [self checkErrorsForLogUpload];
    if (self.completeBlock != nil)
    {
        self.completeBlock(uploadResult);
    }
}

- (void)uploadFailedAtApplyStage
{
    GinUploadResult* uploadResult = [[GinUploadResult alloc] init];
    uploadResult.voideRateType = _rateType;
    
    uploadResult.vUpStep = UP_STEP_APPLY;
    uploadResult.vid = self.vid;
    uploadResult.fid = self.fid;
    uploadResult.requestID = self.requestID;
    uploadResult.checkkey = self.checkKey;
    uploadResult.offset = 0;
    uploadResult.error = self.error;
    
    if (ShootVideoTypeLongVideo == self.VideoType)
    {
        uploadResult.msgID = self.msgID;
    }
    
    if (self.uploadStage & kGinVideoUploadSuspend)
    {
        uploadResult.error = [[NSError alloc] initWithDomain:UPLOAD_SUSPEND_FAKE_ERROR code:UPLOAD_SUSPEND_FAKE_ERROR_CODE userInfo:nil];
    }
    else
    {
        [self reportUploadVideoLogFailedWithUploadAlgorithm:_uploadAlgorithm andError:self.error andVideoType:self.VideoType];
    }

    [self killWatchDog];

    [self logInModule:kApplyUploadErrorModule description:self.error.description errorLevel:kLogErrorError errorCode:self.error.code command:nil];

    GERROR(LogModuleVideoUpload, @"upload video screwed up at APPLY stage, the result is: %@", [uploadResult simpleDescription]);
    // for jail break error log collect
    [self checkErrorsForLogUpload];
    if (self.completeBlock != nil)
    {
        self.completeBlock(uploadResult);
    }
}

- (void)UploadApplySuccessful
{
    GinUploadResult* uploadResult = [[GinUploadResult alloc] init];
    uploadResult.voideRateType = _rateType;
    
    uploadResult.vUpStep = UP_STEP_APPLY;
    uploadResult.vid = self.vid;
    uploadResult.fid = self.fid;
    uploadResult.requestID = self.requestID;
    uploadResult.checkkey = self.checkKey;
    uploadResult.offset = 0;
    uploadResult.error = nil;
    if (ShootVideoTypeLongVideo == self.VideoType)
    {
        uploadResult.longVideoURL = self.longVideoURL;
        uploadResult.msgID = self.msgID;
    }
    
    if (self.uploadStage & kGinVideoUploadSuspend)
    {
        uploadResult.error = [[NSError alloc] initWithDomain:UPLOAD_SUSPEND_FAKE_ERROR code:UPLOAD_SUSPEND_FAKE_ERROR_CODE userInfo:nil];
    }
    else
    {
        [self reportUploadVideoLogWithElapseTime:_uploadVideoTotalConsumedTime andPackageSize:0 andUploadAlgorithm:_uploadAlgorithm];
    }
    
    [self killWatchDog];
    GINFO(LogModuleVideoUpload, @"upload apply SUCCESSFUL, result is: %@", [uploadResult simpleDescription]);
    if (self.completeBlock != nil)
    {
        self.completeBlock(uploadResult);
    }
}

- (void)uploadFailedAtUploadVideoStage
{
    GinUploadResult* uploadResult = [[GinUploadResult alloc] init];
    
    uploadResult.voideRateType = _rateType;
    uploadResult.vUpStep = UP_STEP_UPLOAD;
    uploadResult.vid = self.vid;
    uploadResult.fid = self.fid;
    uploadResult.requestID = self.requestID;
    uploadResult.checkkey = self.checkKey;
    uploadResult.offset = self.uploadedOffset;
    uploadResult.error = self.error;
    
    if (ShootVideoTypeLongVideo == self.VideoType)
    {
        uploadResult.msgID = self.msgID;
    }
    
    if (self.uploadStage & kGinVideoUploadSuspend)
    {
        uploadResult.error = [[NSError alloc] initWithDomain:UPLOAD_SUSPEND_FAKE_ERROR code:UPLOAD_SUSPEND_FAKE_ERROR_CODE userInfo:nil];
    }
    else
    {
        [self reportUploadVideoLogFailedWithUploadAlgorithm:_uploadAlgorithm andError:self.error andVideoType:self.VideoType];
    }
    
    [self killWatchDog];

    [self logInModule:kUploadVideoErrorMudule description:self.error.description errorLevel:kLogErrorError errorCode:self.error.code command:nil];

    GERROR(LogModuleVideoUpload, @"upload video screwed up at UPLOAD VIDEO stage, the result is: %@", [uploadResult simpleDescription]);
    // for jail break error log collect
    [self checkErrorsForLogUpload];
    if (self.completeBlock != nil)
    {
        self.completeBlock(uploadResult);
    }
    
}

- (void)UploadVideoSuccessful
{
    GinUploadResult* uploadResult = [[GinUploadResult alloc] init];
    uploadResult.voideRateType = _rateType;
    
    uploadResult.vUpStep = UP_STEP_PUBLISH;
    uploadResult.vid = self.vid;
    uploadResult.fid = self.fid;
    uploadResult.requestID = self.requestID;
    uploadResult.checkkey = self.checkKey;
    if (ShootVideoTypeLongVideo == self.VideoType)
    {
        uploadResult.longVideoURL = self.longVideoURL;
    }
    if (ShootVideoTypeLongVideo == self.VideoType)
    {
        uploadResult.msgID = self.msgID;
    }
    uploadResult.offset = _fileSize;
    uploadResult.error = nil;

    if (self.uploadStage & kGinVideoUploadSuspend)
    {
        uploadResult.error = [[NSError alloc] initWithDomain:UPLOAD_SUSPEND_FAKE_ERROR code:UPLOAD_SUSPEND_FAKE_ERROR_CODE userInfo:nil];
    }
    else
    {
        [self reportUploadVideoLogWithElapseTime:_uploadVideoTotalConsumedTime andPackageSize:_fileSize andUploadAlgorithm:_uploadAlgorithm];
    }

    [self killWatchDog];
    GINFO(LogModuleVideoUpload, @"upload video SUCCESSFUL, result is: %@", [uploadResult simpleDescription]);
    if (self.completeBlock != nil)
    {
        self.completeBlock(uploadResult);
    }else{
        GINFO(LogModuleVideoUpload, @"upload video completeBlock is: nil");
    }
}

//---------------------------------------------------------
//-------------------Functional Methods--------------------
//---------------------------------------------------------
#pragma mark - Functional Methods

- (void)setUploadProgressWithStartOffset:(unsigned long long)startOffset NextOffset:(unsigned long long)nextOffset waitingTime:(NSTimeInterval)time
{
    CGFloat startPoint = 0;
    CGFloat nextPoint = 0;
    CGFloat estimatedTime = 0;
    
    if (0 == startOffset)
    {
        startPoint = 0;
    }
    else
    {
        startPoint = (CGFloat)self.uploadedOffset/(CGFloat)_fileSize;
        startPoint = WEISHI_APPLAY_UPLOAD_PROGRESS + startPoint*WEISHI_UPLOAD_VOIDEO_PROGRESS;
    }
    
    // 如果还在申请上传阶段
    if (0 == self.uploadedOffset+_packageSize)
    {
        nextPoint = WEISHI_APPLAY_UPLOAD_PROGRESS;
    }
    else
    {
        nextPoint = (CGFloat)nextOffset/(CGFloat)_fileSize;
        nextPoint = WEISHI_APPLAY_UPLOAD_PROGRESS + nextPoint*WEISHI_UPLOAD_VOIDEO_PROGRESS;
    }

    if (0 == _uploadVideoTotalConsumedTime)
    {
        estimatedTime = 0;
    }
    else
    {
        CGFloat v = (CGFloat)self.uploadedOffset/(CGFloat)_uploadVideoTotalConsumedTime;
        estimatedTime = (CGFloat)(_fileSize-self.uploadedOffset-v*time)/v;
        // 在文件上传的最后一片时，因为接入层的粘包需要时间，通常最后一片分片的时间会很长，这种情况会导致estimatedTime为负值
        if (estimatedTime < 0)
        {
            estimatedTime = (CGFloat)(_fileSize-self.uploadedOffset)/v;
        }
        GINFO(LogModuleVideoUpload, @"uploadedOffset is:%f, _uploadVideoTotalConsumedTime is:%f, time is:%f, estimatedTime is:%f", self.uploadedOffset/1024, _uploadVideoTotalConsumedTime, time, estimatedTime);
    }
    
    if ([self.delegate respondsToSelector:@selector(setUploadProgressWithStartPoint:nextPoint:estimatedTime:endPoint:)])
    {
        GINFO(LogModuleVideoUpload, @"update progress bar, the startPoint is:%f, nextPoint is:%f, the estimatedTime is:%f", startPoint, nextPoint, estimatedTime);
        [self.delegate setUploadProgressWithStartPoint:startPoint nextPoint:nextPoint estimatedTime:estimatedTime endPoint:0.98];
    }
}

- (void)setUploadProgressWithNextPackageOffset:(unsigned long long)nextOffset
{
    if (YES == self.shouldDisplayProgress)
    {
        if (self.isGorgeousDisplayProgress)
        {
            [self setUploadProgressWithStartOffset:self.uploadedOffset NextOffset:nextOffset waitingTime:0];
        }
        else
        {
            CGFloat startProgress = (CGFloat)self.uploadedOffset/(CGFloat)_fileSize;
            startProgress = WEISHI_APPLAY_UPLOAD_PROGRESS + startProgress*WEISHI_UPLOAD_VOIDEO_PROGRESS;
            CGFloat nextProgress = (CGFloat)nextOffset/(CGFloat)_fileSize;
            nextProgress = WEISHI_APPLAY_UPLOAD_PROGRESS + nextProgress*WEISHI_UPLOAD_VOIDEO_PROGRESS;
            // 在apply阶段
            if (0 == nextOffset)
            {
                startProgress = 0;
                nextProgress = WEISHI_APPLAY_UPLOAD_PROGRESS;
            }
            GINFO(LogModuleVideoUpload, @"set upload progress startPoint is: %f, nextPoint is: %f", startProgress, nextProgress);
            // 通知GinWriteFailView需要更新上传进度
            if ([self.delegate respondsToSelector:@selector(setUploadProgressStart:nextProgress:total:)])
            {
                [self.delegate setUploadProgressStart:startProgress nextProgress:nextProgress total:1];
            }
        }
    }
}

- (void)composeErrorWithServerResponse:(MicroVideoQueryResult*)serverResult
{
    NSString *errMsg = serverResult.msg;
    int finalCode = 0;
    int errCode = (int)serverResult.errCode;
    int retCode = (int)serverResult.ret;
    
    if (nil == errMsg || 0 == [errMsg length])
    {
        errMsg = UPLOAD_VIDEO_SERVER_RESPONSE_ERROR;
        
        finalCode = retCode;
    }
    else
    {
        finalCode = errCode;
    }
    
    self.error = [[NSError alloc] initWithDomain:errMsg code:finalCode userInfo:serverResult.data];
}

- (void)determinePackageSizeByCoach
{
    self.uploadCoach.uploadedOffset = self.uploadedOffset;
//    _packageSize = [self.uploadCoach getPackageSizeByPreviousSize:_packageSize andElapseTime:_uploadTimeForPreviousRequest];
    _packageSize = 512 * 1024;
    _packageSize = (self.uploadedOffset+_packageSize > _fileSize) ? _fileSize-self.uploadedOffset : _packageSize;
    GINFO(LogModuleVideoUpload, @"DETERMINE PACKAGE SIZE; file size is: %llu, the uploaded offset is: %llu, package size is:\n %llu", _fileSize, self.uploadedOffset, _packageSize);
}

// 视频上传暂停后，cancel
- (void)processCancelUploadVideo
{
    // 如果在申请上传阶段
    if (self.uploadStage & kGinVideoUploadApply)
    {
        [self uploadFailedAtApplyStage];
    }// 如果在视频上传阶段
    else if (self.uploadStage & kGinVideoUploadVideo)
    {
        [self uploadFailedAtUploadVideoStage];
    }// 如果在视频上传成功但未进入到publish阶段
    else if (self.uploadStage & kGinVideoUploadFinished)
    {
        [self UploadVideoSuccessful];
    }
}

- (void)displayWarningWithText:(NSString*)wanring
{
}

- (void)notifyClientOffsetChanged
{
    // 通知client offset变化了
    if ((ShootVideoTypeLongVideo == self.VideoType) && ([self.delegate respondsToSelector:@selector(setUploadOffset:)]))
    {
        [self.delegate setUploadOffset:(int)self.uploadedOffset];
    }
}

- (void)killWatchDog
{
    if (self.watchDog)
    {
        [self.watchDog invalidate];
        self.watchDog = nil;
    }
}

// this function is just used for upload error log collect
- (void)checkErrorsForLogUpload
{
#ifndef kBuildAppForAppStore
    if (self.error)
    {
        int errCode = (int)self.error.code;
        if (-166 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"server response parameters invalid, error code is %d", errCode);
        }
        else if (-105 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"tencent video interface error, error code is %d", errCode);
        }
        else if (-2 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"request parameters error, error code is %d", errCode);
        }
        else if (-117 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"tencent platform interface error, error code is %d", errCode);
        }
        else if (-1001 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"HTTP request timeout, error code is %d", errCode);
        }
        else if (-1009 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"network shift error, error code is %d", errCode);
        }
        else if (-1005 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"network shift to WWLAN, error code is %d", errCode);
        }
        else if (-144 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-107 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-144 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-1004 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-101 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-164 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }else if (-14 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-15 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-1 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-5 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (3840 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-1003 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-6 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-1011 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-126 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (306 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-11 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-1019 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-125 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-136 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-4 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
        else if (-102 == errCode)
        {
            GCRITICAL(LogModuleVideoUpload, @"error code is %d", errCode);
        }
    }
#endif
}

- (void)reportUploadVideoErrorWithUID:(NSString*)uid andError:(NSError*)error andVideoType:(int)videoType;
{
    
}

- (void)reportUploadVideoLogFailedWithUploadAlgorithm:(int)uploadAlg andError:(NSError*)error andVideoType:(int)videoType
{
    
}

- (void)reportUploadVideoLogWithElapseTime:(long)elapse andPackageSize:(unsigned long long)size andUploadAlgorithm:(int)uploadAlg
{
    
}

- (void)logInModule:(NSString*)module description:(NSString*)des errorLevel:(NSInteger)level errorCode:(NSInteger)errCode command:(NSString*)cmd
{
}
@end