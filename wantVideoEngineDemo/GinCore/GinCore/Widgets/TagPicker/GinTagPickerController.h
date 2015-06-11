//
//  GinTagPickerController.h
//  microChannel
//
//  Created by leizhu on 13-7-1.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTopicNameKey @"name"
#define kTopicIdKey @"id"

typedef void (^FinishPickBlock)(NSString *tag, NSDictionary *topic, NSArray *rencentTags, NSArray *recentTopics);

@interface GinTagPickerController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *pickerTableView;
@property (nonatomic, copy) FinishPickBlock finishBlock;

@property (nonatomic, strong) NSMutableArray *hotTagList;
@property (nonatomic, copy) NSString *selectedTag;
@property (nonatomic, strong) NSMutableArray *recentTagList;    //所有历史标签记录

@property(nonatomic,strong) NSArray *topicList; //所有主题
@property(nonatomic,strong) NSDictionary *selectedTopic;//topic是一个dictionary eg. @{@"name":@"someName", @"id":@"someId"}
@property(nonatomic,strong) NSMutableArray *recentTopicList; //所有历史主题记录

//MTA统计需要
- (void)didClickTag;
- (void)didClickTopic;

@end
