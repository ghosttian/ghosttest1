//
//  GinMD5Util.m
//  Gin
//
//  Created by ricky on 12-12-27.
//  Copyright (c) 2012年 Gin. All rights reserved.
//

#import "GinMD5Util.h"
#import <CommonCrypto/CommonDigest.h>


@implementation GinMD5Util

+ (NSString*) md5String:(NSString*)srcString
{
	const char *cStr = [srcString UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}

@end
