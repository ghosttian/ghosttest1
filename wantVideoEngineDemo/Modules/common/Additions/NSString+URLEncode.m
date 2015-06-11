//
//  NSString+URLEncode.m
//  microChannel
//
//  Created by randyyu on 13-11-19.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncode)


- (NSString *)URLEncodedString {
    // Encode all the reserved characters, per RFC 3986
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
                                                                           (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                           kCFStringEncodingUTF8));
    return result;
}

- (NSString*) urlDecode:(NSStringEncoding)stringEncoding
{
    
	NSArray *escapeChars = [NSArray arrayWithObjects:@";", @"/", @"?", @":",
							@"@", @"&", @"=", @"+", @"$", @",", @"!",
                            @"'", @"(", @")", @"*", @"-", @"~", @"_", nil];
	
	NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B", @"%2F", @"%3F", @"%3A",
							 @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%21",
                             @"%27", @"%28", @"%29", @"%2A", @"%2D", @"%7E", @"%5F", nil];
	
	int len = [escapeChars count];
	
	NSMutableString *temp = [self mutableCopy];
	
	int i;
	for (i = 0; i < len; i++) {
		
		[temp replaceOccurrencesOfString:[replaceChars objectAtIndex:i]
							  withString:[escapeChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
	}
	NSString *outStr = [NSString stringWithString: temp];
	
	return [outStr stringByReplacingPercentEscapesUsingEncoding:stringEncoding];
}

@end
