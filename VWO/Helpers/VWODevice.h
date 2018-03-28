//
//  VWODevice.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VWOAppleDeviceType) {
    VWOAppleDeviceTypeIPhone = 1,
    VWOAppleDeviceTypeIPad = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface VWODevice : NSObject

@property (class, readonly, nonatomic) BOOL isAttachedToDebugger;
@property (class, readonly, nonatomic) VWOAppleDeviceType appleDeviceType;

/// Eg: 11.0.2
@property (class, readonly, nonatomic) NSString *iOSVersion;

/// iPhone 6,2
@property (class, readonly, nonatomic) NSString *deviceName;

/**
 UIDevice.currentDevice.name
 Eg: Kaunteya's iPhone
 */
@property (class, readonly, nonatomic) NSString *userName;

@property (class, readonly, nonatomic) int screenWidth;
@property (class, readonly, nonatomic) int screenHeight;

@end

NS_ASSUME_NONNULL_END
