//
//  VWO.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 22/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWO.h"
#import "VWOController.h"
#import "VWOLogger.h"

static VWOLogLevel kLogLevel = VWOLogLevelError;
static BOOL kOptOut = NO;

NSString * const VWOUserStartedTrackingInCampaignNotification = @"VWOUserStartedTrackingInCampaignNotification";

@implementation VWO

+ (VWOLogLevel)logLevel {
    return kLogLevel;
}

+ (void)setLogLevel:(VWOLogLevel)level {
    kLogLevel = level;
}

+ (BOOL)optOut {
    return kOptOut;
}

+ (void)setOptOut:(BOOL)optOut {
    if (VWOController.shared.isInitialised) {
        VWOLogWarning(@"Cannot optout/optin after VWO has been launched");
        return;
    }
    kOptOut =  optOut;
}

+ (void)launchForAPIKey:(NSString *)apiKey {
    NSParameterAssert(apiKey);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.shared launchWithAPIKey:apiKey config:nil withTimeout:nil withCallback:nil failure:nil];
    });
}

+ (void)launchForAPIKey:(NSString *)apiKey
             completion:(void(^)(void))completion
                failure:(void (^)(NSString *error))failureBlock {
    NSParameterAssert(apiKey);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.shared launchWithAPIKey:apiKey config:nil withTimeout:nil withCallback:completion failure:nil];
    });
}

+ (void)launchForAPIKey:(NSString *)apiKey
             config:(VWOConfig *)config
             completion:(void(^)(void))completion
                failure:(nullable void (^)(NSString *error))failureBlock {
    NSParameterAssert(apiKey);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.shared launchWithAPIKey:apiKey
                                    config:config
                                   withTimeout:nil
                                  withCallback:completion
                                       failure:failureBlock];

    });
}

+ (void)launchSynchronouslyForAPIKey:(NSString *)apiKey
                             timeout:(NSTimeInterval)timeout {
    NSParameterAssert(apiKey);
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        [VWOController.shared launchWithAPIKey:apiKey
                                    config:nil
                                   withTimeout:@(timeout)
                                  withCallback:nil
                                       failure:nil];

    });
}

+ (void)launchSynchronouslyForAPIKey:(NSString *)apiKey
                             timeout:(NSTimeInterval)timeout
                          config:(VWOConfig *)config {
    NSParameterAssert(apiKey);
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        [VWOController.shared launchWithAPIKey:apiKey
                                    config:config
                                   withTimeout:@(timeout)
                                  withCallback:nil
                                       failure:nil];

    });
}

+ (id)objectForKey:(NSString *)key {
    NSParameterAssert(key);
    __block id object;
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        object = [VWOController.shared variationForKey:key];;
    });
    return object;
}

+ (id)objectForKey:(NSString *)key defaultValue:(nullable id)defaultValue {
    id object = [self objectForKey:key];
    return object != nil ? object : defaultValue;
}

+ (id)variationForKey:(NSString *)key defaultValue:(id)defaultValue {
        // Deprecated
    return [self objectForKey:key defaultValue:defaultValue];
}

+ (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    id object = [self objectForKey:key];
    return object != nil ? [object boolValue] : defaultValue;
}

+ (int)intForKey:(NSString *)key defaultValue:(int)defaultValue {
    id object = [self objectForKey:key];
    return object != nil ? [object intValue] : defaultValue;
}

+ (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue {
    id object = [self objectForKey:key];
    return object != nil ? [object doubleValue] : defaultValue;
}

+ (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    NSParameterAssert(key);
    id object = [self objectForKey:key];
    return object != nil ? [object stringValue] : defaultValue;
}

+ (void)trackConversion:(NSString *)goal {
    NSParameterAssert(goal);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.shared trackConversion:goal withValue:nil];
    });
}

+ (void)trackConversion:(NSString *)goal withValue:(double)value {
    NSParameterAssert(goal);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.shared trackConversion:goal withValue:[NSNumber numberWithDouble:value]];
    });
}

+ (void)setCustomVariable:(NSString *)key withValue:(NSString *)value {
    NSParameterAssert(key);
    NSParameterAssert(value);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        VWOController.shared.customVariables[key] = value;
    });
}

+ (NSString *)version {
    return kVWOSDKversion;
}

@end
