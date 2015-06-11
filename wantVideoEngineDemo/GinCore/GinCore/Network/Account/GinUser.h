//
//  GinUser.h
//  microChannel
//
//  Created by minghuiji on 13-7-22.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef enum
//{
//    GenderUnknow = 0,
//    GenderMale,
//    GenderFemale,
//} Gender;
//
//typedef enum
//{
//    OnlineStatusOffline = 0,
//    OnlineStatusOnline = 1,
//} OnlineStatus;

@interface GinUser : NSObject<NSCoding, NSCopying>
{
}

@property(nonatomic, copy) NSString     *weiShiId;          //用户微视id
@property(nonatomic, copy) NSString     *accountName;       //用户昵称
@property(nonatomic, copy) NSString     *wbNickName;        //用户微博昵称
@property(nonatomic, copy) NSString     *headUrl;           //头像url
@property(nonatomic, copy) NSString     *coverUrl;          //cover
@property(nonatomic, assign) int        sex;                //用户性别，1-男，2-女，0-未填写
@property(nonatomic, assign) int        idolNum;            //收听的人数
@property(nonatomic, assign) int        fansNum;            //听众数
@property(nonatomic, assign) int        favNum;             //赞的个数数
@property(nonatomic, assign) int        tweetNum;           //发表的微博数
@property(nonatomic, assign) int        commentNum;         //评论个数
@property(nonatomic, assign) int        retweetNum;         //转评个数
@property(nonatomic, assign) NSInteger  userLevel;           //用户等级
@property(nonatomic, copy) NSString     *mail;              //邮箱

@property(nonatomic, copy)NSString      *countryCode;       //国家id
@property(nonatomic, copy)NSString      *provinceCode;      //地区id
@property(nonatomic, copy)NSString      *cityCode;          //城市id
@property(nonatomic, copy)NSString      *location;          // 地区描述
@property(nonatomic, copy)NSString      *introduction;      //个人介绍
@property(nonatomic, assign) BOOL       isVip;              //是否认证用户，0-不是，1-是
@property(nonatomic, copy)NSString*     verifyInfo;         //认证信息
@property(nonatomic, copy)NSString*     preRzName;          //预认证名称
@property(nonatomic, copy)NSString*     preRzInfo;          //预认证信息

@property(nonatomic, assign) BOOL       isMySelf;           //是否是当前用户，0-不是，1-是
@property(nonatomic, assign) BOOL       isMyFans;           // 是否是当前用户的粉丝，0-不是，1-是
@property(nonatomic, assign) BOOL       isMyidol;           //是否是当前用户的偶像，0-不是，1-是
@property(nonatomic, assign) BOOL       isBlack;            //是否在我的黑名单中

@property(nonatomic, copy) NSString     *modAccNoPre;           // 不能修改个人信息提示文案
@property(nonatomic, copy) NSString     *modAccWording;         // 修改个人信息wording
@property(nonatomic, copy) NSString     *qrCardUrl;
@property(nonatomic, copy) NSString     *qrlinkUrl;
@property(nonatomic, copy) NSDictionary *qrShareTextDict;
@property(nonatomic, copy) NSString     *homePage;              //主页url

@property(nonatomic, copy) NSString     *bindPhoneNum;
@property(nonatomic, copy) NSString     *addressDevice;
@property(nonatomic, assign) NSInteger  jumppage;            //登录成功跳到哪个页面 100-跳到热门， 其他跳到主页
//是否订阅该用户，只对当前登录用户有效，用户退出登录需重置。
@property(nonatomic, assign)BOOL isSubscribed;

// 0代表勋章功能开启不需要引导，1第一次来玩勋章，2再来玩勋章
@property(nonatomic, assign) NSInteger  medalGuide;
//1封停，0或其他是正常
@property(nonatomic, assign) NSInteger  forbidUser;
//周年庆视频
@property(nonatomic, copy) NSString     *anniversaryId;

- (id)initWithJsonDictionary:(NSDictionary*)dic;

@end
