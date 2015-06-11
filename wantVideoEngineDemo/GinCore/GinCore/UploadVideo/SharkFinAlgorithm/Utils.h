//
//  Utils.h
//  QQMSFContact
//
//  Created by wstt on 12-8-20.
//
//

#import <Foundation/Foundation.h>
#import "SSCMDef.h"

@interface Utils : NSObject
{
    long _WiFiSent;
    long _WiFiReceived;
    long _WWANSent;
    long _WWANReceived;
}

@property long WiFiSent;
@property long WWANSent;

//获取网口发送流量(B)
+ (long) getOutOctets:(NET_TYPE)netType;

@end
