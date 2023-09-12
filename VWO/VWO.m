//
//  VWO.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 22/09/17.
//  Copyright © 2017-2022 vwo. All rights reserved.
//

#import "VWO.h"
#import "VWOController.h"
#import "VWOLogger.h"
#import "CampaignGroupMapper.h"
#import "MutuallyExclusiveGroups.h"
#import "Group.h"
#import "VWOCampaign.h"
#import "MEGManager.h"

static VWOLogLevel kLogLevel = VWOLogLevelError;
static BOOL kOptOut = NO;
static NSString * const CAMPAIGN_TYPE = @"type";
static NSString * const CAMPAIGN_GROUPS = @"groups";
NSMutableDictionary<NSString *, NSString *> *customVariables;

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
        @try {
                [VWOController.shared launchWithAPIKey:apiKey config:nil withTimeout:nil withCallback:nil failure:nil];
        }@catch (NSException *exception) {
            VWOLogException(@"Caught an exception in launchForAPIKey method: %@", exception);
        }
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
                              config:(nullable VWOConfig *)config
                             timeout:(NSTimeInterval)timeout {
    NSParameterAssert(apiKey);
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        [VWOController.shared launchWithAPIKey:apiKey
                                        config:config
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

+ (id)objectForKey:(NSString *)key{
    NSParameterAssert(key);
    __block id object;
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        @try {
            object = [VWOController.shared variationForKey:key];
        }@catch (NSException *exception) {
            VWOLogException(@"Caught an exception in objectForKey method: %@", exception);
        }
    });
    return object;
}

+ (id)objectForKey:(NSString *)key testKey:(NSString *)testKey{
    NSParameterAssert(key);
    __block id object;
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        @try {
            object = [VWOController.shared variationForKey:key testKey:testKey];
        }@catch (NSException *exception) {
            VWOLogException(@"Caught an exception in objectForKey testKey method: %@", exception);
        }
    });
    
    return object;
}
+ (id)objectForKey:(NSString *)key defaultValue:(nullable id)defaultValue{
    id object = [self objectForKey:key];
    return object != nil ? object : defaultValue;
}

+ (id)objectForKey:(NSString *)key defaultValue:(nullable id)defaultValue testKey:(NSString *)testKey{
    id object = [self objectForKey:key testKey:testKey];
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

+ (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue testKey:(NSString *)testKey{
    id object = [self objectForKey:key testKey:testKey];
    return object != nil ? [object boolValue] : defaultValue;
}

+ (int)intForKey:(NSString *)key defaultValue:(int)defaultValue {
    id object = [self objectForKey:key];
    return object != nil ? [object intValue] : defaultValue;
}

+ (int)intForKey:(NSString *)key defaultValue:(int)defaultValue testKey:(NSString *)testKey{
    id object = [self objectForKey:key testKey:testKey];
    return object != nil ? [object intValue] : defaultValue;
}

+ (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue {
    id object = [self objectForKey:key];
    return object != nil ? [object doubleValue] : defaultValue;
}

+ (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue testKey:(NSString *)testKey{
    id object = [self objectForKey:key testKey:testKey];
    return object != nil ? [object doubleValue] : defaultValue;
}

+ (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    NSParameterAssert(key);
    id object = [self objectForKey:key];
    return [NSString stringWithFormat:@"%@", object != nil ? object : defaultValue];
}

+ (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue testKey:(NSString *)testKey{
    NSParameterAssert(key);
    id object = [self objectForKey:key testKey:testKey];
    return [NSString stringWithFormat:@"%@", object != nil ? object : defaultValue];
}

+ (nullable NSString *)variationNameForTestKey:(NSString *)campaignTestKey {
    NSParameterAssert(campaignTestKey);
    __block NSString *variationName;
    dispatch_barrier_sync(VWOController.taskQueue, ^{
        @try {
            variationName = [VWOController.shared variationNameForCampaignTestKey:campaignTestKey];
        }
        @catch (NSException *exception) {
            VWOLogException(@"Caught an exception in variationNameForTestKey method: %@", exception);
        }
    });
    return variationName;
    
}

+ (NSString *)getCampaign:(NSString *)userId args:(NSDictionary *)args {
    MEGManager *megManager = [[MEGManager alloc] init];
    return [megManager getCampaign:userId args:args];
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
    if (customVariables == nil) {
        customVariables = [NSMutableDictionary new];
    }
    customVariables[key] = value;
    dispatch_barrier_async(VWOController.taskQueue, ^{
        VWOController.shared.customVariables = customVariables;
    });
}


+ (void)pushCustomDimension:(NSString *)customDimensionKey withCustomDimensionValue:(nonnull NSString *)customDimensionValue {
    NSParameterAssert(customDimensionKey);
    NSParameterAssert(customDimensionValue);
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.shared pushCustomDimension:customDimensionKey withCustomDimensionValue:customDimensionValue];
    });
    
}

+ (void)pushCustomDimension:(NSMutableDictionary *)customDimensionDictionary {
    NSParameterAssert(customDimensionDictionary);
    
    NSArray *values = [customDimensionDictionary allValues];

    @try {
        for (id value in values) {
            if([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]){
                continue;
            }
            else{
                @throw [NSException exceptionWithName:@"VWOCustomDimensionException" reason:@"Please enter values with valid type" userInfo:nil];
            }
        }
    }
    @catch (NSException *exception) {
        VWOLogException(@"Caught an exception in pushCustomDimension method: %@", exception);
        return;
    }
    
    dispatch_barrier_async(VWOController.taskQueue, ^{
        [VWOController.shared pushCustomDimension:customDimensionDictionary];
    });
}

+ (NSString *)version {
    return kVWOSDKversion;
}

@end
