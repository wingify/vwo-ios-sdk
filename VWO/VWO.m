//
//  VWO.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 22/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWO.h"

#import "VWOController.h"
#import "VWOSocketClient.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import "VWOSDK.h"
#import "VWODevice.h"
#import "VWOSegmentEvaluator.h"

static VWOLogLevel kLogLevel = VWOLogLevelError;
NSString * const VWOUserStartedTrackingInCampaignNotification = @"VWOUserStartedTrackingInCampaignNotification";

@implementation VWO

+ (VWOLogLevel)logLevel {
    return kLogLevel;
}

+ (void)setLogLevel:(VWOLogLevel)level {
    kLogLevel = level;
}

+ (void)launchForAPIKey:(NSString *) apiKey {
    NSParameterAssert(apiKey);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.sharedInstance launchWithAPIKey:apiKey withTimeout:nil withCallback:nil failure:nil];
    });
}

+ (void)launchForAPIKey:(NSString *) apiKey completion:(void(^)(void))completion {
    NSParameterAssert(apiKey);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.sharedInstance launchWithAPIKey:apiKey withTimeout:nil withCallback:completion failure:nil];
    });
}

+ (void)launchForAPIKey:(NSString *)apiKey completion:(void(^)(void))completion failure:(void (^)(void))failureBlock {
    NSParameterAssert(apiKey);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.sharedInstance launchWithAPIKey:apiKey withTimeout:nil withCallback:completion failure:failureBlock];
    });
}

+ (void)launchSynchronouslyForAPIKey:(NSString *) apiKey timeout:(NSTimeInterval)timeout {
    NSParameterAssert(apiKey);
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        [VWOController.sharedInstance launchWithAPIKey:apiKey withTimeout:@(timeout) withCallback:nil failure:nil];
    });
}

+ (id)variationForKey:(NSString *)key {
    NSParameterAssert(key);
    __block id object;
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        object = [VWOController.sharedInstance variationForKey:key];;
    });
    return object;
}

+ (id)variationForKey:(NSString *)key defaultValue:(id)defaultValue {
    NSParameterAssert(key);
    NSParameterAssert(defaultValue);
    __block id object;
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        object = [VWOController.sharedInstance variationForKey:key];;
    });
    if (!object) object = defaultValue;
    return object;
}

+ (void)markConversionForGoal:(NSString *)goal {
    NSParameterAssert(goal);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.sharedInstance markConversionForGoal:goal withValue:nil];
    });
}

+ (void)markConversionForGoal:(NSString *)goal withValue:(double)value {
    NSParameterAssert(goal);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.sharedInstance markConversionForGoal:goal withValue:[NSNumber numberWithDouble:value]];
    });
}

+ (void)setCustomVariable:(NSString *)key withValue:(NSString *)value {
    NSParameterAssert(key);
    NSParameterAssert(value);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        VWOController.sharedInstance.segmentEvaluator.customVariables[key] = value;
    });
}

+ (NSString *)version {
    return VWOSDK.version;
}

@end
