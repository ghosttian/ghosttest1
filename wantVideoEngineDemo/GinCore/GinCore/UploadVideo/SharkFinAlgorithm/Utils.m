//
//  Utils.m
//  QQMSFContact
//
//  Created by wstt on 12-8-20.
//
//

#import "Utils.h"
#import <ifaddrs.h>
#import <sys/socket.h>
#import <net/if.h>

Utils *gUtils = nil;

@implementation Utils

@synthesize WiFiSent = _WiFiSent;
@synthesize WWANSent = _WWANSent;

- (void)getInterfaceData
{
    BOOL                    success;
    struct ifaddrs          *addrs;
    const struct ifaddrs    *cursor;
    const struct if_data    *networkStatisc;
    
    _WiFiSent       = 0;
    _WiFiReceived   = 0;
    _WWANSent       = 0;
    _WWANReceived   = 0;
    
    NSString *name=nil;
    
    success = getifaddrs(&addrs) == 0;
    
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
//            NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);

            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    _WiFiSent     += networkStatisc->ifi_obytes;
                    _WiFiReceived += networkStatisc->ifi_ibytes;
//                    NSLog(@"WiFiSent %d ==%d", _WiFiSent, networkStatisc->ifi_obytes);
//                    NSLog(@"WiFiReceived %d ==%d", _WiFiReceived, networkStatisc->ifi_ibytes);
                }
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    _WWANSent     += networkStatisc->ifi_obytes;
                    _WWANReceived += networkStatisc->ifi_ibytes;
//                    NSLog(@"WWANSent %d ==%d", _WWANSent, networkStatisc->ifi_obytes);
//                    NSLog(@"WWANReceived %d ==%d", _WWANReceived, networkStatisc->ifi_ibytes);
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    
//    NSLog(@"WiFiSent:%lu WWANSenT:%lu", _WiFiSent, _WWANSent);
    return;
}

+ (long) getOutOctets:(NET_TYPE)netType
{
    if (gUtils == nil) {
        gUtils = [[Utils alloc]init];
    }
    
    [gUtils getInterfaceData];
    
    if (netType == TYPE_WIFI) {
        return [gUtils WiFiSent];
    }
    else {
        return [gUtils WWANSent];
    }
    
    return 0;
}

@end
