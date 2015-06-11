//
//  NSObject+MemoryMonitor.m
//  DetectMemoryLeak
//
//  Created by eson on 13-12-25.
//  Copyright (c) 2013年 eson. All rights reserved.
//

#import "NSObject+MemoryMonitor.h"

#import <objc/runtime.h>
#if __has_feature(objc_arc)
#error MRC only. Either turn on MRC for the project
#endif

static NSMutableDictionary * memoryMonitorCache = nil;
static dispatch_queue_t memoryMonitorQueue;
static UIWindow *monitorWindow = nil;
static EvaluateNeedPrintMemoryInfoForClassBlock needPrintClassBlock;
static RecoverApplicationInitailStateBlock releaseKeyWindowBlock;

static const CGFloat kMemoryMonitorWindowHeight = 10;
static const NSTimeInterval kPrintAllMonitoredObjectsDelayInterval = 3;

@implementation NSObject (MemoryMonitor)

#pragma mark - hacker
#ifdef MONITOR_MEMORY_LEAK

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		memoryMonitorCache = [[NSMutableDictionary alloc]init];
		memoryMonitorQueue = dispatch_queue_create("MemoryMonitorQueue", DISPATCH_QUEUE_CONCURRENT);
	});
	[self swizzleClassMethod:@selector(alloc) toSelector:@selector(mAlloc)];
	[self swizzleInstanceMethod:NSSelectorFromString(@"dealloc") toSelector:@selector(mDealloc)];
}
#endif

- (void)mDealloc
{
	NSString *key = NSStringFromClass([self class]);
	dispatch_barrier_async(memoryMonitorQueue, ^{
//		NSLog(@"dealloc class %@",key);
		NSNumber *allocObjectCount = [memoryMonitorCache objectForKey:key];
		if (allocObjectCount && allocObjectCount.integerValue > 0) {
			[memoryMonitorCache setObject:[NSNumber numberWithInteger:allocObjectCount.integerValue - 1] forKey:key];
		} else {
			[memoryMonitorCache removeObjectForKey:key];
		}
	});

	[self mDealloc];
}

+ (id)mAlloc
{
	id instance = [self mAlloc];
	NSString *key = NSStringFromClass([instance class]);
	dispatch_barrier_async(memoryMonitorQueue, ^{
		if (key.length) {
			NSNumber *allocObjectCount = [memoryMonitorCache objectForKey:key];
			if (!allocObjectCount || allocObjectCount.integerValue == 0) {
				[memoryMonitorCache setObject:[NSNumber numberWithInteger:1] forKey:key];
			} else {
				[memoryMonitorCache setObject:[NSNumber numberWithInteger:allocObjectCount.integerValue + 1] forKey:key];
			}
		}
	});
	return instance;
}

+ (void)swizzleInstanceMethod:(SEL)fromSelector toSelector:(SEL)toSelector
{
    Method m1 = class_getInstanceMethod(self, fromSelector);
    Method m2 = class_getInstanceMethod(self, toSelector);
    method_exchangeImplementations(m1, m2);
}

+ (void)swizzleClassMethod:(SEL)fromSelector toSelector:(SEL)toSelector
{
	Method m1 = class_getClassMethod(self, fromSelector);
    Method m2 = class_getClassMethod(self, toSelector);
    method_exchangeImplementations(m1, m2);
}

#pragma mark - setup memory leak monitor

+ (void)addCheckMemoryMonitorUI
{
	CGRect frame = [[UIApplication sharedApplication]statusBarFrame];
	frame.size.height = kMemoryMonitorWindowHeight;
	UIWindow *overlayWindow = [[UIWindow alloc] initWithFrame:frame];
	overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	overlayWindow.backgroundColor = [UIColor redColor];
	overlayWindow.userInteractionEnabled = YES;
	overlayWindow.windowLevel = UIWindowLevelStatusBar;
	overlayWindow.hidden = NO;
	monitorWindow = overlayWindow;
	
	CGFloat buttonWidth = 160;
	CGFloat buttonHeight = kMemoryMonitorWindowHeight;
	UIButton * button = [self createButton:@"Check Leak" target:[self class] selector:@selector(checkMemory)];
	button.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
	button.backgroundColor = [UIColor redColor];
	[overlayWindow addSubview:button];
	
	button = [self createButton:@"Print All" target:[self class] selector:@selector(printAllAllocObjects)];
	button.frame = CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight);
	[overlayWindow addSubview:button];
}

+ (UIButton *)createButton:(NSString *)title target:(id)target selector:(SEL)sel
{
	UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.backgroundColor = [UIColor greenColor];
	button.titleLabel.font = [UIFont systemFontOfSize:8];
	[button setTitle:title forState:UIControlStateNormal];
	[button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
	return button;
}

+ (void)setupMonitorMemoryLeaks:(EvaluateNeedPrintMemoryInfoForClassBlock)needPrintBlock recoverApplicationInitailStateBlock:(RecoverApplicationInitailStateBlock)block
{
	needPrintClassBlock = [needPrintBlock copy];
	releaseKeyWindowBlock = [block copy];
	[self addCheckMemoryMonitorUI];
}

+ (void)checkMemory
{
	if (!releaseKeyWindowBlock) {
		NSLog(@"you need to release the Application keywindow");
	}
	[self checkMemoryLeak:needPrintClassBlock];
}

+ (void)checkMemoryLeak:(EvaluateNeedPrintMemoryInfoForClassBlock) needPrintBlock
{
	@autoreleasepool {
		if (releaseKeyWindowBlock) {
			releaseKeyWindowBlock();
#if !__has_feature(objc_arc)
			Block_release(releaseKeyWindowBlock);
#endif
			releaseKeyWindowBlock = nil;
		}
		double delayInSeconds = kPrintAllMonitoredObjectsDelayInterval;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			printAllMonitoredObjects(needPrintBlock);
		});
	}
}

+ (void)printAllAllocObjects
{
	printAllMonitoredObjects(^BOOL(NSString *className) {
		return YES;
	});
}
@end

void printAllMonitoredObjects (EvaluateNeedPrintMemoryInfoForClassBlock needPrintBlock)
{
	if (memoryMonitorCache.count) {
		dispatch_async(memoryMonitorQueue, ^{
			for (id className in memoryMonitorCache.allKeys) {
				NSInteger objectCount = [memoryMonitorCache[className] integerValue];
				BOOL needPrint = needPrintBlock ? needPrintBlock(className) : YES;
				if (objectCount > 0 && needPrint) {
					NSLog(@"%@ object did not dealloc object count %ld",className,(long)objectCount);
				}
			}
		});
	}
}
