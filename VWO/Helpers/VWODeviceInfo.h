//
//  VWODeviceInfo.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWODeviceInfo : NSObject

@property (class, readonly, nonatomic) BOOL isAttachedToDebugger;
@property (class, readonly, copy) NSString *platformName;
+ (NSString *)iOSVersionMinor:(BOOL) minor patch:(BOOL)patch;

@end

NS_ASSUME_NONNULL_END
