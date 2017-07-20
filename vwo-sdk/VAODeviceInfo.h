//
//  VAODeviceInfo.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import <Foundation/Foundation.h>

//Any static information that is specific to device will be handled by this class

@interface VAODeviceInfo : NSObject

+ (BOOL)isAttachedToDebugger;
+ (NSString *)platformName;
+ (NSString *)iOSVersionMinor:(BOOL) minor patch:(BOOL)patch;
@end
