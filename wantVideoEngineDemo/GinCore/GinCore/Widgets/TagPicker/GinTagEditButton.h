//
//  GinTagEditButton.h
//  GinCore
//
//  Created by leizhu on 15/1/16.
//  Copyright (c) 2015年 leizhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GinTagFlowViewItem.h"

@interface GinTagEditButton : GinTagFlowViewItem

@property(nonatomic,weak) NSString *text;
@property(nonatomic,strong) NSString *placeHolder;
@end
