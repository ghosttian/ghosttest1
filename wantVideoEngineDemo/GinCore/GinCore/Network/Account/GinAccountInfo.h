//
//  GinAccountInfo.h
//  microChannel
//
//  Created by minghuiji on 13-7-22.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GinUser.h"
typedef enum
{
    LoginStateFail = 0,
    LoginStateIng = 1,
    LoginStateSucc = 2,
    LoginStateShow = 3
}LoginStates;

//第三方登录分享类型
typedef enum eSnsShareType{
    eShareQQWeibo,//腾讯微博
    eWeishi,//微视登录
    eShareWeiChatFriend,//微信好友
    eShareQQ,//qq
    eShareQZone,//qzone
    eShareWeiChatTimeLine,//微信朋友圈
    eShareWeiChatCurrentSession,//分享到当前对话框
    eWeiChatSave,//保存到微信
    eShareSinaWeiBo,//分享到sina微博
    eShareSynToQzone,//同步到qoze
    eUnLogin,
}eSnsShareType;

@interface GinAccountInfo : NSObject<NSCoding>
@property (nonatomic, assign) BOOL isRegisterWeibo;//是否是微博用户
@property(nonatomic,strong) GinUser *wbUserInfo;
@property(nonatomic, copy) NSString *qqId ; //QQ号
@property(nonatomic, copy) NSString *lsKey;
@property(nonatomic, copy) NSString *sKey;
@property(nonatomic, copy) NSString *psKey;
@property(nonatomic, copy) NSString *stWeb;
@property(nonatomic,copy) NSString *openId;//手q、微信授权获取的openid
@property(nonatomic,copy) NSString *token;//手q、微信授权获取的token
@property(nonatomic,copy) NSString *tokenExpire;//sina微博授权token有效期
@property(nonatomic,assign) BOOL isLogin;
@property(nonatomic,assign) LoginStates loginStates;
@property (nonatomic, assign) NSInteger isNeedInvate;//第一次登录用户是否需要验证码
@property(nonatomic, assign) BOOL saveCache;
@property (nonatomic, assign) eSnsShareType loginType;//登录类型：微信、qq、微视
@property(nonatomic,strong) NSMutableDictionary *sinaWeiboLoginDic;//sina微博登陆服务器下发的票据
@property(nonatomic, copy) NSString *bindSinaWeiboId ;//当前账号绑定的sina微博账户id
@property(nonatomic, copy) NSString *bindSinaWeiboNickname ;//当前账号绑定的sina微博账户昵称

+ (GinAccountInfo *)sharedAccountInfo;
- (void)setDataWithDic:(NSDictionary*)dataDic;

- (void)copyLoginInfoFromAppToExtension; //已登录的用户，extension无法同步login数据，需要手动同步。
- (void)reloadConfigureForExtension; //app切换账号状态后extension不会同步，需手动reload。

@end
