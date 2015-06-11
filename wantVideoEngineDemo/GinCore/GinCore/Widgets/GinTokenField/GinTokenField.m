//
//  GinTokenField.m
//  GinTokenFieldDemo
//
//  Created by leizhu on 13-12-17.
//  Copyright (c) 2013年 leizhu. All rights reserved.
//

#import "GinTokenField.h"
#import "GinToken.h"
#import "UIColor+Utils.h"

@interface GinTokenField () <UIAlertViewDelegate> {
    CGPoint _tokenPosition;
    BOOL alertShowing;
}
@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation GinTokenField

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.alertView = nil;
}

- (id)initWithFrame:(CGRect)frame showAt:(BOOL)show {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorderStyle:UITextBorderStyleNone];
        [self setFont:[UIFont systemFontOfSize:kGinTokenFontSize]];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [self setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        
        [self addTarget:self action:@selector(didBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
        [self addTarget:self action:@selector(didEndEditing) forControlEvents:UIControlEventEditingDidEnd];
        [self addTarget:self action:@selector(didChangeText) forControlEvents:UIControlEventEditingChanged];
        
        if (show) {
            [self setPromptText:@"@"];
            [self setText:kTextEmpty];
        }
        
        _ginTokens = [[NSMutableArray alloc] init];
        _editable = YES;
        _edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        [self layoutTokensAnimated:NO];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame showAt:YES];
}

#pragma mark -
#pragma mark Private methods

- (CGFloat)layoutTokensInternal {
	
    CGFloat leftMargin = _edgeInsets.left+self.leftView.bounds.size.width+5;
	//CGFloat lineHeight = self.font.lineHeight + topMargin + 5;
    CGFloat lineHeight = kGinTokenHeight + 10;
	
	_numberOfLines = 1;
    _tokenPosition = CGPointMake(leftMargin, _edgeInsets.top);
	
    for (GinToken *token in self.ginTokens) {
        CGFloat maxWith = self.bounds.size.width - _edgeInsets.right - (_numberOfLines > 1 ? _edgeInsets.left : leftMargin);
		[token setMaxWidth:maxWith];
		
		if (token.superview){
			
			if (_tokenPosition.x + token.bounds.size.width + _edgeInsets.right > self.bounds.size.width){
				_numberOfLines++;
				_tokenPosition.x = (_numberOfLines > 1 ? _edgeInsets.left : leftMargin);
				_tokenPosition.y += lineHeight;
			}
			
            token.frame = CGRectMake(_tokenPosition.x, _tokenPosition.y, token.bounds.size.width, token.bounds.size.height);
			_tokenPosition.x += token.bounds.size.width + 8;
			
//			if (self.bounds.size.width - _tokenPosition.x - rightMargin < 50){
//				_numberOfLines++;
//				_tokenPosition.x = (_numberOfLines > 1 ? hPadding : leftMargin);
//				_tokenPosition.y += lineHeight;
//			}
		}
    }
	return _tokenPosition.y + lineHeight;
}

- (void)layoutTokensAnimated:(BOOL)animated {
	
	CGFloat newHeight = [self layoutTokensInternal];
	if (self.bounds.size.height != newHeight){
		
        CGRect rect = self.frame;
        rect.size.height = newHeight;
        
		// Animating this seems to invoke the triple-tap-delete-key-loop-problem-thing™
		[UIView animateWithDuration:(animated ? 0.3 : 0) animations:^{
            self.frame = rect;
            [self sendActionsForControlEvents:(UIControlEvents)GinTokenFieldControlEventFrameWillChange];
		} completion:^(BOOL complete){
			if (complete) [self sendActionsForControlEvents:(UIControlEvents)GinTokenFieldControlEventFrameDidChange];
		}];
	}
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self layoutTokensAnimated:NO];
}

- (void)setText:(NSString *)text {
	[super setText:(text.length == 0 ? kTextEmpty : text)];
}

#pragma mark -
#pragma mark UIControl Events

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    return (_editable ? [super becomeFirstResponder] : NO);
}

- (void)didBeginEditing {
    for (GinToken *token in self.ginTokens) {
        [self addToken:token];
    }
}

- (void)didEndEditing {
//    [self.selectedToken setSelected:NO];
//    _selectedToken = nil;
}

- (void)didChangeText {
    if (!self.text.length)[self setText:kTextEmpty];
}

- (void)tokenTouchDown:(GinToken *)token {
    if (_selectedToken != token){
		[_selectedToken setSelected:NO];
		_selectedToken = nil;
	}
}

- (void)tokenTouchUpInside:(GinToken *)token {
    if (_editable) {
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (![menu isMenuVisible]) {
            [self selectToken:token];
            [token becomeFirstResponder];
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unhighlight) name:UIMenuControllerWillHideMenuNotification object:nil];
            [menu setTargetRect:token.frame inView:self];
            [menu setMenuVisible:YES animated:YES];
        } else {
            [menu setMenuVisible:NO animated:YES];
            [self deselectSelectedToken];
        }
    }
}

- (void)unhighlight{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
}

- (void)delete:(id)sender {
    [self removeToken:self.selectedToken];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (!self.selectedToken) {
//        if ([self.text isEqualToString:kTextEmpty] || [self.text isEqualToString:kTextHidden]) {
//            return NO;
//        }
        return NO;
    }
    if (action == @selector(delete:)) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    alertShowing = NO;
}

#pragma mark -
#pragma mark Public methods

- (void)addToken:(GinToken *)token {
    
    if (self.ginTokens.count >= self.maxCount && self.maxCount > 0) {
        if (alertShowing) {
            return;
        }
        NSString *tips = [NSString stringWithFormat:@"您最多只能选择%ld位朋友", (long)self.maxCount];
        self.alertView = [[UIAlertView alloc] initWithTitle:tips message:nil delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [self.alertView show];
        alertShowing = YES;
        return;
    }
    [token addTarget:self action:@selector(tokenTouchDown:) forControlEvents:UIControlEventTouchDown];
    [token addTarget:self action:@selector(tokenTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    if (![self.ginTokens containsObject:token]) {
        [self addSubview:token];
        [self.ginTokens addObject:token];
    }
    [self deselectSelectedToken];
    
    [self layoutTokensAnimated:YES];
    
    token.selected = NO;
    
    if ([self.tokenFieldDelegate respondsToSelector:@selector(tokenField:didAddToken:)]) {
        [self.tokenFieldDelegate tokenField:self didAddToken:token];
    }
}

- (void)addTokenWithTitle:(NSString *)title {
    return [self addTokenWithTitle:title object:nil];
}

- (void)addTokenWithTitle:(NSString *)title object:(id)object {
    if (title.length > 0) {
        GinToken *token = [[GinToken alloc] initWithTitle:title object:object];
        [self addToken:token];
    }
}

- (void)removeTokenWithTitle:(NSString *)title {
    if (title.length > 0) {
        for (GinToken *token in self.ginTokens) {
            if ([token.titleLabel.text isEqualToString:title]) {
                [self removeToken:token];
                break;
            }
        }
    }
}

- (void)removeToken:(GinToken *)token {
    if (token == _selectedToken) {
        [self deselectSelectedToken];
    }
    [token removeFromSuperview];
    [self.ginTokens removeObject:token];
    
    [self layoutTokensAnimated:YES];
    
    if ([self.tokenFieldDelegate respondsToSelector:@selector(tokenField:didRemoveToken:)]) {
        [self.tokenFieldDelegate tokenField:self didRemoveToken:token];
    }
}

- (void)removeAllTokens {
    for (GinToken *token in self.ginTokens) {
        [self removeToken:token];
    }
    
    [self layoutTokensAnimated:YES];
}

- (void)selectToken:(GinToken *)token {
    [self deselectSelectedToken];
	
	_selectedToken = token;
	[_selectedToken setSelected:YES];
	
	[self setText:kTextHidden];
}

- (void)deselectSelectedToken {
    [_selectedToken setSelected:NO];
	_selectedToken = nil;
	
	[self setText:kTextEmpty];
}

- (BOOL)containsTitle:(NSString *)title {
    for (GinToken *token in self.ginTokens) {
        if ([token.titleLabel.text isEqualToString:title]) {
            return YES;
        }
    }
    return NO;
}

- (void)setPromptText:(NSString *)text {
    if (text){
		UILabel * label = (UILabel *)self.leftView;
		if (!label || ![label isKindOfClass:[UILabel class]]){
			label = [[UILabel alloc] initWithFrame:CGRectZero];
			[label setTextColor:[UIColor colorWithRGBHex:0xffaaaaaa alpha:1.0]];
			[self setLeftView:label];
			[self setLeftViewMode:UITextFieldViewModeAlways];
		}
		[label setText:text];
		[label setFont:[UIFont systemFontOfSize:20]];
		[label sizeToFit];
        
	} else {
		[self setLeftView:nil];
	}
	[self layoutTokensAnimated:YES];
}

- (NSArray *)tokenTitles {
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:self.ginTokens.count];
    for (GinToken *token in self.ginTokens) {
        [titles addObject:[token.titleLabel.text copy]];
    }
    return titles;
}

- (NSArray *)tokenObjects {
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:self.ginTokens.count];
    for (GinToken *token in self.ginTokens) {
        [objects addObject:token.object];
    }
    return objects;
}


#pragma mark -
#pragma mark Override Layout methods

- (CGRect)textRectForBounds:(CGRect)bounds {
	
	if ([self.text isEqualToString:kTextHidden]) return CGRectMake(0, -20, 0, 0);
	
	CGRect frame = CGRectOffset(bounds, _tokenPosition.x, _tokenPosition.y + 5);
	frame.size.width -= (_tokenPosition.x + 5);
	
	return frame;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
	return [self textRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
	return [self textRectForBounds:bounds];
}

//- (void)drawPlaceholderInRect:(CGRect)rect {
//    [[UIColor colorWithRed:176/255.0 green:176/255.0 blue:176/255.0 alpha:1.0] setFill];
//    CGRect bounds = [self placeholderRectForBounds:self.bounds];
//    bounds.origin.x = 0;
//    [[self placeholder] drawInRect:bounds withFont:[UIFont systemFontOfSize:14.0]];
//}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    return CGRectMake(_edgeInsets.left, _edgeInsets.top + 2, self.leftView.bounds.size.width, self.leftView.bounds.size.height);
}

- (CGFloat)leftViewWidth {
	
	if (self.leftViewMode == UITextFieldViewModeNever ||
		(self.leftViewMode == UITextFieldViewModeUnlessEditing && self.editing) ||
		(self.leftViewMode == UITextFieldViewModeWhileEditing && !self.editing)) return 0;
	
	return self.leftView.bounds.size.width;
}

@end
