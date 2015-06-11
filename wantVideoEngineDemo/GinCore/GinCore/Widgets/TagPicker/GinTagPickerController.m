//
//  GinTagPickerController.m
//  microChannel
//
//  Created by leizhu on 13-7-1.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinTagPickerController.h"
#import "GinTagFlowView.h"
#import "GinTagSectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "GinCommonUIFactory.h"
#import "UIColor+Utils.h"
#import "GinCoreDefines.h"
#import "GinTopicItemView.h"
#import "GinToastTipsView.h"
#import "UIImage+Plus.h"
#import "GinCustomTagViewController.h"
#import "GinTagEditButton.h"

#define kDeviceWidth ([[UIScreen mainScreen] bounds].size.width)

#define kTagHeaderViewHeight 30
#define kMaxRecentTags 20       //可保存的最大个数
#define kMaxRecentTagsForShow 10 //可展示的最大个数

#define kUserDefaultAlreadyUseTopic @"UserDefaultsAlreadyUseTopic"
#define kUserDefaultAlreadyUseTag @"UserDefaultsAlreadyUseTag"

@interface GinTagPickerController () <GinTagFlowViewDataSource, GinTagFlowViewDelegate,GinTagFlowItemDelegate, GinCustomTagViewControllerDelegate, UIScrollViewDelegate> {
    CGSize lastTextContentSize;
}

@property(nonatomic,strong) GinTagFlowView *hotTagView;
@property(nonatomic,strong) NSMutableArray *recentTags;       //已从selectedTags中排重的标签记录
@property(nonatomic,strong) UIBarButtonItem *doneButton;
@property(nonatomic,weak) GinTopicItemView *currentTopicItemView;
@property(nonatomic,strong) GinTagEditButton *editButton;

@end

@implementation GinTagPickerController

- (void)dealloc {
    self.selectedTag = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.recentTags = [NSMutableArray array];
    }
    return self;
}

- (void)setSelectedTag:(NSString *)selectedTag {
    if (selectedTag != _selectedTag) {
        _selectedTag = selectedTag;
    }
    if (selectedTag == nil) {
        return;
    }
    //从rencentTagList中过滤掉已选择的tag
    for (NSString *recentTag in self.recentTagList) {

        if (self.recentTags.count >= kMaxRecentTagsForShow) {
            break;
        }
        if (![selectedTag isEqualToString:recentTag]) {
            [self.recentTags addObject:recentTag];
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //CGRect tableRect = CGRectMake(0, kTextViewHeight+1.0, SCREEN_WIDTH, self.view.frame.size.height-kTextViewHeight-1.0);
    //self.pickerTableView.frame = tableRect;
    
    self.editButton.frame = CGRectMake(10, 10, self.view.frame.size.width-20, 30);
    [self.hotTagView reloadData];
    [self.pickerTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    self.navigationItem.titleView = [GinCommonUIFactory customTitleViewWithTitle:@"添加标签" image:[UIImage extensionImageNamed:@"tag_ic_tag_nor"]];
    self.view.backgroundColor = [UIColor colorWithRGBHex:0xffd7efef];

    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView: [GinCommonUIFactory navBarNormalButtonWithTitle:@"取消" target:self action:@selector(actionClose)]];
    self.navigationItem.leftBarButtonItems = @[left];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:[GinCommonUIFactory navBarRightNormalButtonWithTitle:@"完成" target:self action:@selector(actionDone)]];
    self.navigationItem.rightBarButtonItems = @[right];
    self.doneButton = right;
    self.doneButton.enabled = NO;
    
    [self.view addSubview:self.pickerTableView];
    [self.pickerTableView reloadData];
    [self.hotTagView reloadData];
    
    //选中的tag
    if (self.selectedTag.length > 0) {
        BOOL find = NO;
        for (GinTagFlowViewItem *item in self.hotTagView.items) {
            if ([self.selectedTag isEqualToString:item.textLabel.text]) {
                [item setSelected:YES animated:NO];
                self.doneButton.enabled = YES;
                find = YES;
                break;
            }
        }
        if (!find) {
            self.editButton.text = self.selectedTag;
            [self.editButton setSelected:YES animated:NO];
        }
    }

    if (self.selectedTag || self.selectedTopic) {
        self.doneButton.enabled = YES;
    }
}

- (GinTagEditButton *)editButton {
    if (!_editButton) {
        _editButton = [[GinTagEditButton alloc] initWithFrame:CGRectZero];
        _editButton.frame = CGRectMake(10, 10, self.view.frame.size.width-20, 30);
        _editButton.delegate = self;
    }
    return _editButton;
}

- (UITableView *)pickerTableView {
    if (!_pickerTableView) {
        UITableView *pickerTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        pickerTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        pickerTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        pickerTable.showsVerticalScrollIndicator = NO;
        pickerTable.dataSource = self;
        pickerTable.delegate = self;
        _pickerTableView = pickerTable;
    }
    return _pickerTableView;
}

- (GinTagFlowView *)hotTagView {
    if (!_hotTagView) {
        _hotTagView = [[GinTagFlowView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 50)];
        _hotTagView.tagDataSource = self;
        _hotTagView.tagDelegate = self;
    }
    return _hotTagView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deselectCurrentTag {
    //取消选中的标签
    for (GinTagFlowViewItem *item in self.hotTagView.items) {
        if (item.isSelected) {
            [item setSelected:NO animated:NO];
        }
    }
}

#pragma mark -
#pragma mark Private methods

- (void)actionChooseTopic:(GinTopicItemView *)view {
    
    [self didClickTopic];
    
    NSDictionary *topic = [self.topicList objectAtIndex:view.tag];
    view.selected = !view.selected;
    if (view.selected && self.currentTopicItemView != view) {
        self.currentTopicItemView.selected = NO;
        self.currentTopicItemView = view;
    }
    if (view.selected) {
        self.selectedTopic = topic;
        self.doneButton.enabled = YES;
    } else {
        self.selectedTopic = nil;
        if (!self.selectedTag) {
            self.doneButton.enabled = NO;
        }
    }
}

- (void)actionClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionDone {

    if (self.selectedTag == nil) {
        //没有标签
        BOOL alreadyUseTag = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultAlreadyUseTag];
        if (!alreadyUseTag) {
            //提示可用自定义标签
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultAlreadyUseTag];
            GinToastTipsView *tipsView = [[GinToastTipsView alloc] initWithText:@"您还可以再添加个性标签喔" arrowPosition:ArrowPositionTop arrowPoint:CGPointMake(60, 70)];
            [tipsView showInView:self.view];
            return;
        }
    } else {
        if (self.selectedTopic == nil) {
            //没有主题
            BOOL alreadyUseTopic = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultAlreadyUseTopic];
            if (!alreadyUseTopic) {
                //提示可选择主题
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultAlreadyUseTopic];
                NSInteger section = 0;
                if (self.topicList.count > 0) {
                    section = 1;
                }
                CGFloat offsetY = [self.pickerTableView rectForHeaderInSection:section].origin.y + 5.0;
                GinToastTipsView *tipsView = [[GinToastTipsView alloc] initWithText:@"您还可以添加一个主题标签喔" arrowPosition:ArrowPositionBottom arrowPoint:CGPointMake(60, offsetY)];
                [tipsView showInView:self.pickerTableView];
                return;
            }
        }
    }

    if (self.finishBlock) {
        [self saveTag:self.selectedTag];
        [self saveTopic:self.selectedTopic];
        self.finishBlock(self.selectedTag, self.selectedTopic, self.recentTagList, self.recentTopicList);
    }
}

#pragma mark -
#pragma mark UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.topicList.count > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.topicList.count/2 + self.topicList.count%2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"TagContainer";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:self.editButton];
            [cell.contentView addSubview:self.hotTagView];
        }
        if ([self.editButton.text isEqualToString:self.selectedTag]) {
            [self.editButton setSelected:YES animated:NO];
        }
        for (GinTagFlowViewItem *item in self.hotTagView.items) {
            if ([self.selectedTag isEqualToString:item.textLabel.text]) {
                [item setSelected:YES animated:NO];
                break;
            }
        }
        return cell;
        
    } else {
        static NSString *cellIdentitfier = @"topicCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentitfier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentitfier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSString *topicName = nil;
        
        NSInteger leftIndex = indexPath.row * 2;
        topicName = [[self.topicList objectAtIndex:leftIndex] objectForKey:kTopicNameKey];
        GinTopicItemView *leftItem = [[GinTopicItemView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth/2.0, 44)];
        [leftItem setTitle:topicName forState:UIControlStateNormal];
        leftItem.tag = leftIndex;
        [leftItem addTarget:self action:@selector(actionChooseTopic:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:leftItem];
        [leftItem showRightSeperator];
        
        if ([topicName isEqualToString:[self.selectedTopic objectForKey:kTopicNameKey]]) {
            leftItem.selected = YES;
            self.currentTopicItemView = leftItem;
        } else {
            leftItem.selected = NO;
        }
        
        NSInteger rightIndex = indexPath.row * 2 + 1;
        if (rightIndex<self.topicList.count) {
            topicName = [[self.topicList objectAtIndex:rightIndex] objectForKey:kTopicNameKey];
            if (rightIndex < self.topicList.count) {
                UIButton *rightItem = [[GinTopicItemView alloc] initWithFrame:CGRectMake(kDeviceWidth/2.0, 0, kDeviceWidth/2.0, 44)];
                [rightItem setTitle:topicName forState:UIControlStateNormal];
                rightItem.tag = rightIndex;
                [rightItem addTarget:self action:@selector(actionChooseTopic:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:rightItem];
                
                if ([topicName isEqualToString:[self.selectedTopic objectForKey:kTopicNameKey]]) {
                    rightItem.selected = YES;
                    self.currentTopicItemView = leftItem;
                } else {
                    rightItem.selected = NO;
                }
            }
        }
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
        if (indexPath.section == 0) {
            return self.hotTagView.frame.size.height + self.editButton.frame.size.height + 10;
        } else {
            return 44.0;
        }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [GinTagSectionHeaderView headerViewWithTitle:@"个性标签"];
    } else if (section == 1) {
        UIImage *tipsImage = [UIImage extensionImageNamed:@"g_post_tips_channel"];
        UIView *headerView = [GinTagSectionHeaderView headerViewWithTitle:@"主题标签" tipsImage:tipsImage];
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kTagHeaderViewHeight;
}

#pragma mark -
#pragma mark GinTagFlowViewDataSource && GinTagFlowViewDelegate 

- (NSInteger)numberOfItemsInTagFlowView:(GinTagFlowView *)view {
    return self.hotTagList.count;
}

- (GinTagFlowViewItem *)tagFlowView:(GinTagFlowView *)view itemForIndex:(NSInteger)index {
    static NSString *hotIdentifier = @"HotTagIdentifier";

    GinTagFlowViewItem *item = nil;

    if (self.hotTagList.count == 0) {
        return nil;
    }
    item = [view dequeueItemWithReuseIdentifier:hotIdentifier];
    if (!item) {
        item = [[GinTagFlowViewItem alloc] initWithReuseIdentifier:hotIdentifier];
    }
    item.textLabel.text = [self.hotTagList objectAtIndex:index];
    
    return item;
}

- (BOOL)tagFlowView:(GinTagFlowView *)view canEditItemAtIndex:(NSInteger)index {
//    GinTagFlowViewItem *item = [self tagFlowView:view itemForIndex:index];
//    if ([self.selectedTags containsObject:item.textLabel.text]) {
//        return NO;
//    }
    return YES;
}

- (void)tagFlowView:(GinTagFlowView *)view didRemoveItemAtIndex:(NSInteger)index {
    
}

- (void)tagFlowView:(GinTagFlowView *)view didSelectItemAtIndex:(NSInteger)index {
    
    [self didClickTag];
    
    GinTagFlowViewItem *currentItem = [self.hotTagView.items objectAtIndex:index];
    if (currentItem.selected) {
        [currentItem setSelected:NO animated:NO];
        
        self.selectedTag = nil;
        
        if (!self.selectedTopic) {
            self.doneButton.enabled = NO;
        }
    } else {
        NSString *tag = [self.hotTagList objectAtIndex:index];
        //取消选中的其他标签
        for (GinTagFlowViewItem *item in self.hotTagView.items) {
            if ([item.textLabel.text isEqualToString:tag]) {
                [item setSelected:YES animated:NO];
            } else {
                [item setSelected:NO animated:NO];
            }
            //selectedTags 暂未用到，否则需要重置。
        }

        //设置编辑按钮为未选中状态
        [self.editButton setSelected:NO animated:NO];
        self.selectedTag = tag;
        self.doneButton.enabled = YES;
    }
}

#pragma mark -
#pragma mark Recent tags storage

- (void)saveTag:(NSString *)recentTag {
    if (recentTag.length == 0) {
        return;
    }
    for (NSString *tag in self.recentTagList) {
        if ([tag isEqualToString:recentTag]) {
            [self.recentTagList removeObject:tag];
            break;
        }
    }
    [self.recentTagList insertObject:recentTag atIndex:0];
    if (self.recentTagList.count > kMaxRecentTags) {
        [self.recentTagList removeLastObject];
    }
}

- (void)saveTopic:(NSDictionary *)recentTopic {
    if (!recentTopic) {
        return;
    }
    for (NSDictionary *topic in self.recentTopicList) {
        if ([[recentTopic objectForKey:kTopicIdKey] isEqualToString:[topic objectForKey:kTopicIdKey]]) {
            [self.recentTopicList removeObject:topic];
            break;
        }
    }
    [self.recentTopicList insertObject:recentTopic atIndex:0];
}

#pragma mark - GinTagFlowItemDelegate

- (void)didTapOnItem:(GinTagFlowViewItem *)item {
    GinCustomTagViewController *customTagVC = [[GinCustomTagViewController alloc] init];
    customTagVC.delegate = self;
    customTagVC.entryTag = self.selectedTag;
    NSMutableArray *searchTags = [NSMutableArray array]; //只显示最近的4个tag，只包括自定义的。
    NSInteger index = 0;
    for (NSString *recentTag in self.recentTagList) {
        BOOL find = NO;
        for (NSString *hotTag in self.hotTagList) {
            if ([hotTag isEqualToString:recentTag]) {
                find = YES;
                break;
            }
        }
        if (!find) {
            [searchTags addObject:recentTag];
            index ++;
        }
    }
    
    customTagVC.searchHistory = [NSMutableSet setWithArray:searchTags];
    NSInteger count = MIN(4, searchTags.count);
    customTagVC.recentTags = [searchTags subarrayWithRange:NSMakeRange(0, count)];
    if (self.editButton.text.length > 0 && ![self.editButton.text isEqualToString:self.editButton.placeHolder]) {
        customTagVC.defaultText = self.editButton.text;
    }
    [self.navigationController pushViewController:customTagVC animated:YES];
}

- (void)didLongPressOnItem:(GinTagFlowViewItem *)item {
    
}

#pragma mark - GinCustomTagViewControllerDelegate

- (void)didInputCustomTag:(NSString *)tag seletedTag:(NSString *)selectedTag {
    if (tag.length > 0) {
        self.doneButton.enabled = YES;
        self.editButton.text = tag;
        [self.editButton setSelected:YES animated:NO];
        [self deselectCurrentTag];
        self.selectedTag = tag;
    } else {;
        [self.editButton setSelected:NO animated:NO];
        if ([selectedTag isEqualToString:self.editButton.text]) {
            self.selectedTag = nil;
        }
        self.editButton.text = nil;
        if (!self.selectedTopic && !self.selectedTag) {
            self.doneButton.enabled = NO;
        }
    }
}

#pragma mark -

- (void)didClickTag {}
- (void)didClickTopic {}

@end
