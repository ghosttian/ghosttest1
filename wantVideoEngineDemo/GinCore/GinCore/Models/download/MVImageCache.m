//
//  MVImageCache.m
//  microChannel
//
//  Created by alankong on 4/15/14.
//  Copyright (c) 2014 wbdev. All rights reserved.
//

#import "MVImageCache.h"

@interface MVImageCache()

@property (nonatomic, strong) NSCache* memCache;

@end

@implementation MVImageCache

static MVImageCache*  gInstance = nil;
+ (MVImageCache*) sharedInstance
{
    if (gInstance == nil) {
        gInstance = [[MVImageCache alloc] init];
    }
    
    return gInstance;
}


- (id)init
{
	if (self = [super init]) {
        self.memCache = [[NSCache alloc] init];
	}
	return self;
}

- (void)clear {
    [self.memCache removeAllObjects];
}

- (void)setImage:(UIImage*)image forPath:(NSString*)path {
    [self.memCache setObject:image forKey:[self keyForPath:path]];
}

- (UIImage*)getImageForPath:(NSString*)path {
    UIImage* image = [self.memCache objectForKey:[self keyForPath:path]];
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:path];
    }
    
    if (image != nil) {
        [self setImage:image forPath:path];
    }
    
    return image;
}

- (NSString*)keyForPath:(NSString*)path {
    NSString* key = [NSString stringWithFormat:@"%u", [[path description] hash]];
    return key;
}

@end
