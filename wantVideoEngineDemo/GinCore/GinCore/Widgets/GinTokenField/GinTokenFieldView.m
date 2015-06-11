//
//  GinTokenFieldView.m
//  microChannel
//
//  Created by leizhu on 13-12-23.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinTokenFieldView.h"
#import "GinTokenField.h"

@implementation GinTokenFieldView

- (id)initWithFrame:(CGRect)frame showAt:(BOOL)show {
    self = [super initWithFrame:frame];
    if (self) {
        _tokenField = [[GinTokenField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) showAt:show];
        _tokenField.delegate = self;
        [_tokenField addTarget:self action:@selector(tokenFieldWillChangeFrame:) forControlEvents:(UIControlEvents)GinTokenFieldControlEventFrameWillChange];
        [self addSubview:_tokenField];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame showAt:YES];
}

#pragma mark -
#pragma mark Scroll methods

- (void)tokenFieldWillChangeFrame:(GinTokenField *)tokenField {
    
    [self setContentSize:CGSizeMake(self.bounds.size.width, tokenField.bounds.size.height)];
    
    CGFloat maxHeight = 10*3 + 30*2;
    CGRect rect = self.frame;
    rect.size.height = MIN(maxHeight, tokenField.frame.size.height);
    self.frame = rect;

    CGFloat offsetY = 0;
    if (self.bounds.size.height >= maxHeight) {
        offsetY = self.contentSize.height - maxHeight;
    }
    self.contentOffset = CGPointMake(0, offsetY);
    
    if (self.frameChangeBlock) {
        self.frameChangeBlock(self.frame);
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
	if (self.tokenField.ginTokens.count && [string isEqualToString:@""] && [textField.text isEqualToString:kTextEmpty]){
		[self.tokenField selectToken:[self.tokenField.ginTokens lastObject]];
		return NO;
	}
	
	if ([textField.text isEqualToString:kTextHidden]){
		[self.tokenField removeToken:self.tokenField.selectedToken];
		return (![string isEqualToString:@""]);
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

@end
