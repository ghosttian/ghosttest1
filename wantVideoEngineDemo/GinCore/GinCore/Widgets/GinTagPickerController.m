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
#import "NSString+CharCounter.h"
#import "GinPinyinUtil.h"
#import "GinCommonUIFactory.h"
#import "UIColor+Utils.h"
#import "GinCoreDefines.h"
#import "GinTopicItemView.h"
#import "GinToastTipsView.h"
#import "UIImage+Plus.h"

#define kDeviceWidth ([[UIScreen mainScreen] bounds].size.width)

#define kTagHeaderViewHeight 30
#define kTextViewHeight 44.0
#define kTextViewMargin 10
#define kMaxRecentTags 20       //可保存的最大个数
#define kMaxRecentTagsForShow 10 //可展示的最大个数
#define kSearchTableRowHeight 44.0f
#define kMaxTagLength 20 //标签最大长度

#define kUserDefaultAlreadyUseTopic @"UserDefaultsAlreadyUseTopic"
#define kUserDefaultAlreadyUseTag @"UserDefaultsAlreadyUseTag"

@interface GinTagPickerController () <GinTagFlowViewDataSource, GinTagFlowViewDelegate, UIScrollViewDelegate, UITextFieldDelegate> {
    CGSize lastTextContentSize;
}

@property(nonatomic,strong) GinTagFlowView *hotTagView;
@property(nonatomic,strong) NSMutableArray *recentTags;       //已从selectedTags中排重的标签记录
@property(nonatomic,strong) NSMutableArray *searchResults;
@property(nonatomic,strong) UIBarButtonItem *doneButton;
@property(nonatomic,weak) GinTopicItemView *currentTopicItemView;
@property(nonatomic,strong) CALayer *topLine;

@end

@implementation GinTagPickerController

- (void)dealloc {
    self.selectedTags = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.searchResults = [NSMutableArray array];
        self.recentTags = [NSMutableArray array];
    }
    return self;
}

- (void)setSelectedTags:(NSArray *)selectedTags {
    if (selectedTags == nil) {
        return;
    }
    if (selectedTags != _selectedTags) {
        _selectedTags = selectedTags;
    }
    //从rencentTagList中过滤掉已选择的tag
    for (NSString *recentTag in self.recentTagList) {
        BOOL find = NO;
        for (NSString *selectedTag in selectedTags) {
            if ([selectedTag isEqualToString:recentTag]) {
                find = YES;
                break;
            }
        }
        if (!find) {
            if (self.recentTags.count >= kMaxRecentTagsForShow) {
                break;
            }
            [self.recentTags addObject:recentTag];
        }
    }
}

- (void)loadView {
    [super loadView];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(kTextViewMargin, 0, SCREEN_WIDTH-2*kTextViewMargin, kTextViewHeight)];
    textField.textColor = [UIColor colorWithRGBHex:0xff679191];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = [UIFont systemFontOfSize:16.0f];
    textField.backgroundColor = [UIColor clearColor];
    textField.delegate = self;
    textField.enablesReturnKeyAutomatically = NO;
    textField.returnKeyType = UIReturnKeyDone;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.placeholder = @"请输入标签, 最多10个字";
    [self.view addSubview:textField];
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.textField = textField;
    
    CALayer *topLine = [CALayer layer];
    topLine.backgroundColor = [UIColor colorWithRGBHex:0xffb2dada].CGColor;
    topLine.frame = CGRectMake(0, kTextViewHeight, self.view.frame.size.width, 1.0);
    [self.view.layer addSublayer:topLine];
    self.topLine = topLine;

    
    // Init tableView
    UITableView *searchTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    searchTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    searchTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    searchTable.dataSource = self;
    searchTable.delegate = self;
    searchTable.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:247.0/255.0 alpha:1.0];
    
    self.searchTableView = searchTable;
    //[self.view addSubview:self.tableView];
    
    // Init tagContentView
    UITableView *pickerTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    pickerTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    pickerTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    pickerTable.showsVerticalScrollIndicator = NO;
    pickerTable.dataSource = self;
    pickerTable.delegate = self;
    self.pickerTableView = pickerTable;
    [self.view addSubview:pickerTable];

    GinTagFlowView *hotView = [[GinTagFlowView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    hotView.tagDataSource = self;
    hotView.tagDelegate = self;
    self.hotTagView = hotView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.topLine.frame = CGRectMake(0, kTextViewHeight, self.view.frame.size.width, 1.0);
    
    CGRect tableRect = CGRectMake(0, kTextViewHeight+1.0, SCREEN_WIDTH, self.view.frame.size.height-kTextViewHeight-1.0);
    self.searchTableView.frame = tableRect;
    self.pickerTableView.frame = tableRect;
    
    [self.hotTagView reloadData];
    [self.pickerTableView reloadData];
    [self.searchTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title = @"添加标签";
    self.navigationItem.titleView = [GinCommonUIFactory customTitleViewWithTitle:@"添加标签" image:[UIImage extensionImageNamed:@"tag_ic_tag_nor"]];
    self.view.backgroundColor = [UIColor colorWithRGBHex:0xffd7efef];
    //[self.hotTagView reloadData];
    //[self.pickerTableView reloadData];
	
    //UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView: [GinCommonUIFactory navBarLeftTextButtonWithTitle:@"取消" target:self action:@selector(actionClose)]];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView: [GinCommonUIFactory navBarNormalButtonWithTitle:@"取消" target:self action:@selector(actionClose)]];
    self.navigationItem.leftBarButtonItems = @[left];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:[GinCommonUIFactory navBarRightNormalButtonWithTitle:@"完成" target:self action:@selector(actionDone)]];
    self.navigationItem.rightBarButtonItems = @[right];
    self.doneButton = right;
    self.doneButton.enabled = NO;
    
    [self.hotTagView reloadData];
    
    //选中的tag
    for (GinTagFlowViewItem *item in self.hotTagView.items) {
        if ([self.selectedTags containsObject:item.textLabel.text]) {
            [item setSelected:YES animated:NO];
            self.doneButton.enabled = YES;
            break;
        }
    }
    NSString *selectedTag = [self.selectedTags firstObject];
    if (selectedTag) {
        self.textField.text = selectedTag;
        self.doneButton.enabled = YES;
    }
    
    if (self.selectedTopic) {
        self.doneButton.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if (self.textField.text.length == 0) {
            self.doneButton.enabled = NO;
        }
    }
}

- (void)clearSelectedTags {
    //取消选中的标签
    for (GinTagFlowViewItem *item in self.hotTagView.items) {
        if ([item.textLabel.text isEqualToString:self.textField.text]) {
            [item setSelected:YES animated:NO];
        } else {
            [item setSelected:NO animated:NO];
        }
        //selectedTags 暂未用到，否则需要重置。
    }
}

- (void)quitEditState {
    //返回标签选择状态
    [self.textField resignFirstResponder];
    [self fadeOutView:self.searchTableView];
    [self fadeInView:self.pickerTableView];
}

- (void)actionClose {
    if ([self.textField isFirstResponder]) {
        //还原为之前选中的标签
        for (GinTagFlowViewItem *item in self.hotTagView.items) {
            if (item.isSelected) {
                self.textField.text = item.textLabel.text;
                break;
            }
        }
        [self quitEditState];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)actionDone {
    
    if ([self.textField isFirstResponder]) {
        [self clearSelectedTags];
        [self quitEditState];
    } else {
        if (self.textField.text.length == 0) {
            //没有标签
            BOOL alreadyUseTag = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultAlreadyUseTag];
            if (!alreadyUseTag) {
                //提示可用自定义标签
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultAlreadyUseTag];
                GinToastTipsView *tipsView = [[GinToastTipsView alloc] initWithText:@"您还可以再添加个性标签喔" arrowPosition:ArrowPositionTop arrowPoint:CGPointMake(60, 40)];
                [tipsView showInView:self.view];
                return;
            }
        } else if (self.selectedTopic == nil) {
            //没有主题
            BOOL alreadyUseTopic = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultAlreadyUseTopic];
            if (!alreadyUseTopic) {
                //提示可选择主题
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultAlreadyUseTopic];
                CGFloat offsetY = [self.pickerTableView rectForHeaderInSection:1].origin.y + 5.0;
                GinToastTipsView *tipsView = [[GinToastTipsView alloc] initWithText:@"您还可以添加一个主题标签喔" arrowPosition:ArrowPositionBottom arrowPoint:CGPointMake(60, offsetY)];
                [tipsView showInView:self.pickerTableView];
                return;
            }
        }
        
        BOOL valid = [self tagIsValid:self.textField.text];
        if (!valid) {
            [self showInvalidTagAlert];
            return;
        }
        
        if (self.finishBlock) {
            NSString *tag = nil;
            if (self.textField.text.length > 0) {
                tag = [NSString convertSBC2DBC:self.textField.text];
                if (tag.length > 0) {
                    [self saveTag:tag];
                }
            }
            [self saveTopic:self.selectedTopic];
            
            self.finishBlock(tag, self.selectedTopic, self.recentTagList, self.recentTopicList);
        }
    }
}

- (void)fadeInView:(UIView *)view {
    if (view.superview == nil) {
        view.alpha = 0.0f;
        [self.view addSubview:view];
    }
    [UIView animateWithDuration:.2 animations:^{
        view.alpha = 1.0f;
    }];
}

- (void)fadeOutView:(UIView *)view {
    [UIView animateWithDuration:.2 animations:^{
        view.alpha = 0;
    }];
}

#pragma mark -
#pragma mark UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.pickerTableView) {
        if (self.topicList.count > 0) {
            return 2;
        }
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.pickerTableView) {
        if (section == 0) {
            return 1;
        } else {
            return self.topicList.count/2 + self.topicList.count%2;
        }
    }
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.pickerTableView) {
        if (indexPath.section == 0) {
            static NSString *cellIdentifier = @"TagContainer";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            [cell.contentView addSubview:self.hotTagView];
            return cell;
            
        } else {
            static NSString *cellIdentitfier = @"topicCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentitfier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentitfier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
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
        
    } else {
        static NSString *cellIdentifier = @"TagCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.textColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0];
            cell.textLabel.highlightedTextColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0];
            cell.selectedBackgroundView = [[UIView alloc] init];
            cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
            cell.contentView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:247.0/255.0 alpha:1.0];
            
            CALayer* topLineLayer = [CALayer layer];
            topLineLayer.frame = CGRectMake(0, cell.frame.size.height - 0.5, tableView.frame.size.width, 0.5);
            topLineLayer.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0].CGColor;
            [cell.contentView.layer addSublayer:topLineLayer];
        }
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.pickerTableView) {
        if (indexPath.section == 0) {
            return self.hotTagView.frame.size.height;
        } else {
            return 44.0;
        }
    }
    return kSearchTableRowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.pickerTableView) {
        if (section == 0) {
            return [GinTagSectionHeaderView headerViewWithTitle:@"热门标签"];
        } else {
            UIImage *tipsImage = [UIImage imageNamed:@"g_post_tips_channel"];
            UIView *headerView = [GinTagSectionHeaderView headerViewWithTitle:@"选择主题标签" tipsImage:tipsImage];
            return headerView;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.pickerTableView) {
        return kTagHeaderViewHeight;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row >= self.searchResults.count) {
        return;
    }
    NSString *tag = [self.searchResults objectAtIndex:indexPath.row];
    self.textField.text = tag;
    [self handleTextFieldChange:self.textField];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //[self.textView resignFirstResponder];
    [self.textField resignFirstResponder];
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
        self.textField.text = nil;
    } else {
        NSString *tag = [self.hotTagList objectAtIndex:index];
        //取消选中的标签
        for (GinTagFlowViewItem *item in self.hotTagView.items) {
            if ([item.textLabel.text isEqualToString:tag]) {
                [item setSelected:YES animated:NO];
            } else {
                [item setSelected:NO animated:NO];
            }
            //selectedTags 暂未用到，否则需要重置。
        }
        self.textField.text = tag;
    }
    [self handleTextFieldChange:self.textField];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (UILabel *)searchHeaderView {
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kSearchTableRowHeight)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    return headerLabel;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

    [self fadeOutView:self.pickerTableView];
    [self fadeInView:self.searchTableView];
    
    if (textField.text.length == 0) {
        self.searchTableView.tableHeaderView = nil;
        self.searchResults = [self.recentTags mutableCopy];
        [self.searchTableView reloadData];
    }
}

- (void)handleTextFieldChange:(UITextField *)textField {
    //显示匹配结果
    NSInteger count = [NSString calculateCharCounterForTag:textField.text];
    
    NSMutableArray *newResults = [NSMutableArray array];
    if (count > 0 && count <= kMaxTagLength) {
        
        NSMutableSet *allTags = [NSMutableSet setWithArray:self.hotTagList];
        [allTags addObjectsFromArray:self.recentTagList];
        
        for (NSString *tag in allTags) {
            if (tag.length >= textField.text.length) {
                NSComparisonResult result = [tag compare:textField.text options:NSCaseInsensitiveSearch range:NSMakeRange(0, textField.text.length)];
                if (result != NSOrderedSame) {
                    NSString *pinyin = [GinPinyinUtil convert:tag];
                    if (pinyin.length >= textField.text.length) {
                        NSComparisonResult result2 = [pinyin compare:textField.text options:NSCaseInsensitiveSearch range:NSMakeRange(0, textField.text.length)];
                        if (result2 == NSOrderedSame) {
                            [newResults addObject:tag];
                        }
                    }
                } else {
                    [newResults addObject:tag];
                }
            }
        }
        if (newResults.count > 0) {
            self.searchTableView.tableHeaderView = nil;
            self.searchResults = newResults;
            [self.searchTableView reloadData];
        } else {
            UILabel *headerLabel = [self searchHeaderView];
            headerLabel.text = @"未匹配到结果";
            self.searchTableView.tableHeaderView = headerLabel;
            [self.searchResults removeAllObjects];
            [self.searchTableView reloadData];
        }
        self.doneButton.enabled = YES;
    }
    else if (count == 0) {
        if (!self.selectedTopic) {
            self.doneButton.enabled = NO;
        }
        
        self.searchTableView.tableHeaderView = nil;
        self.searchResults = [self.recentTags mutableCopy];
        [self.searchTableView reloadData];
    } else {
        UILabel *headerLabel = [self searchHeaderView];
        headerLabel.text = @"最多输入10个汉字或20个英文";
        self.searchTableView.tableHeaderView = headerLabel;
        [self.searchResults removeAllObjects];
        [self.searchTableView reloadData];
        self.doneButton.enabled = NO;
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    [self handleTextFieldChange:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger count = [NSString calculateCharCounterForTag:textField.text];
    if (count > kMaxTagLength) {
        [self showInputTooMuchAlert];
        return NO;
    }
    BOOL valid = [self tagIsValid:textField.text];
    if (!valid) {
        [self showInvalidTagAlert];
        return NO;
    }
    [self clearSelectedTags];
    [self quitEditState];
    return YES;
}

- (void)showInputTooMuchAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"最多输入10个汉字或20个英文" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)showInvalidTagAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TagAlertTitle", nil) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
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

#pragma mark -
#pragma mark 检测输入合法性

- (BOOL)tagIsValid:(NSString *)tag {
    if (tag.length == 0) {
        return YES;
    }
    NSString *regex = @"(^[A-Za-z0-9\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [predicate evaluateWithObject:tag];
    return isMatch;
}


#pragma mark -

- (void)didClickTag {}
- (void)didClickTopic {}

@end
