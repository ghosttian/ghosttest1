//
//  GinWrtierLocationController.h
//  Gin
//
//  Created by tianzhe on 13-3-8.
//  Copyright (c) 2013年 Gin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
typedef void(^ReverseGeoderCompletionBlock) (NSString* address);//获取详细位置信息成功回调
typedef void(^ReverseGeoderErrorBlock) (NSString *errStr);//获取详细位置信息失败回调

@class GinLocationCentre;

@protocol LocatingCenterDelegate <NSObject>

@optional
// 有效定位数据更新通知
- (void)didLocatingUpdate:(CLLocation *)newLocation;
@optional
// 定位到了完全符合条件的数据
- (void)didLocatingSuccess:(CLLocation *)location;
// 定位失败
- (void)didLocatingFail;
//获取到详细位置信息回调
- (void)didGetLocation:(NSString*) msg loction:(NSString *)placemark;

@end

@interface GinLocationCentre : NSObject<CLLocationManagerDelegate>

@property (nonatomic,strong)CLLocation* storedLocation;// 储存的有效位置信息
@property (nonatomic,weak) id<LocatingCenterDelegate> locationDelegate;
@property (nonatomic, strong) CLGeocoder *geoCode;
@property (nonatomic,strong) CLLocationManager *locationManager;


+ (GinLocationCentre*)sharedInstance;
//开始定位
- (void)runRoutineLocating:(id<LocatingCenterDelegate>)delegate;
- (BOOL)isLocationServicesEnabled;
- (void)startLocatingWithAccuracy:(CLLocationAccuracy)accuracy
                           failIn:(NSTimeInterval)expirationTime;
- (BOOL)checkIfLocationServiceEnabledAndWarn;
//获取详细地址信息
- (void)startedReverseGeoder :(CLLocationCoordinate2D)coor;
//获取详细地址信息 --block
- (void)startedReverseGeoder :(CLLocationCoordinate2D)coor completionBlock :(ReverseGeoderCompletionBlock)finishBlock errBlock:(ReverseGeoderErrorBlock)errorBlock;

@end
