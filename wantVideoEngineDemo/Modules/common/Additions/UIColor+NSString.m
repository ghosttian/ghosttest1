//
//  UIColor.m
//  Gin
//
//  Created by wbdev on 13-1-5.
//  Copyright (c) 2013年 Gin. All rights reserved.
//

#import "UIColor+NSString.h"

@implementation UIColor(NSStringExtent)


+(UIColor*) colorWithString:(NSString*) string
{
    
    NSArray* array  = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSUInteger count = [array count];
    if(count == 0 || count > 4 || count == 2)
    {
        return nil;
    }
    
    if ([array count] == 1)
    {
        // using name
        NSString* selectorStr = [[array objectAtIndex:0] stringByAppendingString:@"Color"];
        SEL selector = NSSelectorFromString(selectorStr);
        
        if([UIColor respondsToSelector:selector])
        {
            return [UIColor performSelector:selector];
        }
    }else 
    {
        NSMutableArray* values = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < [array count]; ++i)
        {
            CGFloat v = [[array objectAtIndex:i] floatValue];
            if(v > 254.99999f)
            {
                v = 255.0f;
            }
            
            if(v > 0.99999f)
            {
                v = v / 255.0f;
            }
            
            [values addObject:[NSNumber numberWithFloat:v]];
        }
        
        CGFloat r = [[values objectAtIndex:0] floatValue];
        CGFloat g = [[values objectAtIndex:1] floatValue];
        CGFloat b = [[values objectAtIndex:2] floatValue];
        CGFloat a = 1.f;
    
        if(count == 4)
        {
            a = [[array objectAtIndex:3] floatValue];
        }
        
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    
    return nil;
}


@end
