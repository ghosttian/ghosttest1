//
//  GinIdol.h
//  microChannel
//
//  Created by minghuiji on 13-7-22.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GinIdol : NSObject<NSCopying, NSCoding>

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *name;         //用户名
@property (nonatomic, copy) NSString *headUrl;
@property (nonatomic, copy) NSString *nickNamePingyin;
@property (nonatomic, copy) NSString *nickNameAllLetterFirstPinyin;
@property (nonatomic, copy) NSString *simNickName;  //简体账号
@property (nonatomic, copy) NSString *traNickName;  //繁体账号
@property (nonatomic, assign) int sex;
@property (nonatomic, assign) BOOL isMyFans;
@property (nonatomic, assign) BOOL isMyIdol;
@property (nonatomic, assign) BOOL isVip;
@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, assign) BOOL isBlock;     //是否被拉黑
@property (nonatomic, copy) NSString* userInfo;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, copy) NSString* remark;
@property (nonatomic, assign) int idolNum;               //收听的人数
@property (nonatomic, assign) int fansNum;               //听众数
@property (nonatomic, assign) int tweetNum;              //发表的微视数
@property (nonatomic, assign) int rankNum;
@property (nonatomic, assign) int eliteNum;
@property (nonatomic, assign) BOOL isTotalCelebrity;

- (id)initWithJsonDictionary: (NSDictionary *)dic;

- (id)initNewFriendWithJsonDictionary:(NSDictionary *)dic;


@end
