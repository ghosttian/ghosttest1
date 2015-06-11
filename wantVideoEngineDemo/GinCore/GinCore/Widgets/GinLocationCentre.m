//
//  GinWrtierLocationController.m
//  Gin
//
//  Created by tianzhe on 13-3-8.
//  Copyright (c) 2013年 Gin. All rights reserved.
//

#import "GinLocationCentre.h"

@interface GinLocationCentre (private)
@end

@implementation GinLocationCentre

- (void)dealloc{

}

- (id)init {
	if (self = [super init]) {
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.delegate = self;
        
        [self flushBuffer];
        
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        if ([self isLocationServicesEnabled]) {
            [_locationManager startUpdatingLocation];
        }
        [_locationManager stopUpdatingLocation];
        
        
	}
	return self;
}

+ (GinLocationCentre*)sharedInstance{
    static GinLocationCentre *instance = nil;
    @synchronized(self){
        if(instance == nil){
            instance = [[GinLocationCentre alloc] init];
        }
        return instance;
    }
}

-(CLGeocoder *)geoCode
{
    if (nil == _geoCode) {
        _geoCode = [[CLGeocoder alloc]init];
    }
    return _geoCode;
}
- (void)runRoutineLocating:(id<LocatingCenterDelegate>)delegate {
    self.locationDelegate = delegate;
    // 如果上一次定位的数据未过期，则不进行定位
	if (self.storedLocation) {
		NSTimeInterval age = [self.storedLocation.timestamp timeIntervalSinceNow];
		if (age + 300.00f >= 0) {
            if(self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(didLocatingSuccess:)]){
                [self.locationDelegate didLocatingSuccess:self.storedLocation];
            }
			return;
		}
	}
    
	// 如果上次定位的数据已超过执行周期，则进行例行定位
	[self startLocatingWithAccuracy:kCLLocationAccuracyHundredMeters failIn:5.0f];
	NSLog(@"正在进行例行定位....");
}

- (void)startLocatingWithAccuracy:(CLLocationAccuracy)accuracy failIn:(NSTimeInterval)expirationTime {
    // 开启定位动作
    [_locationManager setDesiredAccuracy:accuracy];
    [_locationManager setDistanceFilter:10];
    [_locationManager startUpdatingLocation];
}

- (void)flushBuffer {
	self.storedLocation = nil;
}

- (BOOL)isLocationServicesEnabled {
   return [CLLocationManager locationServicesEnabled];
}

- (BOOL)checkIfLocationServiceEnabledAndWarn {
    if ([self isLocationServicesEnabled]) {
        return YES;
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"定位服务不可用"
                                                            message:@"请在主屏幕的\"设置\"->\"通用\"中打开\"定位服务\"，并重试"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return NO;
    }
}

#pragma mark CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	NSLog(@"location succ");
    // 如果定位结果生成的时间已经超过了5分钟，则放弃。
    NSTimeInterval age = [newLocation.timestamp timeIntervalSinceNow];
    if (age + 300.0f < 0){
        return;
    }
	
    // 获得完全符合精度要求的定位结果，停止定位活动，发出success通知
    //	if (newLocation.horizontalAccuracy <= manager.desiredAccuracy) {
    
    self.storedLocation = newLocation;
    [_locationManager stopUpdatingLocation];
    
    if(self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(didLocatingSuccess:)]){
        [self.locationDelegate didLocatingSuccess:newLocation];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{

    [self checkIfLocationServiceEnabledAndWarn];
	
	// 定位失败，停止定位活动，返回错误对象通知delegate，并注销之
	[_locationManager stopUpdatingLocation];
    if(self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(didLocatingFail)]){
        [self.locationDelegate didLocatingFail];
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:RCLocatingCenterDidFailedNotification object:nil];
    
}

/*
 @property (nonatomic, readonly) NSString *name; // eg. Apple Inc.
 @property (nonatomic, readonly) NSString *thoroughfare; // street address, eg. 1 Infinite Loop
 @property (nonatomic, readonly) NSString *subThoroughfare; // eg. 1
 @property (nonatomic, readonly) NSString *locality; // city, eg. Cupertino
 @property (nonatomic, readonly) NSString *subLocality; // neighborhood, common name, eg. Mission District
 @property (nonatomic, readonly) NSString *administrativeArea; // state, eg. CA
 @property (nonatomic, readonly) NSString *subAdministrativeArea; // county, eg. Santa Clara
 @property (nonatomic, readonly) NSString *postalCode; // zip code, eg. 95014
 @property (nonatomic, readonly) NSString *ISOcountryCode; // eg. US
 @property (nonatomic, readonly) NSString *country; // eg. United States
 @property (nonatomic, readonly) NSString *inlandWater; // eg. Lake Tahoe
 @property (nonatomic, readonly) NSString *ocean; // eg. Pacific Ocean
 @property (nonatomic, readonly) NSArray *areasOfInterest; // eg. Golden Gate Park
 */

////////////////////////////-----下面方法在需要得到地点的时候调用----///////////////////////////////
- (void)startedReverseGeoder:(CLLocationCoordinate2D)coor{
   [self.geoCode reverseGeocodeLocation:_locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
       if (error) {
           //errStr = @"获取位置失败";
           if (self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(didLocatingFail)]) {
               [self.locationDelegate didLocatingFail];
           }
       }else{
           
        
           if (placemarks && placemarks.count > 0) {
               CLPlacemark *place = [placemarks objectAtIndex:0];
               NSMutableString * addressStr = [[NSMutableString alloc] init];
               if (place.country && ![[place.country lowercaseString] isEqualToString:@"unknown"]) {
                   [addressStr appendString:place.country];
               }
               if (place.administrativeArea  && ![[place.administrativeArea lowercaseString] isEqualToString:@"unknown"]) {
                   [addressStr appendString:place.administrativeArea];
               }
               if (place.subAdministrativeArea  && ![[place.subAdministrativeArea lowercaseString] isEqualToString:@"unknown"]) {
                   [addressStr appendString:place.subAdministrativeArea];
               }
               if (place.locality  && ![[place.locality lowercaseString] isEqualToString:@"unknown"]) {
                   [addressStr appendString:place.locality];
               }
               if (place.subLocality  && ![[place.subLocality lowercaseString] isEqualToString:@"unknown"]) {
                   [addressStr appendString:place.subLocality];
               }
               if (place.thoroughfare  && ![[place.thoroughfare lowercaseString] isEqualToString:@"unknown"]) {
                   [addressStr appendString:place.thoroughfare];
               }
               if (self.locationDelegate && [self.locationDelegate respondsToSelector:@selector(didGetLocation:loction:)]) {
                   [self.locationDelegate didGetLocation:nil loction:addressStr];
               }
           }
       }
    
   }];
}

- (void)startedReverseGeoder :(CLLocationCoordinate2D)coor completionBlock :(ReverseGeoderCompletionBlock)finishBlock errBlock:(ReverseGeoderErrorBlock)errorBlock
{
    CLLocation *location = [[CLLocation alloc]initWithLatitude:coor.latitude longitude:coor.longitude];
    [self.geoCode reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSString *errStr = nil;
        if (error) {
            errStr = @"获取位置失败";
            if (errorBlock) {
                errorBlock(errStr);
            }
        }else{
            if (placemarks && placemarks.count > 0) {
                CLPlacemark *place = [placemarks objectAtIndex:0];

                NSString *addresStr = [[[place description] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] objectAtIndex:0];

                if(finishBlock){
                    finishBlock(addresStr);
                }
            }
        }
        
    }];
}
@end