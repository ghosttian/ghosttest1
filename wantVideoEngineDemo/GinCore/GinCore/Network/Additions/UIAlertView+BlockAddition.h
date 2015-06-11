//
//  UIAlertView+BlockAddition.h
//  iCare_new
//
//  Created by eson on 13-12-24.
//  Copyright (c) 2013年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIAlertViewDismissBlock)(NSInteger buttonIndex);
typedef void (^UIAlertViewCancelBlock)();

@interface UIAlertView (BlockAddition)<UIAlertViewDelegate>

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle;

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  otherButtonTitles:(NSArray*) otherButtons
                          onDismiss:(UIAlertViewDismissBlock) dismissed
                           onCancel:(UIAlertViewCancelBlock) cancelled;

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  otherButtonTitles:(NSArray*) otherButtons
                           subViews:(NSArray*) subViews
                          onDismiss:(UIAlertViewDismissBlock) dismissed
                           onCancel:(UIAlertViewCancelBlock) cancelled;

@end
