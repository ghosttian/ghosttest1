//
//  GinPublishViewController.h
//  GinCore
//
//  Created by leizhu on 14/12/3.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GinPlaceHolderTextView.h"
#import "GinLocationCentre.h"

@interface GinPublishViewController : UIViewController <LocatingCenterDelegate>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UIButton *videoCoverView;
@property(nonatomic,strong) GinPlaceHolderTextView *textView;
@property(nonatomic,strong) UIButton *locationButton;
@property(nonatomic,strong) UILabel *locationLabel;
@property(nonatomic,strong) UIButton *lockButton;

@property(nonatomic,strong) UIBarButtonItem *sendButton;

@property(nonatomic,assign) BOOL showFriendsPickerEntry;
@property(nonatomic,strong) NSArray *friendsNotifyList;
@property(nonatomic,assign) BOOL isPrivate;

@property(nonatomic,strong) NSString *currentTag;
@property(nonatomic,strong) NSString *currentTopicName;
@property(nonatomic,strong) NSString *currentTopicId;

@property(nonatomic,assign) CGFloat latitude;
@property(nonatomic,assign) CGFloat longitude;
@property(nonatomic,strong) NSString *placeString;




//methods for override
- (void)showFriendsPicker;

- (void)actionLocate;
- (void)actionToggleLock;
- (void)actionCancel;
- (void)actionSend;
- (void)actionChooseVideoCover;

@end
