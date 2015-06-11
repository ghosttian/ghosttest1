//
//  GinTagsView.h
//  microChannel
//
//  Created by leizhu on 13-7-18.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GinTagsView : UIView

@property (nonatomic,assign) UIEdgeInsets edgeInsets;
@property (nonatomic,strong) NSArray *tags;
@property (nonatomic,copy) void (^clickBlock)(NSString *tag);

+ (CGFloat)heightForTags:(NSArray *)tags;

@end
