//
//  GinPinyinUntil.h
//  Gin
//
//  Created by aidenluo on 5/9/13.
//  Copyright (c) 2013 Gin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GinPinyinUtil : NSObject

+ (NSString *) convert:(NSString *) hzString;
+ (NSString *) getAllLetterFirstPinyin:(NSString*)word;

@end
