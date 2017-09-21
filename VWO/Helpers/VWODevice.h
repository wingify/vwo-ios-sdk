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
+ (NSString *)iOSVersionMinor:(BOOL) minor patch:(BOOL)patch;

@end

NS_ASSUME_NONNULL_END
