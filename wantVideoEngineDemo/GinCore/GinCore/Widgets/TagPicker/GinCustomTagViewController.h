//
//  GinCustomTagViewController.h
//  GinCore
//
//  Created by leizhu on 15/1/16.
//  Copyright (c) 2015年 leizhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GinCustomTagViewControllerDelegate;
@interface GinCustomTagViewController : UIViewController

@property(nonatomic,strong) UITextField *textField;
@property(nonatomic,strong) UITableView *searchTableView;
@property(nonatomic,strong) NSMutableSet *searchHistory;
@property(nonatomic,strong) NSArray *recentTags;
@property(nonatomic,weak) id <GinCustomTagViewControllerDelegate> delegate;
@property(nonatomic,copy) NSString *defaultText;
@property(nonatomic,copy) NSString *entryTag; //进入此页前，已选中的标签。

@end


@protocol GinCustomTagViewControllerDelegate <NSObject>

- (void)didInputCustomTag:(NSString *)tag seletedTag:(NSString *)selectedTag;

@end