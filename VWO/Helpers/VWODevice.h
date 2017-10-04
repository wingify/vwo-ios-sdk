//
//  VWODevice.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWODevice : NSObject

@property (class, readonly, nonatomic) BOOL isAttachedToDebugger;
@property (class, readonly, nonatomic) BOOL isiPhone;
@property (class, readonly, nonatomic) BOOL isPad;

/// 11.0.2
@property (class, readonly, nonatomic) NSString *iOSVersion;

/// iPhone 6,2
@property (class, readonly, nonatomic) NSString *deviceName;

+ (NSString *)iOSVersionMinor:(BOOL) minor patch:(BOOL)patch;

@end

NS_ASSUME_NONNULL_END
