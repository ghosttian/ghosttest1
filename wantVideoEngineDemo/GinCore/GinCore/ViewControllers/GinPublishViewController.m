//
//  GinPublishViewController.m
//  GinCore
//
//  Created by leizhu on 14/12/3.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import "GinPublishViewController.h"
#import "UIColor+Utils.h"
#import "GinEmojiPickerView.h"
#import "GinTagPickerController.h"
#import "UIImage+Plus.h"
#import "NSString+CharCounter.h"
#import "MicroVideoNetworkImp.h"
#import "GinCommonUIFactory.h"
#import "GinPublishTagCell.h"

#define kVideoCoverSize 66.0
#define kPaddingLeft 15.0
#define kHeadHeight 136.0
#define kToolbarHeight 44.0
#define kIconSize 30.0
#define kLockButtonPadding 2.0

@interface GinPublishViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, GinEmojiPickerViewDelegate>

@property(nonatomic,strong) GinEmojiPickerView *emojiView;
@property(nonatomic,strong) UIButton *emojiButton;
@property(nonatomic,strong) UILabel *countLabel;

@property(nonatomic,strong) NSMutableArray *hotTags;
@property(nonatomic,strong) NSMutableArray *hotTopics;

@end

@implementation GinPublishViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [MicroVideoNetworkImp getHotTagsWithSuccess:^(id result) {
            NSArray *tags = [result objectForKey:@"hottags"];
            NSArray *topics = [result objectForKey:@"writetopics"];
            if (tags.count > 0) {
                self.hotTags = [NSMutableArray arrayWithArray:tags];
            }
            if (topics.count > 0) {
                self.hotTopics = [NSMutableArray arrayWithArray:topics];
            }
    
        } fail:^(NSError *error) {
            
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"发表微视";
    
    self.tableView.backgroundColor = [UIColor colorWithRGBHex:0xffeaeaea alpha:1.0];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[GinPublishTagCell class] forCellReuseIdentifier:@"TagCell"];
    
    UIButton *cancelButton = [GinCommonUIFactory navBarBackButtonWithTitle:@"取消"];
    [cancelButton addTarget:self action:@selector(actionCancel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    UIButton *sendButton = [GinCommonUIFactory navBarRightNormalButtonWithTitle:@"发送" target:self action:@selector(actionSend)];
    self.sendButton = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    self.navigationItem.rightBarButtonItem = self.sendButton;
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    countLabel.font = [UIFont systemFontOfSize:14.0];
    countLabel.textColor = [UIColor redColor];
    countLabel.text = @"";
    countLabel.textAlignment = NSTextAlignmentRight;
    self.countLabel = countLabel;
    UIBarButtonItem *countItem = [[UIBarButtonItem alloc] initWithCustomView:countLabel];
    
    self.navigationItem.rightBarButtonItems = @[self.sendButton, countItem];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
  
    if (self.emojiView.superview) {
        self.emojiView.frame = CGRectMake(0, self.view.frame.size.height-self.emojiView.frame.size.height, self.view.frame.size.width, 216);
        [self.emojiView relayoutEmojiView];
    }
    self.lockButton.frame = CGRectMake(self.view.frame.size.width-10-kIconSize, kHeadHeight-kIconSize-5.0, kIconSize+4, kIconSize);
    self.textView.frame = CGRectMake(kPaddingLeft+kVideoCoverSize+10, 5, self.view.frame.size.width-(kPaddingLeft+kVideoCoverSize+10)-10, 90);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isPrivate {
    return self.lockButton.selected;
}

- (void)setIsPrivate:(BOOL)isPrivate {
    self.lockButton.selected = isPrivate;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (GinEmojiPickerView *)emojiView {
    if (!_emojiView) {
        _emojiView = [[GinEmojiPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216)];
        _emojiView.delegate = self;
        _emojiView.hideSendButton = YES;
    }
    return _emojiView;
}

- (UIButton *)videoCoverView {
    if (!_videoCoverView) {
        _videoCoverView = [[UIButton alloc] initWithFrame:CGRectMake(kPaddingLeft, kPaddingLeft, kVideoCoverSize, kVideoCoverSize)];
        //TODO subview
        [_videoCoverView addTarget:self action:@selector(actionChooseVideoCover) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoCoverView;
}

- (GinPlaceHolderTextView *)textView {
    if (!_textView) {
        _textView = [[GinPlaceHolderTextView alloc] initWithFrame:CGRectZero];
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.realTextColor = [UIColor colorWithRGBHex:0xff333333 alpha:1.0];
        _textView.placeholder = @"描述下这个视频吧...";
        _textView.placeholderColor = [UIColor colorWithRGBHex:0xffaaaaaa alpha:1.0];
    }
    return _textView;
}

- (UIButton *)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emojiButton setImage:[UIImage extensionImageNamed:@"write_icon_emoticon"] forState:UIControlStateNormal];
        [_emojiButton addTarget:self action:@selector(actionToggleEmojiView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiButton;
}

- (UIButton *)locationButton {
    if (!_locationButton) {
        _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locationButton setImage:[UIImage extensionImageNamed:@"write_icon_lbs"] forState:UIControlStateNormal];
        [_locationButton addTarget:self action:@selector(actionLocate) forControlEvents:UIControlEventTouchUpInside];
    }
    return _locationButton;
}

- (UILabel *)locationLabel {
    if (!_locationLabel) {
        _locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _locationLabel.font = [UIFont systemFontOfSize:14.0];
        _locationLabel.textColor = [UIColor blackColor];
    }
    return _locationLabel;
}

- (UIButton *)lockButton {
    if (!_lockButton) {
        _lockButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_lockButton setTitleColor:[UIColor colorWithRGBHex:0xff888888 alpha:1.0] forState:UIControlStateNormal];
        [_lockButton setTitleColor:[UIColor colorWithRGBHex:0xfff87e31 alpha:1.0] forState:UIControlStateSelected];
        [_lockButton setImage:[UIImage extensionImageNamed:@"write_icon_public"] forState:UIControlStateNormal];
        [_lockButton setImage:[UIImage extensionImageNamed:@"write_icon_notpublic"] forState:UIControlStateSelected];
        [_lockButton setTitle:@"" forState:UIControlStateNormal];
        [_lockButton setTitle:@"不公开" forState:UIControlStateSelected];
        [_lockButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, kLockButtonPadding)];
        [_lockButton setTitleEdgeInsets:UIEdgeInsetsMake(0, kLockButtonPadding, 0, 0)];
        _lockButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_lockButton addTarget:self action:@selector(actionToggleLock) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lockButton;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = 1;
            break;
        case 1:
            if (self.showFriendsPickerEntry) {
                count = 2;
            } else {
                count = 1;
            }
            break;
        default:
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case 0: {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor colorWithRGBHex:0xfff3f3f3 alpha:1.0];
            
            [cell.contentView addSubview:self.videoCoverView];
            [cell.contentView addSubview:self.textView];
            [cell.contentView addSubview:self.emojiButton];
            [cell.contentView addSubview:self.locationButton];
            [cell.contentView addSubview:self.locationLabel];
            [cell.contentView addSubview:self.lockButton];
            
            CGFloat offsetX = 10.0;
            CGFloat offsetY = kHeadHeight - kIconSize - 5.0;
            self.emojiButton.frame = CGRectMake(offsetX, offsetY, kIconSize, kIconSize);
            offsetX += kIconSize + 12.0;
            self.locationButton.frame = CGRectMake(offsetX, offsetY, kIconSize, kIconSize);
            offsetX += kIconSize;
            self.locationLabel.frame = CGRectMake(offsetX, offsetY, 145.0, kIconSize);
            
            CALayer *line = [CALayer layer];
            line.frame = CGRectMake(0, kHeadHeight - 1, self.view.frame.size.width, 1);
            line.backgroundColor = [UIColor colorWithRGBHex:0xffe0e0df alpha:1.0].CGColor;
            [cell.contentView.layer addSublayer:line];
            
            return cell;
            break;
        }
        case 1: {

            GinPublishTagCell *cell = nil;
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"TagCell"];
                cell.currentTag = self.currentTag;
                cell.currentTopic = self.currentTopicName;
                [cell.closeButton addTarget:self action:@selector(actionClearTag) forControlEvents:UIControlEventTouchUpInside];
            }
      
//            } else {
//                cell.imageView.image = [UIImage extensionImageNamed:@"g_icon_people"];
//                cell.textLabel.text = @"提醒好友";
//                NSString *text = nil;
//                if (self.friendsNotifyList.count > 0) {
//                    text = [NSString stringWithFormat:@"已提醒%lu位好友", (unsigned long)self.friendsNotifyList.count];
//                } else {
//                    if (self.isPrivate) {
//                        text = @"(仅被提醒的好友可见)";
//                    } else {
//                        text = @"(好友仅限互相关注)";
//                    }
//                }
//                cell.detailTextLabel.text = text;
//            }
    
            return cell;
            break;
        }
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    switch (indexPath.section) {
        case 0:
            height = kHeadHeight;
            break;
        case 1:
            height = 44.0;
            break;
        default:
            break;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 22.0f;
    }
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            //标签
            GinTagPickerController *tagPicker = [[GinTagPickerController alloc] init];
            if (self.hotTags.count) {
                tagPicker.hotTagList = self.hotTags;
            } else {
                NSArray *tags = @[@"自拍", @"美食", @"旅行", @"萌物", @"宝宝", @"恶搞", @"汪星人", @"喵星人", @"喵了个咪", @"味道", @"在路上", @"心情", @"风景", @"亲子", @"K歌", @"搞怪"];
                tagPicker.hotTagList = [NSMutableArray arrayWithArray:tags];
            }
            if (self.hotTopics.count) {
                tagPicker.topicList = self.hotTopics;
            }
//            } else {
//                self.hotTopics = [NSMutableArray arrayWithArray:@[
//                                                                  @{@"id":@"01", @"name":@"自拍"},
//                                                                  @{@"id":@"02", @"name":@"美食"},
//                                                                  @{@"id":@"03", @"name":@"旅行"},
//                                                                  @{@"id":@"04", @"name":@"萌物"},
//                                                                  @{@"id":@"05", @"name":@"宝宝"}]];
//                tagPicker.topicList = self.hotTopics;
//            }
            [self.textView resignFirstResponder];
            tagPicker.finishBlock = ^(NSString *theTag, NSDictionary *topic, NSArray *recentTags, NSArray *recentTopics) {
        
                self.currentTag = [theTag copy];
                if (topic) {
                    self.currentTopicId = [topic objectForKey:kTopicIdKey];
                    self.currentTopicName = [topic objectForKey:kTopicNameKey];
                } else {
                    self.currentTopicId = nil;
                    self.currentTopicName = nil;
                }
                [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
                
                [self dismissViewControllerAnimated:YES completion:nil];

            };
            
            if (self.currentTag) {
                tagPicker.selectedTag = [self.currentTag copy];
            }
            if (self.currentTopicId && self.currentTopicName) {
                tagPicker.selectedTopic = @{@"id":[self.currentTopicId copy], @"name":[self.currentTopicName copy]};
            }
            UINavigationController *topicNav = [[UINavigationController alloc] initWithRootViewController:tagPicker];
            [GinCommonUIFactory setNavigationBarApperanceForExtension:topicNav.navigationBar];
            [self presentViewController:topicNav animated:YES completion:nil];

        } else if (indexPath.row == 1) {
            //好友
            [self showFriendsPicker];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.emojiView.superview) {
        [self showEmojiView:NO];
        [self.emojiView removeFromSuperview];
    }
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.emojiButton setImage:[UIImage extensionImageNamed:@"write_icon_emoticon"] forState:UIControlStateNormal];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView.selectedRange.location >= textView.text.length) {
        [textView scrollRangeToVisible:NSMakeRange([textView.text length]-1, 1)];
    }
    
    NSInteger count = [NSString calculateCharCounterFor:textView.text];
    if (count > 280) {
        self.sendButton.enabled = NO;
        self.countLabel.text = [NSString stringWithFormat:@"-%d", (int)floor((count-280)/2)];
    } else {
        self.sendButton.enabled = YES;
        self.countLabel.text = @"";
    }
}

#pragma mark - GinEmojiPickerViewDelegate

- (void)emojiPickerView:(GinEmojiPickerView *)view didPickEmoji:(NSString *)emojiSymbol {
    NSUInteger location = _textView.selectedRange.location;
    NSString *content = _textView.text;
    NSString* prefix = nil;
    if (location <= content.length) {
        prefix = [content substringToIndex:location];
    }
    
    NSString *tailStr = nil;
    if (location < content.length) {
        tailStr = [content substringFromIndex:location];
    }
    
    NSString *result = nil;
    if (prefix) {
        result = prefix;
    }
    if (emojiSymbol) {
        if (result) {
            result = [NSString stringWithFormat:@"%@%@", result, emojiSymbol];
        }else{
            result = emojiSymbol;
        }
    }
    if (tailStr) {
        result = [NSString stringWithFormat:@"%@%@", result, tailStr];
        
    }
    _textView.text = result;
    _textView.selectedRange = NSMakeRange([prefix length] + [emojiSymbol length], 0);
    //[self textViewDidChange:self.textView];
}

- (void)emojiPickerViewDidTapDeleteButton:(GinEmojiPickerView *)view {
    NSUInteger location = _textView.selectedRange.location;
    NSString *content = _textView.text;
    NSString* prefix = nil;
    if (location <= content.length) {
        prefix = [content substringToIndex:location];
    }
    
    NSRange range = [prefix rangeOfString:@"/" options:NSBackwardsSearch];
    if(range.length > 0){
        NSString *temp = [prefix substringFromIndex:range.location];
        if([self.emojiView.emojSymbols containsObject:temp]){
            NSString *result = [NSString stringWithFormat:@"%@%@",[prefix substringToIndex:range.location], [content substringFromIndex:location]];
            _textView.text = result;
            _textView.selectedRange = NSMakeRange(location - temp.length, 0);
            //[self textViewDidChange:self.textView];
        } else {
            if (prefix.length > 0) {
                _textView.text = [prefix substringToIndex:prefix.length-1];
                _textView.selectedRange = NSMakeRange(prefix.length-1, 0);
            }
        }
    } else {
        if (prefix.length > 0) {
            _textView.text = [prefix substringToIndex:prefix.length-1];
            _textView.selectedRange = NSMakeRange(prefix.length-1, 0);
        }
    }
    
}

#pragma mark - Action methods

- (void)actionCancel {
    
}

- (void)actionSend {

}

- (void)actionClearTag {
    self.currentTag = nil;
    self.currentTopicId = nil;
    self.currentTopicName = nil;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)actionChooseVideoCover {
    
}

- (void)actionToggleEmojiView {
    if (!self.emojiView.superview) {
        [self.view addSubview:self.emojiView];
        
        [self showEmojiView:YES];
        [self.textView resignFirstResponder];
        return;
    }
    
    if (!self.textView.isFirstResponder) {
        [self showEmojiView:NO];
        [self.textView becomeFirstResponder];
    } else {
        [self showEmojiView:YES];
        [self.textView resignFirstResponder];
    }
}

- (void)showEmojiView:(BOOL)show {
    if (show) {
        [self.emojiButton setImage:[UIImage extensionImageNamed:@"write_icon_keyboard"] forState:UIControlStateNormal];
        [UIView animateWithDuration:.25 animations:^{
            self.emojiView.frame = CGRectMake(0, self.view.frame.size.height - 216, self.emojiView.frame.size.width, self.emojiView.frame.size.height);
        }];
    } else {
        [self.emojiButton setImage:[UIImage extensionImageNamed:@"write_icon_emoticon"] forState:UIControlStateNormal];
        [UIView animateWithDuration:.25 animations:^{
            self.emojiView.frame = CGRectMake(0, self.view.frame.size.height, self.emojiView.frame.size.width, self.emojiView.frame.size.height);
        }];
    }
}

- (void)actionToggleLock {
    self.lockButton.selected = !self.lockButton.selected;
    CGFloat width = 0;
    if (self.lockButton.selected) {
        //不公开
        width = kIconSize+kLockButtonPadding+50;
    } else {
        //公开
        width = kIconSize+kLockButtonPadding;
    }
    self.lockButton.frame = CGRectMake(self.view.frame.size.width-10-width, kHeadHeight-kIconSize-5.0, width, kIconSize);
    [self.tableView reloadData];
}

- (void)actionLocate {
    if (self.locationButton.selected) {
        self.locationLabel.text = nil;
    } else {
        if (self.placeString == nil) {
            self.locationLabel.text = @"定位中...";
            self.locationButton.userInteractionEnabled = NO;
            [[GinLocationCentre sharedInstance] runRoutineLocating:self];
        } else {
            self.locationLabel.text = self.placeString;
        }
    }
    self.locationButton.selected = !self.locationButton.selected;
}


#pragma mark - LocatingCenterDelegate

- (void)didLocatingSuccess:(CLLocation *)location {
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;
    NSDictionary * params = @{@"latitude":@(self.latitude), @"longitude":@(self.longitude)};
    [MicroVideoNetworkImp getLbsInfo:params success:^(NSString *placeString) {
        self.placeString = placeString;
        self.locationLabel.text = placeString;
        self.locationButton.userInteractionEnabled = YES;
    } fail:^(NSError *error) {
        self.locationLabel.text = @"定位失败";
        self.locationButton.userInteractionEnabled = YES;
    }];
}

- (void)didLocatingFail {
    self.locationLabel.text = @"定位失败";
    self.locationButton.userInteractionEnabled = YES;
}

- (void)didGetLocation:(NSString *)msg loction:(NSString *)placemark {
    
}

#pragma mark - methods for override

- (void)showFriendsPicker {
    
}

@end
