//
//  GinPlaceHolderTextView.h
//  GinCore
//
//  Created by leizhu on 14/12/18.
//  Copyright (c) 2014年 leizhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GinPlaceHolderTextView : UITextView

@property(nonatomic,strong) NSString *placeholder;
@property(nonatomic,strong) UIColor *realTextColor;
@property(nonatomic,strong) UIColor *placeholderColor;

@end
