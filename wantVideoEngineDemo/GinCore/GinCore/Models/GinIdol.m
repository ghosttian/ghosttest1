//
//  GinIdol.m
//  microChannel
//
//  Created by minghuiji on 13-7-22.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinIdol.h"
#import "GinPinyinUtil.h"
#import "NSDictionary+Additions.h"

@implementation GinIdol

- (id)initWithJsonDictionary: (NSDictionary *)dic
{
    if (self = [super init]) {
        self.uid = [dic ginStringValueForKey:@"uid"];
        self.name = [dic ginStringValueForKey:@"name"];
        self.headUrl = [dic ginStringValueForKey:@"head"];
        self.isMyFans = [dic ginIntValueForKey:@"is_followed"];
        self.isMyIdol = [dic ginIntValueForKey:@"is_follow"];
        self.sex = [dic ginIntValueForKey:@"sex"];
        self.isVip = [dic ginBoolValueForKey:@"is_auth"];
        self.isSelf = [dic ginBoolValueForKey:@"isSelf"];
        self.isBlock = [dic ginBoolValueForKey:@"is_block"];
        self.userInfo = [dic ginStringValueForKey:@"info"];
        self.time = [dic ginIntValueForKey:@"time"];
        self.remark = [dic ginStringValueForKey:@"remark"];
        self.rankNum = [dic ginIntValueForKey:@"rank_num"];
        self.eliteNum = [dic ginIntValueForKey:@"elite_num"];
        self.traNickName = [dic ginStringValueForKey:@"traname"];
        self.simNickName = [dic ginStringValueForKey:@"simname"];
        NSString * simNickName = self.simNickName ? self.simNickName : self.name;
        self.nickNamePingyin = [[GinPinyinUtil convert:simNickName] lowercaseString];
        self.nickNameAllLetterFirstPinyin = [GinPinyinUtil getAllLetterFirstPinyin:simNickName];
        self.idolNum = [dic ginIntValueForKey:@"following_num"];
        self.fansNum = [dic ginIntValueForKey:@"follower_num"];
        self.tweetNum = [dic ginIntValueForKey:@"tweet_num"];
    }
    return self;
}

- (id)initNewFriendWithJsonDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        self.name = [dic ginStringValueForKey:@"name"];
        self.uid = [dic ginStringValueForKey:@"uid"];
        self.time = [dic unsignedIntegerValueForKey:@"time"];
        self.headUrl= [dic ginStringValueForKey:@"head"];
        self.remark = [dic ginStringValueForKey:@"source_nick"];
        self.isMyFans = [dic ginBoolValueForKey:@"is_followed"];
        self.isMyIdol = [dic ginBoolValueForKey:@"is_follow"];
        self.isVip = [dic ginBoolValueForKey:@"is_auth"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.uid forKey:@"uid"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.headUrl forKey:@"headUrl"];
    [encoder encodeObject:self.nickNamePingyin forKey:@"nickNamePingyin"];
    [encoder encodeObject:self.nickNameAllLetterFirstPinyin forKey:@"nickNameAllLetterFirstPinyin"];
    [encoder encodeInteger:self.sex forKey:@"sex"];
    [encoder encodeBool:self.isMyFans forKey:@"isMyFans"];
    [encoder encodeBool:self.isMyIdol forKey:@"isMyIdol"];
    [encoder encodeBool:self.isVip forKey:@"isVip"];
    [encoder encodeBool:self.isSelf forKey:@"isSelf"];
    [encoder encodeBool:self.isBlock forKey:@"isBlock"];
    [encoder encodeObject:self.userInfo forKey:@"description"];
    [encoder encodeInteger:self.time forKey:@"time"];
    [encoder encodeObject:self.remark forKey:@"remark"];
    [encoder encodeObject:self.simNickName forKey:@"simname"];
    [encoder encodeObject:self.traNickName forKey:@"traname"];
    [encoder encodeInteger:self.idolNum forKey:@"following_num"];
    [encoder encodeInteger:self.fansNum forKey:@"follower_num"];
    [encoder encodeInteger:self.tweetNum forKey:@"tweet_num"];
    [encoder encodeInteger:self.rankNum forKey:@"rank_num"];
    [encoder encodeInteger:self.eliteNum forKey:@"elite_num"];
    [encoder encodeInteger:self.isTotalCelebrity forKey:@"isTotalCelebrity"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.uid = [decoder decodeObjectForKey:@"uid"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.headUrl = [decoder decodeObjectForKey:@"headUrl"];
        self.nickNamePingyin = [decoder decodeObjectForKey:@"nickNamePingyin"];
        self.nickNameAllLetterFirstPinyin = [decoder decodeObjectForKey:@"nickNameAllLetterFirstPinyin"];
        self.sex = [decoder decodeIntForKey:@"sex"];
        self.isMyFans = [decoder decodeBoolForKey:@"isMyFans"];
        self.isMyIdol = [decoder decodeBoolForKey:@"isMyIdol"];
        self.isVip = [decoder decodeBoolForKey:@"isVip"];
        self.isSelf = [decoder decodeBoolForKey:@"isSelf"];
        self.isBlock = [decoder decodeBoolForKey:@"isBlock"];
        self.userInfo = [decoder decodeObjectForKey:@"description"];
        self.time = [decoder decodeIntegerForKey:@"time"];
        self.remark = [decoder decodeObjectForKey:@"remark"];
        self.simNickName = [decoder decodeObjectForKey:@"simname"];
        self.traNickName = [decoder decodeObjectForKey:@"traname"];
        self.idolNum = [decoder decodeIntForKey:@"following_num"];
        self.fansNum = [decoder decodeIntForKey:@"follower_num"];
        self.tweetNum = [decoder decodeIntForKey:@"tweet_num"];
        self.rankNum = [decoder decodeIntForKey:@"rank_num"];
        self.eliteNum = [decoder decodeIntForKey:@"elite_num"];
        self.isTotalCelebrity = [decoder decodeIntForKey:@"isTotalCelebrity"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"uid:%@ name:%@  headurl:%@ Pingyin:%@ FirstLetterPinyin:%@ info:%@ simname %@ traname %@", self.uid, self.name,  self.headUrl,self.nickNamePingyin,self.nickNameAllLetterFirstPinyin,self.userInfo, self.simNickName, self.traNickName];
}

- (id)copyWithZone:(NSZone *)zone
{
    GinIdol *c = [[GinIdol allocWithZone:zone] init];
    c.uid = self.uid;
    c.name = self.name;
    c.headUrl = self.headUrl;
    c.sex = self.sex;
    c.isMyFans = self.isMyFans;
    c.isMyIdol = self.isMyIdol;
    c.isVip = self.isVip;
    c.isSelf = self.isSelf;
    c.isBlock = self.isBlock;
    c.nickNamePingyin = self.nickNamePingyin;
    c.time = self.time;
    c.remark = self.remark;
    c.simNickName = self.simNickName;
    c.traNickName = self.traNickName;
    c.idolNum = self.idolNum;
    c.fansNum = self.fansNum;
    c.tweetNum = self.tweetNum;
    c.rankNum = self.rankNum;
    c.eliteNum = self.eliteNum;
    c.isTotalCelebrity = self.isTotalCelebrity;
    return c;
}

@end
