//
//  NSObject+MemoryMonitor.h
//  DetectMemoryLeak
//
//  Created by eson on 13-12-25.
//  Copyright (c) 2013年 eson. All rights reserved.
//

#import <Foundation/Foundation.h>

//#ifndef MONITOR_MEMORY_LEAK
//#define MONITOR_MEMORY_LEAK 1
//#endif

typedef BOOL(^EvaluateNeedPrintMemoryInfoForClassBlock)(NSString *className);
typedef void(^RecoverApplicationInitailStateBlock)();

void printAllMonitoredObjects ();

@interface NSObject (MemoryMonitor)

+ (void)setupMonitorMemoryLeaks:(EvaluateNeedPrintMemoryInfoForClassBlock)needPrintBlock recoverApplicationInitailStateBlock:(RecoverApplicationInitailStateBlock)block;

+ (void)swizzleInstanceMethod:(SEL)fromSelector toSelector:(SEL)toSelector;
+ (void)swizzleClassMethod:(SEL)fromSelector toSelector:(SEL)toSelector;
@end

