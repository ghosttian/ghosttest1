//
//  UITableView+Settings.m
//  microChannel
//
//  Created by leizhu on 13-7-21.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "UITableView+Settings.h"
#import <QuartzCore/QuartzCore.h>

@implementation UITableView (Settings)

- (TableCellPosition)tableCellPosition:(NSInteger)row rowSection:(NSInteger)rowSection
{
    TableCellPosition position = kCellViewPositionAlone;
    
    NSInteger sectionRow = [self numberOfRowsInSection:rowSection];
    
    if(sectionRow == 1){
        position = kCellViewPositionAlone;
    } else if(sectionRow > 1){
        if (row == 0){
            position = kCellViewPositionTop;
        } else if (row == sectionRow - 1){
            position = kCellViewPositionBottom;
        } else {
            position = kCellViewPositionMiddle;
        }
    } else {
        position = kCellViewPositionAlone;
    }
    
    return position;
}

@end
