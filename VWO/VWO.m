//
//  VWO.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 22/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWO.h"
#import "VWOController.h"

static VWOLogLevel kLogLevel = VWOLogLevelError;
NSString * const VWOUserStartedTrackingInCampaignNotification = @"VWOUserStartedTrackingInCampaignNotification";

@implementation VWO

+ (VWOLogLevel)logLevel {
    return kLogLevel;
}

+ (void)setLogLevel:(VWOLogLevel)level {
    kLogLevel = level;
}

+ (void)launchForAPIKey:(NSString *)apiKey {
    NSParameterAssert(apiKey);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.shared launchWithAPIKey:apiKey withTimeout:nil withCallback:nil failure:nil];
    });
}

+ (void)launchForAPIKey:(NSString *)apiKey completion:(void(^)(void))completion failure:(void (^)(NSString *error))failureBlock {
    NSParameterAssert(apiKey);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.shared launchWithAPIKey:apiKey withTimeout:nil withCallback:completion failure:failureBlock];
    });
}

+ (void)launchSynchronouslyForAPIKey:(NSString *)apiKey timeout:(NSTimeInterval)timeout {
    NSParameterAssert(apiKey);
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        [VWOController.shared launchWithAPIKey:apiKey withTimeout:@(timeout) withCallback:nil failure:nil];
    });
}

+ (id)variationForKey:(NSString *)key {
    NSParameterAssert(key);
    __block id object;
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        object = [VWOController.shared variationForKey:key];;
    });
    return object;
}

+ (id)variationForKey:(NSString *)key defaultValue:(id)defaultValue {
    NSParameterAssert(key);
    NSParameterAssert(defaultValue);
    __block id object;
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        object = [VWOController.shared variationForKey:key];;
    });
    return object != nil ? object : defaultValue;
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
    return kSDKversion;
}

@end
