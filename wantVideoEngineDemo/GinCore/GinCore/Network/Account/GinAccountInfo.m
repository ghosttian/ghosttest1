//
//  GinAccountInfo.m
//  microChannel
//
//  Created by minghuiji on 13-7-22.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinAccountInfo.h"
#import "NSDictionary+Additions.h"
#import "GinHttpCommonDefine.h"
#import "GinCoreDefines.h"

#define IOSVERSIONISABOVE8     (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)

NSString *const kCacheKeyUserInfo                   =   @"CacheUserInfo";
NSString *const kAccountSinaWeiboLoginDic           =   @"sinaWeiboLoginDic";
NSString *const kLatestLoginUserAccount             =   @"latestLoginUserAccount";//最近登录的用户账号信息
NSString *const kWeiShiLoginAccount                 =   @"kWeiShiLoginAccount";//最近普通登录的用户账号
NSString *const kAccountIsRegisterWeibo             =   @"isRegisterWeibo";
NSString *const kAccountQQId                        =   @"userId";
NSString *const kAccountLSKey                       =   @"lsKey";
NSString *const kAccountSKey                        =   @"sKey";
NSString *const kAccountPSKey                       =   @"psKey";
NSString *const kAccountSTWeb                       =   @"stWeb";
NSString *const kAccountOpenId                      =   @"openId";
NSString *const kAccountToken                       =   @"token";
NSString *const kAccountTokenExpire                 =   @"tokenExpire";
NSString *const kAccountLoginType                   =   @"loginType";
NSString *const kAccountBindSinaWeiboId             =   @"bindSinaWeiboId";
NSString *const kAccountBindSinaWeiboNickName       =   @"bindSinaWeiboNickname";

@interface GinAccountInfo ()

@property(nonatomic,strong) NSUserDefaults *groupDefaults;

@end

@implementation GinAccountInfo

+ (GinAccountInfo *)sharedAccountInfo
{
    static GinAccountInfo *_singleInstance;
    if (!_singleInstance)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _singleInstance = [[GinAccountInfo alloc] initConfig];
        });
    }
    return _singleInstance;
}

- (instancetype)initConfig
{
    if (self = [super init])
    {
        //extension需要读取登录数据，另存到group中。
        if (IOSVERSIONISABOVE8) {
            self.groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:APPGROUPID];
            if (!isExtension) {
                [self copyLoginInfoFromAppToExtension];
            }
        }
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if (isExtension) {
            ud = [self groupDefaults];
        }
        [self reloadConfigureFromUserDefaults:ud];
    }
    
    return self;
}

- (void)reloadConfigureForExtension {
    if (isExtension) {
        [self reloadConfigureFromUserDefaults:self.groupDefaults];
    }
}

//App运行才有效
- (void)copyLoginInfoFromAppToExtension {
    
    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
    NSUserDefaults *groupDefaults = self.groupDefaults;
    
    [groupDefaults setBool:[appDefaults boolForKey:@"isRegisterWeibo"] forKey:@"isRegisterWeibo"];
    
    NSString *userId = [appDefaults objectForKey:@"userId"];
    if (userId) {
        [groupDefaults setObject:userId forKey:@"userId"];
    }
    
    NSString *lsKey = [appDefaults objectForKey:@"lsKey"];
    if (lsKey) {
        [groupDefaults setObject:lsKey forKey:@"lsKey"];
    }
    
    NSString *sKey = [appDefaults objectForKey:@"sKey"];
    if (sKey) {
        [groupDefaults setObject:sKey forKey:@"sKey"];
    }

    NSString *psKey = [appDefaults objectForKey:@"psKey"];
    if (psKey) {
        [groupDefaults setObject:psKey forKey:@"psKey"];
    }

    NSString *stWeb = [appDefaults objectForKey:@"stWeb"];
    if (stWeb) {
        [groupDefaults setObject:stWeb forKey:@"stWeb"];
    }
    
    NSString *openId = [appDefaults objectForKey:@"openId"];
    if (openId) {
        [groupDefaults setObject:openId forKey:@"openId"];
    }
    
    NSString *token = [appDefaults objectForKey:@"token"];
    if (token) {
        [groupDefaults setObject:token forKey:@"token"];
    }

    NSString *tokenExpire = [appDefaults objectForKey:@"tokenExpire"];
    if (tokenExpire) {
        [groupDefaults setObject:tokenExpire forKey:@"tokenExpire"];
    }
    
    NSString *sinaLoginDic = [appDefaults objectForKey:kAccountSinaWeiboLoginDic];
    if (sinaLoginDic) {
        [groupDefaults setObject:sinaLoginDic forKey:kAccountSinaWeiboLoginDic];
    }
    
    NSString *sinaWeiboId = [appDefaults objectForKey:@"bindSinaWeiboId"];
    if (sinaWeiboId) {
        [groupDefaults setObject:sinaWeiboId forKey:@"bindSinaWeiboId"];
    }
    
    NSString *sinaWeiboNickName = [appDefaults objectForKey:@"bindSinaWeiboNickname"];
    if (sinaWeiboNickName) {
        [groupDefaults setObject:sinaWeiboNickName forKey:@"bindSinaWeiboNickname"];
    }

    [groupDefaults setInteger:[appDefaults integerForKey:@"loginType"] forKey:@"loginType"];
    
    [groupDefaults synchronize];
}

- (void)reloadConfigureFromUserDefaults:(NSUserDefaults *)ud {
    
    NSData *data = [ud objectForKey:kCacheKeyUserInfo];
    _wbUserInfo = (GinUser *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    id defaultConfig = nil;
    
    _isRegisterWeibo = [ud boolForKey:@"isRegisterWeibo"];
    
    defaultConfig = [ud objectForKey:@"userId"];
    if(defaultConfig)
    {
        _qqId = [(NSString *)defaultConfig copy];
        defaultConfig = nil;
    }
    defaultConfig = [ud objectForKey:@"lsKey"];
    if(defaultConfig)
    {
        _lsKey = [(NSString *)defaultConfig copy];
        defaultConfig = nil;
    }
    defaultConfig = [ud objectForKey:@"sKey"];
    if(defaultConfig)
    {
        _sKey = [(NSString *)defaultConfig copy];
        defaultConfig = nil;
    }
    defaultConfig = [ud objectForKey:@"psKey"];
    if(defaultConfig)
    {
        _psKey = [(NSString *)defaultConfig copy];
        defaultConfig = nil;
    }
    defaultConfig = [ud objectForKey:@"stWeb"];
    if (defaultConfig) {
        _stWeb = [(NSString *)defaultConfig copy];
        defaultConfig = nil;
    }
    
    defaultConfig = [ud objectForKey:@"openId"];
    if(defaultConfig)
    {
        _openId = [(NSString *)defaultConfig copy];
        defaultConfig = nil;
    }
    
    defaultConfig = [ud objectForKey:@"token"];
    if(defaultConfig)
    {
        _token = [(NSString *)defaultConfig copy];
        defaultConfig = nil;
    }
    
    defaultConfig = [ud objectForKey:@"tokenExpire"];
    if(defaultConfig)
    {
        _tokenExpire = [(NSString *)defaultConfig copy];
        defaultConfig = nil;
    }
    
    defaultConfig = [ud objectForKey:kAccountSinaWeiboLoginDic];
    if(defaultConfig)
    {
        _sinaWeiboLoginDic = defaultConfig;
    }
    
    defaultConfig = [ud objectForKey:@"bindSinaWeiboId"];
    if(defaultConfig)
    {
        _bindSinaWeiboId = [(NSString *)defaultConfig copy];
        defaultConfig = nil;
    }
    
    defaultConfig = [ud objectForKey:@"bindSinaWeiboNickname"];
    if(defaultConfig)
    {
        _bindSinaWeiboNickname = [(NSString *)defaultConfig copy];
        defaultConfig = nil;
    }
    
    _loginType = (eSnsShareType)[ud integerForKey:@"loginType"];
    if (eShareQZone == _loginType || eShareQQ == _loginType) {
        //手q登录
        if (self.openId && self.token) {
            _isLogin = YES;
        }
    }else if (eShareWeiChatTimeLine == _loginType || eShareWeiChatFriend == _loginType){
        //微信登录
        // NOTE!!! the isLogin property set will delegate to GinBaseTokenManager
        //        _isLogin = [[GinWeiChatShare WeiChatShareInstace]isLoggedIn];
        if (isExtension) {
            //微信登录判断被注释掉了，这里根据type判断，type存在，肯定是login状态。
            _isLogin = YES;
        }
    }else if (eShareSinaWeiBo == _loginType){
        //sina微博登录
        _isLogin = _sinaWeiboLoginDic && _sinaWeiboLoginDic.count > 1;
    }else if(eWeishi == _loginType){
        //输入qq登陆
        if (_wbUserInfo.weiShiId && (_lsKey || _sKey)) {
            _isLogin = YES;
        }else{
            _lsKey = nil;
            _sKey =nil;
        }
    }else{
        _isLogin = NO;
    }
    
    if (!_wbUserInfo.weiShiId) {
        _isLogin = NO;
    }
    if (_isLogin) {
        _loginStates = LoginStateSucc;
    }else{
        self.isRegisterWeibo = NO;
        _loginStates = LoginStateFail;
    }
}

#pragma mark - public methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,isRegisterWeibo = %d,wbUserInfo = %@,userId = %@,lsKey = %@,sKey = %@,psKey = %@, stWeb = %@, isLogin = %d,loginStates = %d,isNeedInvate = %ld,saveCache =%d",[super description],self.isRegisterWeibo,self.wbUserInfo,self.qqId,self.lsKey,self.sKey,self.psKey, self.stWeb,self.isLogin,self.loginStates,(long)self.isNeedInvate,self.saveCache];
}

- (void)setDataWithDic:(NSDictionary*)dataDic
{
    if (dataDic && [dataDic isKindOfClass:[NSDictionary class]])
    {
        [self setIsRegisterWeibo:[dataDic ginBoolValueForKey:@"isRegisterWB"]];
        
        if ([dataDic ginStringValueForKey:@"publishUin"] && [dataDic ginStringValueForKey:@"publishUin"].length > 0) {
            self.qqId = [dataDic ginStringValueForKey:@"publishUin"];
        }
        
        self.isNeedInvate = [dataDic ginIntValueForKey:@"need_invite"];
        GinUser *user = [[GinUser alloc]initWithJsonDictionary:dataDic];
        [self setWbUserInfo:user];
        
        self.sinaWeiboLoginDic = [NSMutableDictionary dictionaryWithDictionary:[dataDic dictionaryValueForKey:@"weibologin"]];
        NSString *bindSinaId = [dataDic ginStringValueForKey:@"sinaId"];
        self.bindSinaWeiboId = bindSinaId;
        self.bindSinaWeiboNickname = [dataDic ginStringValueForKey:@"sinaNick"];
        if (self.saveCache) {
            //请不要删除我这句，否则崩溃时可能会丢失登录态
            [[NSUserDefaults standardUserDefaults]synchronize];
            [[self groupDefaults] synchronize];
        }
        
    }
}

#pragma mark - encode & decode methods

-(void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.wbUserInfo forKey:@"wbUserInfo"];
    [encoder encodeBool:self.isRegisterWeibo forKey:@"isRegisterWeibo"];
    [encoder encodeObject:self.qqId forKey:@"userId"];
    [encoder encodeObject:self.lsKey forKey:@"lsKey"];
    [encoder encodeObject:self.sKey forKey:@"sKey"];
    [encoder encodeObject:self.psKey forKey:@"psKey"];
    [encoder encodeObject:self.stWeb forKey:@"stWeb"];
    [encoder encodeObject:self.openId forKey:@"openId"];
    [encoder encodeObject:self.token forKey:@"token"];
    [encoder encodeObject:self.tokenExpire forKey:@"tokenExpire"];
    [encoder encodeInteger:self.loginType forKey:@"loginType" ];
    [encoder encodeObject:self.sinaWeiboLoginDic forKey:@"sinaWeiboLoginDic" ];
    [encoder encodeObject:self.bindSinaWeiboNickname forKey:@"bindSinaWeiboNickname" ];
    [encoder encodeObject:self.bindSinaWeiboId forKey:@"bindSinaWeiboId"];

    
}

-(id) initWithCoder:(NSCoder *)decoder
{
    if( self = [super init] )
    {
        self.wbUserInfo = [decoder decodeObjectForKey:@"wbUserInfo"];
        self.isRegisterWeibo = [decoder decodeBoolForKey:@"isRegisterWeibo"];
        self.qqId = [decoder decodeObjectForKey:@"userId"];
        self.lsKey = [decoder decodeObjectForKey:@"lsKey"];
        self.sKey = [decoder decodeObjectForKey:@"sKey"];
        self.psKey = [decoder decodeObjectForKey:@"psKey"];
        self.stWeb = [decoder decodeObjectForKey:@"stWeb"];
        self.openId = [decoder decodeObjectForKey:@"openId"];
        self.token = [decoder decodeObjectForKey:@"token"];
        self.tokenExpire = [decoder decodeObjectForKey:@"tokenExpire"];
        self.loginType = (eSnsShareType)[decoder decodeIntegerForKey:@"loginType"];
        self.sinaWeiboLoginDic = [decoder decodeObjectForKey:@"sinaWeiboLoginDic"];
        self.bindSinaWeiboId = [decoder decodeObjectForKey:@"bindSinaWeiboId"];

    }
    
    return self;
}

#pragma mark --setMethod

-(void)setIsRegisterWeibo:(BOOL)isRegisterWeibo
{
    _isRegisterWeibo = isRegisterWeibo;
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setBool:_isRegisterWeibo forKey:kAccountIsRegisterWeibo];
        [self.groupDefaults setBool:_isRegisterWeibo forKey:kAccountIsRegisterWeibo];
        [self.groupDefaults synchronize];
    }
}

-(void)setQqId:(NSString *)qqId
{
    if(_qqId == qqId)
    {
        return;
    }
    _qqId = [qqId copy];
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setObject:_qqId forKey:kAccountQQId];
        [self.groupDefaults setObject:_qqId forKey:kAccountQQId];
        [self.groupDefaults synchronize];
    }
}

-(void)setLsKey:(NSString *)lsKey
{
    if(_lsKey == lsKey)
    {
        return;
    }
    _lsKey = [lsKey copy];
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setObject:_lsKey forKey:kAccountLSKey];
        [self.groupDefaults setObject:_lsKey forKey:kAccountLSKey];
        [self.groupDefaults synchronize];
    }
    
}

-(void)setSKey:(NSString *)sKey
{
    if(_sKey == sKey)
    {
        return;
    }
    _sKey = [sKey copy];
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setObject:_sKey forKey:kAccountSKey];
        [self.groupDefaults setObject:_sKey forKey:kAccountSKey];
        [self.groupDefaults synchronize];
    }
}

-(void)setPsKey:(NSString *)psKey
{
    if(_psKey == psKey)
    {
        return;
    }
    _psKey = [psKey copy];
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setObject:_psKey forKey:kAccountPSKey];
        [self.groupDefaults setObject:_psKey forKey:kAccountPSKey];
        [self.groupDefaults synchronize];
    }
}

-(void)setStWeb:(NSString *)stWeb
{
    if(_stWeb == stWeb)
    {
        return;
    }
    _stWeb = [stWeb copy];
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setObject:_stWeb forKey:kAccountSTWeb];
        [self.groupDefaults setObject:_stWeb forKey:kAccountSTWeb];
        [self.groupDefaults synchronize];
    }
}

-(void)setOpenId:(NSString *)openId
{
    if(_openId == openId)
    {
        return;
    }
    _openId = [openId copy];
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setObject:_openId forKey:kAccountOpenId];
        [self.groupDefaults setObject:_openId forKey:kAccountOpenId];
        [self.groupDefaults synchronize];
    }
}

-(void)setToken:(NSString *)token
{
    if(_token == token)
    {
        return;
    }
    _token = [token copy];
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setObject:_token forKey:kAccountToken];
        [self.groupDefaults setObject:_token forKey:kAccountToken];
        [self.groupDefaults synchronize];
    }
}

- (void)setTokenExpire:(NSString *)tokenExpire
{
    if ([_tokenExpire isEqualToString:tokenExpire]) {
        return;
    }
    _tokenExpire = [tokenExpire copy];
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setObject:_tokenExpire forKey:kAccountTokenExpire];
        [self.groupDefaults setObject:_tokenExpire forKey:kAccountTokenExpire];
        [self.groupDefaults synchronize];
    }
}

-(void)setLoginType:(eSnsShareType)loginType
{
    _loginType = loginType;
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setInteger:_loginType forKey:kAccountLoginType];
        [self.groupDefaults setInteger:_loginType forKey:kAccountLoginType];
        [self.groupDefaults synchronize];
    }
}

-(void)setIsLogin:(BOOL)isLogin
{
    if (isLogin) {
        _isLogin = isLogin;
        _loginStates = LoginStateSucc;
    }
    else
    {
        _isLogin = isLogin;
        _loginStates = LoginStateFail;
    }
}

-(void)setWbUserInfo:(GinUser *)wbUserInfo
{
    if (_wbUserInfo == wbUserInfo) {
        return;
    }
    _wbUserInfo = wbUserInfo;
}

-(void)setSinaWeiboLoginDic:(NSMutableDictionary *)sinaWeiboLoginDic
{
    if ([sinaWeiboLoginDic isEqual:_sinaWeiboLoginDic]) {
        return;
    }
    
    if (sinaWeiboLoginDic.count < 1 && self.loginType == eShareSinaWeiBo && _sinaWeiboLoginDic.count > 0) {
        //sina微博登录状态如果获取到的sinaWeiboLoginDic为空说明不是登录时获取的用户信息，这时不应该刷新sinaWeiboLoginDic
        return;
    }
    _sinaWeiboLoginDic = sinaWeiboLoginDic;
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setObject:_sinaWeiboLoginDic forKey:kAccountSinaWeiboLoginDic];
        [[self groupDefaults] setObject:_sinaWeiboLoginDic forKey:kAccountSinaWeiboLoginDic];
        //请不要删除这句，否则崩溃时可能会丢失登录态
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[self groupDefaults] synchronize];
    }
}

- (void)setBindSinaWeiboId:(NSString *)bindSinaWeiboId
{
    if ([_bindSinaWeiboId isEqualToString:bindSinaWeiboId]) {
        return;
    }
    _bindSinaWeiboId = [bindSinaWeiboId copy];
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setObject:_bindSinaWeiboId forKey:kAccountBindSinaWeiboId];
        [self.groupDefaults setObject:_bindSinaWeiboId forKey:kAccountBindSinaWeiboId];
        [self.groupDefaults synchronize];
    }
}

- (void)setBindSinaWeiboNickname:(NSString *)bindSinaWeiboNickname
{
    if ([_bindSinaWeiboNickname isEqualToString:bindSinaWeiboNickname]) {
        return;
    }
    _bindSinaWeiboNickname = [bindSinaWeiboNickname copy];
    if (self.saveCache) {
        [[NSUserDefaults standardUserDefaults] setObject:_bindSinaWeiboNickname forKey:kAccountBindSinaWeiboNickName];
        [self.groupDefaults setObject:_bindSinaWeiboNickname forKey:kAccountBindSinaWeiboNickName];
        [self.groupDefaults synchronize];
    }
}

@end
