//
//  GinUploadResult.m
//  microChannel
//
//  Created by jozeli on 13-8-7.
//  Copyright (c) 2013年 wbdev. All rights reserved.
//

#import "GinUploadResult.h"

@implementation GinUploadResult

- (void)dealloc
{

}

- (NSString*)simpleDescription
{
    NSString *retVal = [NSString stringWithFormat:@"requestID=%@; rateType=%d; step=%d; vid=%@; fid=%@; msgid=%@, checkKey=%@; offset=%llu; error=%@", self.requestID, self.voideRateType, self.vUpStep, self.vid, self.fid, self.msgID, self.checkkey, self.offset, self.error];
    return retVal;
}

- (id)copyWithZone:(NSZone *)zone
{
	GinUploadResult *result = [[[self class]allocWithZone:zone]init];
    result.s = self.s;
    result.serverip = self.serverip;
    result.port = self.port;
    result.checkkey = self.checkkey;
    result.exists = self.exists;
    result.uin = self.uin;
    result.vid = self.vid;
    result.fid = self.fid;
    result.msgID = self.msgID;
    result.requestID = self.requestID;
    result.fileKey = self.fileKey;
    result.longVideoURL = self.longVideoURL;
    result.offset = self.offset;
    result.vUpStep = self.vUpStep;
    result.path = self.path;
    result.vlen = self.vlen;
    result.sha = self.sha;
    result.md5 = self.md5;
    
    return result;
}
@end
