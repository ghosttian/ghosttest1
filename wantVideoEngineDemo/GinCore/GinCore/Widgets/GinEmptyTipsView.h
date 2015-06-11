//
//  GinEmptyTipsView.h
//  microChannel
//
//  Created by leizhu on 14-8-18.
//  Copyright (c) 2014年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _GinEmptyViewStyle{
    GinEmptyViewStyleNoFans=0,
    GinEmptyViewStyleNoiDols,
    GinEmptyViewStyleNoCommentAndShare,
    GinEmptyViewStyleNoMsg,
    GinEmptyViewStyleNoTweet,
    GinEmptyViewStyleNoUserTweet,
    GinEmptyViewStyleNoTweetWithBtn,
    GinEmptyViewStyleNoFavotite,
    GinEmptyViewStyleNoFavoTweets,
    GinEmptyViewStyleNoComment,
    GinEmptyViewStyleNoNewFriend,
    GinEmptyViewStyleNoSearchUser,
    GinEmptyViewStyleNoSearchTag,
    GinEmptyViewStyleNoSearchTweet,
    GinEmptyViewStyleNoRecommendFriends,
    GinEmptyViewStyleAccountNoExit,
    GinEmptyViewStyleDraftNoExit,
    GinEmptyViewStyleNoDynamic,
	GinEmptyViewStyleNoChatMessage,
    GinEmptyViewStyleNoFriendsDynamic,
} GinEmptyViewStyle;


@interface GinEmptyTipsView : UIView

@property(nonatomic,strong) UILabel *textLabel;
@property(nonatomic,strong) UIImageView *imageView;
@property(nonatomic,strong) UIButton *actionButton;

/**
 * topY:图片顶部间隙
 * notice:如果需要使用actionButton,直接通过property访问。
 */
- (instancetype)initWithImage:(UIImage *)image text:(NSString *)text topY:(CGFloat)topY frame:(CGRect)frame;
- (instancetype)initWithImage:(UIImage *)image text:(NSString *)text frame:(CGRect)frame;

+ (GinEmptyTipsView *)emptyTipsViewWithStyle:(GinEmptyViewStyle)style;
+ (GinEmptyTipsView *)emptyTipsViewWithStyle:(GinEmptyViewStyle)style frame:(CGRect)frame;
+ (GinEmptyTipsView *)emptyTipsViewWithStyle:(GinEmptyViewStyle)style frame:(CGRect)frame topY:(CGFloat)topY;

@end
