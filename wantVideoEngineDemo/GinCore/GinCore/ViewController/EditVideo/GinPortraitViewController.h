//
//  GinPortraitViewController.h
//  microChannel
//
//  Created by aidenluo on 3/10/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GinModalViewDismissDelegate <NSObject>
@optional
-(void)modalViewDismiss;
@end

@interface GinPortraitViewController : UIViewController
{
    BOOL _candoTransition;
}
@end
