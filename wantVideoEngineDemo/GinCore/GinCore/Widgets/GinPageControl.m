//
//  GinPageControl.m
//  microChannel
//
//  Created by leizhu on 13-7-18.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinPageControl.h"
#import "UIColor+Utils.h"

// Tweak these or make them dynamic.
#define kDotDiameter 7.0
#define kDotSpacer 7.0

@implementation GinPageControl


- (void)setCurrentPage:(NSInteger)page
{
    _currentPage = MIN(MAX(0, page), self.numberOfPages-1);
    [self setNeedsDisplay];
}

- (void)setNumberOfPages:(NSInteger)pages
{
    _numberOfPages = MAX(0, pages);
   _currentPage = MIN(MAX(0, self.currentPage), _numberOfPages-1);
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // Default colors.
        self.backgroundColor = [UIColor clearColor];
        [self initDotColor];
    }
    return self;
}

-(void)initDotColor
{
    self.dotColorCurrentPage = [UIColor colorWithRGBHex:0xff44bbcc alpha:1.0];
    self.dotColorOtherPage = [UIColor lightGrayColor];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    
    CGRect currentBounds = self.bounds;
    CGFloat dotsWidth = self.numberOfPages*self.dotDiameter + MAX(0, self.numberOfPages-1)*self.dotSpacer;
    CGFloat x = CGRectGetMidX(currentBounds)-dotsWidth/2;
    CGFloat y = CGRectGetMidY(currentBounds)-self.dotDiameter/2;
    for (int i=0; i<self.numberOfPages; i++)
    {
        CGRect circleRect = CGRectMake(x, y, self.dotDiameter, self.dotDiameter);
        if (i == self.currentPage)
        {
            CGContextSetFillColorWithColor(context, self.dotColorCurrentPage.CGColor);
        }
        else
        {
            CGContextSetFillColorWithColor(context, self.dotColorOtherPage.CGColor);
        }
        CGContextFillEllipseInRect(context, circleRect);
        x += self.dotDiameter + self.dotSpacer;
    }
}

- (CGFloat)dotDiameter
{
    return kDotDiameter;
}

- (CGFloat)dotSpacer
{
    return kDotSpacer;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.delegate) return;
    
    CGPoint touchPoint = [[[event touchesForView:self] anyObject] locationInView:self];
    
    CGRect currentBounds = self.bounds;
    CGFloat x = touchPoint.x - CGRectGetMidX(currentBounds);
    
    if(x<0 && self.currentPage>=0){
        self.currentPage--;
        [self.delegate pageControlPageDidChange:self];
    }
    else if(x>0 && self.currentPage<self.numberOfPages-1){
        self.currentPage++;
        [self.delegate pageControlPageDidChange:self];
    }
}

@end