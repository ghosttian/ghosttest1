//
//  GinEmptyTipsView.m
//  microChannel
//
//  Created by leizhu on 14-8-18.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import "GinEmptyTipsView.h"
#import "GinCoreDefines.h"
#import "UIColor+Utils.h"
#import "UIView+Addtion.h"

#define kDefaultTopMargin 80.0

#define Empty_Image_NoFans @"g_pic_blank_fans"
#define Empty_Image_NoTag  @"g_pic_blank_tag"
#define Empty_Image_NoCommentAndShare @"g_pic_blank_comment"
#define Empty_Image_NoMsg @"g_pic_blank_comment"
#define Empty_Image_NoTweet @"g_pic_blank_video"
#define Empty_Image_NoTweetWithBtn @"g_pic_blank_video"
#define Empty_Image_NoFavotite @"g_pic_blank_fans"
#define Empty_Image_NoComment @"g_pic_blank_comment"
#define Empty_Image_NoChatMessage @"g_pic_blank_letter"
#define Empty_Image_NoFriendsDynamic @"g_pic_blank_comment"

#define Empty_Text_NoFans @"暂无粉丝，让朋友们来关注你吧"
#define Empty_Text_NoNewFriend  @"暂无新朋友"
#define Empty_Text_NoSearchUser  @"暂无相关用户"
#define Empty_Text_NoSearchTag  @"暂无相关标签"
#define Empty_Text_NoSearchTweet  @"暂无相关微视"
#define Empty_Text_NoiDols @"暂无关注"
#define Empty_Text_NoCommentAndShare @"暂无转播/评论"
#define Empty_Text_NoMsg @"暂无消息"
#define Empty_Text_NoTweet @"暂无微视"
#define Empty_Text_NoTweetWithBtn @"暂无微视"
#define Empty_Text_NoFavotite @"没有赞过的人"
#define Empty_Text_NoFavoTweets @"还没有赞过任何微视"
#define Empty_Text_NoComment @"暂无评论"
#define Empty_Text_Developing @"开发中..."
#define Empty_Text_NoRecommendFriend @"暂无推荐关注"
#define Empty_Text_NoDraftExit @"暂无草稿"
#define Empty_Text_NoDynamic  @"暂无转发"
#define Empty_Text_NoChatMessage @"开始发一条私信吧"
#define Empty_Text_NoFriendsDynamic @"暂无好友动态"

@implementation GinEmptyTipsView

- (instancetype)initWithImage:(UIImage *)image text:(NSString *)text topY:(CGFloat)topY frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:229/255.f green:229/255.f blue:229/255.f alpha:1.0f];
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.frame = CGRectMake((SCREEN_WIDTH-image.size.width)/2.0, topY, image.size.width, image.size.height);
        [self addSubview:_imageView];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.text = text;
        _textLabel.font = [UIFont systemFontOfSize:14.0];
        _textLabel.textColor = [UIColor colorWithRGBHex:0xff888888 alpha:1.0];
        _textLabel.backgroundColor = [UIColor clearColor];
        [_textLabel sizeToFit];
        _textLabel.origin = CGPointMake((SCREEN_WIDTH-_textLabel.width)/2.0, _imageView.ginBottom + 15.0);
        [self addSubview:_textLabel];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image text:(NSString *)text frame:(CGRect)frame {
    return [self initWithImage:image text:text topY:kDefaultTopMargin frame:frame];
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-90)/2.0, _textLabel.ginBottom + 17.0, 90, 30)];
        [_actionButton setBackgroundImage:[[UIImage imageNamed:@"g_button_lose_nor"] stretchableImageWithLeftCapWidth:8 topCapHeight:15] forState:UIControlStateNormal];
        [_actionButton setBackgroundImage:[[UIImage imageNamed:@"g_button_lose_press"] stretchableImageWithLeftCapWidth:8 topCapHeight:15] forState:UIControlStateHighlighted];
        [_actionButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_actionButton setTitleColor:[UIColor colorWithRGBHex:0xff00bbbb alpha:1.0] forState:UIControlStateNormal];
        [self addSubview:_actionButton];
    }
    return _actionButton;
}

+ (GinEmptyTipsView *)emptyTipsViewWithStyle:(GinEmptyViewStyle)style {
    return [[self class] emptyTipsViewWithStyle:style frame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) topY:kDefaultTopMargin];
}

+ (GinEmptyTipsView *)emptyTipsViewWithStyle:(GinEmptyViewStyle)style frame:(CGRect)frame {
    return [[self class] emptyTipsViewWithStyle:style frame:frame topY:kDefaultTopMargin];
}

+ (GinEmptyTipsView *)emptyTipsViewWithStyle:(GinEmptyViewStyle)style frame:(CGRect)frame topY:(CGFloat)topY {
    GinEmptyTipsView *tipsView = nil;
    NSString *imageName = nil;
    NSString *text = nil;
    switch (style) {
        case GinEmptyViewStyleNoFans: {
            imageName = Empty_Image_NoFans;
            text = Empty_Text_NoFans;
            break;
        }
        case GinEmptyViewStyleNoiDols: {
            imageName = Empty_Image_NoFans;
            text = Empty_Text_NoiDols;
            break;
        }
        case GinEmptyViewStyleNoCommentAndShare: {
            imageName = Empty_Image_NoCommentAndShare;
            text = Empty_Text_NoCommentAndShare;
            break;
        }
        case GinEmptyViewStyleNoMsg: {
            imageName = Empty_Image_NoMsg;
            text = Empty_Text_NoMsg;
            break;
        }
        case GinEmptyViewStyleNoTweet: {
            imageName = Empty_Image_NoTweet;
            text = Empty_Text_NoTweet;
            break;
        }
        case GinEmptyViewStyleNoUserTweet: {
            imageName = Empty_Image_NoTweet;
            text = Empty_Text_NoTweet;
            break;
        }
        case GinEmptyViewStyleNoTweetWithBtn: {
            imageName = Empty_Image_NoTweetWithBtn;
            text = Empty_Text_NoTweetWithBtn;
            break;
        }
        case GinEmptyViewStyleNoFavotite: {
            imageName = Empty_Image_NoFavotite;
            text = Empty_Text_NoFavotite;
            break;
        }
        case GinEmptyViewStyleNoFavoTweets: {
            imageName = Empty_Image_NoTweetWithBtn;
            text = Empty_Text_NoFavoTweets;
            break;
        }
        case GinEmptyViewStyleNoComment: {
            imageName = Empty_Image_NoComment;
            text = Empty_Text_NoComment;
            break;
        }
        case GinEmptyViewStyleNoNewFriend: {
            imageName = Empty_Image_NoFans;
            text = Empty_Text_NoNewFriend;
            break;
        }
        case GinEmptyViewStyleNoSearchUser: {
            imageName = Empty_Image_NoFans;
            text = Empty_Text_NoSearchUser;
            break;
        }
        case GinEmptyViewStyleNoSearchTag: {
            imageName = Empty_Image_NoTag;
            text = Empty_Text_NoSearchTag;
            break;
        }
        case GinEmptyViewStyleNoSearchTweet: {
            imageName = Empty_Image_NoTweet;
            text = Empty_Text_NoSearchTweet;
            break;
        }
        case GinEmptyViewStyleNoRecommendFriends: {
            imageName = Empty_Image_NoFans;
            text = Empty_Text_NoRecommendFriend;
            break;
        }
        case GinEmptyViewStyleAccountNoExit: {
            imageName = Empty_Image_NoFans;
            text = NSLocalizedString(@"AccountNoExist", nil);
            break;
        }
        case GinEmptyViewStyleDraftNoExit: {
            imageName = Empty_Image_NoTweet;
            text = Empty_Text_NoDraftExit;
            break;
        }
        case GinEmptyViewStyleNoDynamic: {
            imageName = Empty_Image_NoTweet;
            text = Empty_Text_NoDynamic;
            break;
        }
        case GinEmptyViewStyleNoChatMessage: {
            imageName = Empty_Image_NoChatMessage;
            text = Empty_Text_NoChatMessage;
            break;
        }
        case GinEmptyViewStyleNoFriendsDynamic: {
            imageName = Empty_Image_NoFriendsDynamic;
            text = Empty_Text_NoFriendsDynamic;
            break;
        }
        default:
            break;
    }
    tipsView = [[GinEmptyTipsView alloc] initWithImage:[UIImage imageNamed:imageName] text:text topY:topY frame:frame];
    return tipsView;
}

@end
