//
//  GinCustomTagViewController.m
//  GinCore
//
//  Created by leizhu on 15/1/16.
//  Copyright (c) 2015年 leizhu. All rights reserved.
//

#import "GinCustomTagViewController.h"
#import "UIColor+Utils.h"
#import "GinCommonUIFactory.h"
#import "NSString+CharCounter.h"
#import "GinPinyinUtil.h"
#import "UIImage+Plus.h"

#define kTextViewHeight 30.0
#define kTextViewMargin 7.5
#define kSearchTableRowHeight 44.0f
#define kMaxTagLength 20 //标签最大长度

@interface GinCustomTagViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property(nonatomic,strong) NSMutableArray *searchResults;
@property(nonatomic,strong) UIBarButtonItem *doneButton;

@end

@implementation GinCustomTagViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.searchResults = [NSMutableArray array];
    }
    return self;
}

- (BOOL)isSupportSwipePop {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    self.navigationItem.titleView = [GinCommonUIFactory customTitleViewWithTitle:@"添加个性标签" image:[UIImage extensionImageNamed:@"tag_ic_tag_nor"]];
    self.view.backgroundColor = [UIColor colorWithRGBHex:0xffededed];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView: [GinCommonUIFactory navBarNormalButtonWithTitle:@"取消" target:self action:@selector(actionClose)]];
    self.navigationItem.leftBarButtonItems = @[left];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:[GinCommonUIFactory navBarRightNormalButtonWithTitle:@"完成" target:self action:@selector(actionDone)]];
    self.navigationItem.rightBarButtonItems = @[right];
    self.doneButton.enabled = NO;

    
    UIView *textBgView = [[UIView alloc] initWithFrame:CGRectMake(kTextViewMargin, kTextViewMargin, self.view.frame.size.width-2*kTextViewMargin, kTextViewHeight)];
    textBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textBgView.backgroundColor = [UIColor whiteColor];
    textBgView.layer.borderColor = [UIColor colorWithRGBHex:0xffdddddd].CGColor;
    textBgView.layer.borderWidth = 1.0;
    textBgView.layer.cornerRadius = 5.0;
    textBgView.layer.masksToBounds = YES;
    [self.view addSubview:textBgView];
    
    [self.view addSubview:self.textField];
    if (self.defaultText) {
        self.textField.text = self.defaultText;
    }
    
    // Init tableView
    UITableView *searchTable = [[UITableView alloc] initWithFrame:CGRectMake(0, kTextViewMargin*2+kTextViewHeight, self.view.frame.size.width, self.view.frame.size.height-kTextViewMargin*2-kTextViewHeight) style:UITableViewStylePlain];
    searchTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    searchTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    searchTable.dataSource = self;
    searchTable.delegate = self;
    searchTable.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:247.0/255.0 alpha:1.0];
    
    self.searchTableView = searchTable;
    [self.view addSubview:self.searchTableView];
    
    [self.textField becomeFirstResponder];
}

- (UITextField *)textField {
    if (!_textField) {
        CGRect rect = CGRectMake(kTextViewMargin, kTextViewMargin, self.view.frame.size.width-2*kTextViewMargin, kTextViewHeight);
        _textField = [[UITextField alloc] initWithFrame:CGRectInset(rect, 10, 0)];
        _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _textField.textColor = [UIColor colorWithRGBHex:0xff949494];
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.font = [UIFont systemFontOfSize:14.0f];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.delegate = self;
        _textField.enablesReturnKeyAutomatically = NO;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.keyboardType = UIKeyboardTypeDefault;
        _textField.placeholder = @"请输入标签, 最多10个字";
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionClose {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionDone {
    BOOL valid = [self tagIsValid:self.textField.text];
    if (!valid) {
        [self showInvalidTagAlert];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(didInputCustomTag:seletedTag:)]) {
        [self.delegate didInputCustomTag:self.textField.text seletedTag:self.entryTag];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSearchTableRowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.searchResults.count) {
        return;
    }
    NSString *tag = [self.searchResults objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(didInputCustomTag:seletedTag:)]) {
        [self.delegate didInputCustomTag:tag seletedTag:self.entryTag];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.text.length == 0) {
        self.searchTableView.tableHeaderView = nil;
        self.searchResults =  [self.recentTags mutableCopy];
        [self.searchTableView reloadData];
    }
}

- (void)handleTextFieldChange:(UITextField *)textField {
    //显示匹配结果
    NSInteger count = [NSString calculateCharCounterForTag:textField.text];
    
    NSMutableArray *newResults = [NSMutableArray array];
    if (count > 0 && count <= kMaxTagLength) {
        
        for (NSString *tag in self.searchHistory) {
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

    if ([self.delegate respondsToSelector:@selector(didInputCustomTag:seletedTag:)]) {
        [self.delegate didInputCustomTag:self.textField.text seletedTag:self.entryTag];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    return NO;
}

#pragma mark - Private methods

- (BOOL)tagIsValid:(NSString *)tag {
    if (tag.length == 0) {
        return YES;
    }
    NSString *regex = @"(^[A-Za-z0-9\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [predicate evaluateWithObject:tag];
    return isMatch;
}

- (UILabel *)searchHeaderView {
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kSearchTableRowHeight)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    return headerLabel;
}

- (void)showInputTooMuchAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"最多输入10个汉字或20个英文" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)showInvalidTagAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TagAlertTitle", nil) message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end
