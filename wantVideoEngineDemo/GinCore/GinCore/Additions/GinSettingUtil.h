//
//  GinSettingUtil.h
//  microChannel
//
//  Created by jozeli on 13-6-5.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TABLEVIEW_CELL_ROUND_SIZE                       6
#define kUITableViewCellHieght                          50
#define kUITableViewGroupSectionHeight                  20
#define kUITableViewSeparateHeight                      1
#define kUITableViewHeaderHeight                        50
#define kUITableViewFooterHeight                        80
#define kUITableViewCellMargin                          10
#define kScrollerViewMargin                             10

#define kProfilePageBgImg2Sengemnt                      15
#define kProfilePageSegmentTabHeight                    49
// Update
#define kUserbaseInfoViewHeight                         (228 - (IOSVERSIONISABOVE7 ? 0 : 44))
#define kUserInfoTableHeadViewHeight                    (kUserbaseInfoViewHeight + 60 + 49)

#define kUserHeaderViewOffsetForPlatForm                (IOSVERSIONISABOVE7 ? 64 : 0)

typedef enum{
    kCellViewPositionTop,
    kCellViewPositionMiddle,
    kCellViewPositionBottom,
    kCellViewPositionAlone
}TableCellPosition;


@interface GinSettingUtil : NSObject

+ (UIImage *)imageFromUIColor:(UIColor *)color;

+ (BOOL)isBlankString:(NSString *)string;

+(NSString *)getMd5StrWithOriginString:(NSString *)str time:(NSString *)r;

@end

