//
//  GinUser.m
//  microChannel
//
//  Created by minghuiji on 13-7-22.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinUser.h"
#import "GinDateFormatter.h"
#import "NSDictionary+Additions.h"

//默认展示页卡
NSString *const kGinDefaultTabType                      =   @"GinDefaultTab";
const int kJumpPageHot                                  =   100;//登录成功默认进入热门页面
const int kDefaultJumpPageHot                           =   2;//登录成功默认进入热门页面

@implementation GinUser

-(void)dealloc
{

}

#pragma mark -- keyed archiving
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.weiShiId forKey:@"uid"];
    [encoder encodeObject:self.cityCode forKey:@"cityCode"];
    [encoder encodeObject:self.countryCode forKey:@"countryCode"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeInt:self.fansNum forKey:@"fansNum"];
    [encoder encodeInt:self.favNum forKey:@"favNum"];
    [encoder encodeInt:self.commentNum forKey:@"commentNum"];
    [encoder encodeInt:self.retweetNum forKey:@"retweetNum"];
    [encoder encodeInteger:self.userLevel forKey:@"userLevel"];
    [encoder encodeObject:self.mail forKey:@"mail"];

    [encoder encodeObject:self.headUrl forKey:@"head"];
    [encoder encodeObject:self.coverUrl forKey:@"coverUrl"];
    [encoder encodeInt:self.idolNum forKey:@"idolNum"];
    [encoder encodeObject:self.introduction forKey:@"introduction"];

    [encoder encodeBool:self.isMySelf forKey:@"is_self"];
    [encoder encodeBool:self.isMyFans forKey:@"isMyFans"];
    [encoder encodeBool:self.isMyidol forKey:@"is_follow"];
    [encoder encodeBool:self.isVip forKey:@"isVip"];
    [encoder encodeObject:self.accountName forKey:@"name"];
    [encoder encodeObject:self.wbNickName forKey:@"nick"];
    [encoder encodeObject:self.provinceCode forKey:@"provinceCode"];
    [encoder encodeInt:self.sex forKey:@"sex"];
    [encoder encodeInt:self.tweetNum forKey:@"tweetNum"];
    [encoder encodeObject:self.verifyInfo forKey:@"verifyInfo"];
    [encoder encodeObject:self.preRzName forKey:@"preRzName"];
    [encoder encodeObject:self.preRzInfo forKey:@"preRzInfo"];
    [encoder encodeBool:self.isBlack forKey:@"isBlack"];
    
    [encoder encodeObject:self.modAccNoPre forKey:@"modAccNoPre"];
    [encoder encodeObject:self.modAccWording forKey:@"modAccWording"];
    [encoder encodeObject:self.homePage forKey:@"homePage"];
    
    [encoder encodeObject:self.bindPhoneNum forKey:@"bindPhoneNum"];
    [encoder encodeObject:self.addressDevice forKey:@"addressDevice"];
    
    [encoder encodeInteger:self.medalGuide forKey:@"medalGuide"];
    [encoder encodeInteger:self.forbidUser forKey:@"forbidUser"];
    [encoder encodeObject:self.anniversaryId forKey:@"anniversaryId"];
    [encoder encodeInteger:self.jumppage forKey:@"jumppage"];
    [encoder encodeBool:self.isSubscribed forKey:@"isSubscribed"];

}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
        self.weiShiId = [decoder decodeObjectForKey:@"uid"];
        self.cityCode = [decoder decodeObjectForKey:@"cityCode"];
        self.countryCode = [decoder decodeObjectForKey:@"countryCode"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.fansNum = [decoder decodeIntForKey:@"fansNum"];
        self.favNum = [decoder decodeIntForKey:@"favNum"];
        self.commentNum = [decoder decodeIntForKey:@"commentNum"];
        self.retweetNum = [decoder decodeIntForKey:@"retweetNum"];
        self.userLevel = [decoder decodeIntForKey:@"userLevel"];
        self.mail = [decoder decodeObjectForKey:@"mail"];
        self.headUrl = [decoder decodeObjectForKey:@"head"];
        self.coverUrl = [decoder decodeObjectForKey:@"coverUrl"];
        self.idolNum = [decoder decodeIntForKey:@"idolNum"];
        self.introduction = [decoder decodeObjectForKey:@"introduction"];
        self.isMySelf = [decoder decodeBoolForKey:@"is_self"];
        self.isMyFans = [decoder decodeBoolForKey:@"isMyFans"];
        self.isMyidol = [decoder decodeBoolForKey:@"is_follow"];
        self.isVip = [decoder decodeBoolForKey:@"isVip"];
        self.accountName = [decoder decodeObjectForKey:@"name"];
        self.wbNickName = [decoder decodeObjectForKey:@"nick"];
        self.provinceCode = [decoder decodeObjectForKey:@"provinceCode"];
        self.sex = [decoder decodeIntForKey:@"sex"];
        self.tweetNum = [decoder decodeIntForKey:@"tweetNum"];
        self.verifyInfo = [decoder decodeObjectForKey:@"verifyInfo"];
        self.preRzName = [decoder decodeObjectForKey:@"preRzName"];
        self.preRzInfo = [decoder decodeObjectForKey:@"preRzInfo"];
        self.isBlack = [decoder decodeBoolForKey:@"isBlack"];
        self.modAccNoPre = [decoder decodeObjectForKey:@"modAccNoPre"];
        self.modAccWording = [decoder decodeObjectForKey:@"modAccWording"];
        self.homePage=[decoder decodeObjectForKey:@"homePage"];
        self.bindPhoneNum = [decoder decodeObjectForKey:@"bindPhoneNum"];
        self.addressDevice = [decoder decodeObjectForKey:@"addressDevice"];
        self.medalGuide = [decoder decodeIntForKey:@"medalGuide"];
        self.forbidUser = [decoder decodeIntForKey:@"forbidUser"];
        self.anniversaryId = [decoder decodeObjectForKey:@"anniversaryId"];
        self.jumppage = [decoder decodeIntForKey:@"jumppage"];
        self.isSubscribed = [decoder decodeBoolForKey:@"isSubscribed"];
        

    }
    return self;
}
- (id)initWithJsonDictionary:(NSDictionary*)dic
{
    if(self = [super init])
    {
        NSString *weiShiId = [dic ginStringValueForKey:@"uid"];
        if (weiShiId && weiShiId.length > 0) {
            self.weiShiId = [dic ginStringValueForKey:@"uid"];
        }else{

        }
        
        NSString *acc = [dic ginStringValueForKey:@"name"];
        if (acc && acc.length > 0) {
            self.accountName = [dic ginStringValueForKey:@"name"];
        }else{

        }
        
        self.wbNickName = [dic ginStringValueForKey:@"nick"];
        
        NSString *head = [dic ginStringValueForKey:@"head"];
        if (head && head.length > 0) {
            self.headUrl = [dic ginStringValueForKey:@"head"];
        }else{

        }
        self.coverUrl = [dic ginStringValueForKey:@"front_img"];
        
        self.sex = [dic ginIntValueForKey:@"sex"];
        self.idolNum = [dic ginIntValueForKey:@"following_num"];
        self.fansNum = [dic ginIntValueForKey:@"follower_num"];
        self.tweetNum = [dic ginIntValueForKey:@"tweet_num"];
        self.favNum = [dic ginIntValueForKey:@"like_num"];
        self.commentNum = [dic ginIntValueForKey:@"comment_num"];
        self.retweetNum = [dic ginIntValueForKey:@"retweet_num"];
        self.userLevel = [dic ginIntValueForKey:@"level"];
        self.mail = [dic ginStringValueForKey:@"email"];
        self.countryCode = [dic ginStringValueForKey:@"country_code"];
        self.provinceCode = [dic ginStringValueForKey:@"province_code"];
        self.location = [dic ginStringValueForKey:@"location"];
        self.cityCode = [dic ginStringValueForKey:@"city_code"];
        self.introduction = [dic ginStringValueForKey:@"introduction"];
        self.isVip = [dic ginBoolValueForKey:@"is_auth"];
        self.verifyInfo = [dic ginStringValueForKey:@"verifyinfo"];
        self.preRzName = [dic ginStringValueForKey:@"preRzName"];
        self.preRzInfo = [dic ginStringValueForKey:@"preRzInfo"];

        self.isMySelf = [dic ginBoolValueForKey:@"is_self"];
        self.isMyidol = [dic ginBoolValueForKey:@"is_follow"];
        self.isMyFans = [dic ginBoolValueForKey:@"is_followed"];
        self.isBlack = [dic ginBoolValueForKey:@"isBlack"];
        
        self.modAccNoPre = [dic ginStringValueForKey:@"modAccNoPre"];
        self.modAccWording = [dic ginStringValueForKey:@"modAccWording"];
        self.homePage=[dic ginStringValueForKey:@"homepage"];
        
        self.bindPhoneNum = [dic ginStringValueForKey:@"bindPhoneNum"];
        self.addressDevice = [dic ginStringValueForKey:@"addressDevice"];
        
        self.medalGuide = [dic ginIntValueForKey:@"medalGuide"];
        self.forbidUser = [dic ginIntValueForKey:@"forbidUser"];
        self.forbidUser = self.forbidUser==1 ? 1 : 0;
        self.anniversaryId = [dic ginStringValueForKey:@"anniversary"];
        self.jumppage = [dic ginIntValueForKey:@"jumppage" defaultValue:0];
        NSNumber *jumpTab = [[NSUserDefaults standardUserDefaults] objectForKey:kGinDefaultTabType];
        self.jumppage = jumpTab.intValue == kDefaultJumpPageHot ? kJumpPageHot : 0;
        self.isSubscribed =[dic ginBoolValueForKey:@"is_subscribe"];
    }
    return self;
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    GinUser *u = [[GinUser allocWithZone:zone] init];
    u.weiShiId = self.weiShiId;
    u.cityCode = self.cityCode;
    u.countryCode = self.countryCode;
    u.location = self.location;
    u.fansNum = self.fansNum;
    u.favNum = self.favNum;
    u.commentNum = self.commentNum;
    u.retweetNum = self.retweetNum;
    u.userLevel = self.userLevel;
    u.mail = self.mail;
    u.headUrl = self.headUrl;
    u.coverUrl = self.coverUrl;
    u.idolNum = self.idolNum;
    u.introduction = self.introduction;
    u.isMySelf = self.isMySelf;
    u.isMyFans = self.isMyFans;
    u.isMyidol = self.isMyidol;
    u.isVip = self.isVip;
    u.accountName = self.accountName;
    u.wbNickName = self.wbNickName;
    u.provinceCode = self.provinceCode;
    u.sex = self.sex;
    u.tweetNum = self.tweetNum;
    u.verifyInfo = self.verifyInfo;
    u.preRzName = self.preRzName;
    u.preRzInfo = self.preRzInfo;
    u.isBlack = self.isBlack;
    u.modAccNoPre = self.modAccNoPre;
    u.modAccWording = self.modAccWording;
    u.homePage = self.homePage;
    u.bindPhoneNum = self.bindPhoneNum;
    u.addressDevice = self.addressDevice;
    u.medalGuide = self.medalGuide;
    u.forbidUser = self.forbidUser;
    u.anniversaryId = self.anniversaryId;
    u.jumppage = self.jumppage;

    return u;
}

@end
