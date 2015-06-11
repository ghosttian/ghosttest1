//
//  GinUserDefaultKey.h
//  microChannel
//
//  Created by ghosttian on 14-6-24.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//
#import <Foundation/Foundation.h>

extern NSString * const kUserDefaultAlreadyInviteFriendsPrefix;
extern NSString * const kUserDefaultAlreadyInviteWeiboFriendsPrefix;

extern NSString * const kUserDefaultFirstSaveDraftKey;
extern NSString * const kUserDefaultFirstLikeTweet;


/**
 * common
 */
#define kAppLaunchDate                  @"LaunchDate"
#define kPreAppLaunchDate               @"PreLaunchDate"
#define kSeriousCrashCount              @"SeriousCrashCount"
#define kMVLockedFilterUserDefaultKey   @"HasShareMyWeishi" //定义加锁的特效消息
#define klastRefreshWtloginKeyTime      @"klastRefreshWtloginKeyTime"
#define kRankInfo                       @"RankInfo"
#define kInitWelcomePage                @"initWelcomePage"
#define ChannelDataMd5Key               @"ChannelDataMd5Key"
#define TagDataMd5Key                   @"TagDataMd5Key"

#define kNeedShowRecommandView          @"NeedShowRecommandView"
#define kneedSinaWeibo                  @"kneedSinaWeibo" //是否需要分享到sina微博
#define kShareImgBottomImgUrl           @"kShareImgBottomImgUrl" //分享到第三方时下方带有的图片
#define kshareNeedSid                   @"shareNeedSid" //分享链接是否需要sid
#define ksynWechat                      @"ksynWechat" //服务器控制是否同步微信朋友圈
#define kshowNativeDiscovery            @"kshowNativeDiscovery" //发现页是否显示本地页卡
#define kdiscoveryH5Url                 @"kdiscoveryH5Url" //发现页H5-url
#define kdiscoveryBackupH5Url           @"kdiscoveryBackupH5Url" //发现页备份H5-url
#define kGuideAppstore                  @"kGuideAppstore" //是否开启评分机制
//#define Share_Friend_Pic                @"friendPic"
#define User_Default_Invite_Friends_Pic @"invite_friends_pic_url"
#define User_Default_String_DownloadAPIType @"DownloadAPIType"
#define User_Default_Url_Weishi_Icon    @"weishi_icon_url"
#define User_Default_Feedback_Url_Key   @"feedbackUrl"
#define kMyPageCellConfig               @"my_page_cell_config_data" // 我的tab动态cell 配置信息
#define kPhpErrorLevel                  @"kPhpErrorLevel"//上报错误最低级别
#define kEditConfigGroupUrlForH5        @"kEditConfigGroupUrlForH5"
#define kServerIpArray                  @"kServerIpArray"
#define kCanShootLongVideo              @"kCanShootLongVideo"
#define kRecommendUserUrl               @"recommondUserUrlkey"
#define kPlayWhileDownloadingUserDefaultKey           @"playDownloading"


/**
 * 分享
 */
#define kNeedQzoneSyn                   @"needQzoneSyn"
#define ShareTOWeChatTLKey              @"share_to_wx_tl_key"
#define needSinaWeiboLoginKey           @"needSinaWeiboLoginKey"
#define kRetweetNeedWords               @"retweetNeedWords"


/**
 * 视频上传
 */
#define WeishiApplyRetry                @"weishi_apply_retry"
#define WeishiUploadRetry               @"weishi_upload_retry"
#define WeishiResetRetry                @"weishi_reset_retry"
#define WeishiWifiUpSize                @"weishi_wifi_up_size"
#define WeishiNoWifiUpSize              @"weishi_nowifi_up_size"
#define WeishiUploadLogFileSize         @"upload_log_file_size"
#define WeishiIsPreUploadEnable         @"pre_upload_enable"
#define WeishiIsGLogEnable              @"glog_enable"
#define WeishiIsMandatoryUploadGLog     @"mandatory_upload_glog_enable"
#define WeishiUploadType                @"weishi_upload_Type"
#define WeishiUploadSubType             @"weishi_upload_sub_Type"
#define kAutoUploadLongVideo            @"auto_upload_long_video"
#define kUploadSizeDict                 @"upload_size_dictionary"

/**
 * Push
 */
#define kPushToken                      @"UserDefaultPushToken"
#define kPushReason                     @"UserDefaultPushReason"
#define kPushId                         @"UserDefaultPushId"
#define kPushTweetType                  @"UserDefaultPushTweetType"  //push跳转类型
#define kPushTweetId                    @"UserDefaultPushTweetId"    //跳转参数 eg.tweetId
#define kPushTweetSt                    @"UserDefaultPushTweetSt"    //用来区分发现也最新和热门segment

/**
 * GinAccountInfo
 */
//账号信息相关
#define kAccountSinaWeiboLoginDic       @"sinaWeiboLoginDic"
#define kAccountIsRegisterWeibo         @"isRegisterWeibo"
#define kAccountQQId                    @"userId"
#define kAccountWeishiId                @"uid"
#define kAccountInfo                    @"account"
#define kAccountNickName                @"nickName"
#define kAccountProfileImageUrl         @"profileImageUrl"
#define kAccountUserCoverUrl            @"userCoverImgUrl"
#define kAccountLSKey                   @"lsKey"
#define kAccountSKey                    @"sKey"
#define kAccountPSKey                   @"psKey"
#define kAccountSTWeb                   @"stWeb"
#define kAccountOpenId                  @"openId"
#define kAccountToken                   @"token"
#define kAccountTokenExpire             @"tokenExpire"
#define kAccountUserLevel               @"userLevel"
#define kAccountLoginType               @"loginType"
#define kAccountBindSinaWeiboId         @"bindSinaWeiboId"
#define kAccountBindSinaWeiboNickName   @"bindSinaWeiboNickname"

//账号状态相关
#define kLatestLoginUserAccount         @"latestLoginUserAccount"//最近登录的用户账号信息
#define kWeiShiLoginAccount             @"kWeiShiLoginAccount"//最近普通登录的用户账号
#define kisFirstHanderUserLogin         @"kisFirstHanderUserLogin"  //使用老userid处理登陆态问题
#define kAlreadyClick4AccountPage       @"already_click_4_account_page"
#define kUserFirstLogin                 @"kUserFirstLogin" //用户是否是第一次登录，是的话记录下来，知道下一次登录成功清除

/**
 * AddressBook
 */
#define kABAddressBookRegisterExternal  @"ABAddressBookRegisterExternal"
#define kAddressbookTimestamp           @"Addressbook_Timestamp"


/**
 * Version
 */
#define kVersionCache                   @"kVersion"
#define kInitializeAppForNewVersion     @"CurrentVersionOfWeishiForInitialize"

#define kUserDefaultLastCheckUpdate     @"UserDefaultLastCheckUpdate"
#define kUserDefaultUpdateUrl           @"UserDefaultUpdateUrl"

//升级提示
#define kLastUpdateAlertDate            @"LastUpdateAlertDate"
#define kLastUpdateAlertVersion         @"LastUpdateAlertVersion"
#define kSavedServerMsgVersion          @"SavedServerMsgVersion"
#define kSavedServerClearCacheVersion   @"SavedServerClearCacheVersion"

//设置页面新版本信息提醒
#define kUpdateFromSettingMessage       @"update_from_setting_message"
#define kUpdateFromSettingVersion       @"update_from_setting_version"

/**
 * 帮助和引导相关
 */
#define GinChannelShareTips                 @"ChannelShareTips"
#define kGinFriendInfoListControllerYellowTips @"kGinFriendInfoListControllerYellowTips"
#define kTimelineTipsViewKey                @"TimeLineTipsViewKey"
#define kShouldShowInviteContactsNewIcon    @"shoudShowInviteContactsNewIcon"
#define kPhoneBindAlertPopTime              @"PhoneBindAlertPopTime"
#define kPhoneBindAlertCount                @"PhoneBindAlertCount"
#define kBindPopViewShowed2                 @"bindPopViewShowed2"
#define kAlreadyClick4SettingPage           @"already_click_4_setting_page"
#define kShareUserInfoSuccessFlagKey        @"share_user_info_success_flag_key" //分享个人页成功，起泡消失逻辑key
#define kGinShareUserInfoProfileViewControllerCount @"ginShareUserInfoProfileViewControllerCount" //进入详情页的次数
#define kGinRecommendUserInfoProfileViewControllerCount @"GinEnterUserInfoProfileViewControllerCount"
#define khasShowSinaToast                   @"khasShowSinaToast"
#define GinSubscribeTipsKey                    @"SubscribeTips"

//周年
#define kHasEnterAnniversary                 @"hasEnterAnniversary" //是否进入过周年页面
#define kAnniversaryEnable                   @"kAnniversaryEnable"  //周年庆功能是否开启

//视频编辑相关
#define kMVAudioVolumeValue                  @"MVAudioVolumeValue" //音量大小
#define kMVOriginalAudioIsSlient             @"MVOriginalAudioIsSlient" //是否静音
#define kMVLongVideoCodeBitRate             @"longVideoCodeRate" //是否静音

//默认展示页卡
#define kGinDefaultTabType                   @"GinDefaultTab"

//动感影集
#define kPhotoMovieOldTypeAccessed          @"kPhotoMovieOldTypeAccessed"
