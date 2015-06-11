//
//  UITableView+Settings.h
//  microChannel
//
//  Created by leizhu on 13-7-21.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GinSettingUtil.h"

@interface UITableView (Settings)

- (TableCellPosition)tableCellPosition:(NSInteger)row rowSection:(NSInteger)rowSection;

@end
