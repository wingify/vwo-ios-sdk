//
//  VWOClient.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 08/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWOClient.h"

#import "VWOModel.h"
#import "VWOController.h"
#import "VWORavenClient.h"
#import "VWOSocketClient.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import "VWOSDK.h"
#import "VWODeviceInfo.h"

static VWOLogLevel kLogLevel = VWOLogLevelError;
NSString * const VWOUserStartedTrackingInCampaignNotification = @"VWOUserStartedTrackingInCampaignNotification";

@implementation VWO

+ (VWOLogLevel)logLevel {
    return kLogLevel;
}

+ (void)setLogLevel:(VWOLogLevel)level {
    kLogLevel = level;
}

+ (void)setUpForKey:(NSString *) key
            isAsync:(BOOL) async
            timeout:(NSTimeInterval)timeout
         completion:(void (^)(void))completionBlock
            failure:(void (^)(void))failureBlock {
    static VWO *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{

        instance = [[self alloc] init];
        [VWOSDK setAppKeyID:key];

        // set up sentry exception handling
        [self setupSentry];

        if (VWODeviceInfo.isAttachedToDebugger) {
            [[VWOSocketClient sharedInstance] launch];
        }
        VWOLogInfo(@"Initializing VWO");
        VWOLogDebug(@"Key: %@", key);
        [VWOController.sharedInstance initializeAsynchronously:async timeout:timeout withCallback:completionBlock failure:failureBlock];
    });
}

+ (void)setupSentry {
    NSDictionary *tags = @{@"VWO Account id" : VWOSDK.accountID,
                           @"SDK Version" : VWOSDK.version};

    //CFBundleDisplayName & CFBundleIdentifier can be nil
    NSMutableDictionary *extras = [NSMutableDictionary new];
    extras[@"App Name"] = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
    extras[@"BundleID"] = NSBundle.mainBundle.infoDictionary[@"CFBundleIdentifier"];

    NSString *DSN = @"https://c3f6ba4cf03548f3bd90066dd182a649:6d6d9593d15944849cc9f8d88ccf1fb0@sentry.io/41858";
    VWORavenClient *client = [VWORavenClient clientWithDSN:DSN extra:extras tags:tags];

    [VWORavenClient setSharedClient:client];
}

+ (void)launchForAPIKey:(NSString *) apiKey {
    NSParameterAssert(apiKey);
    [self setUpForKey:apiKey isAsync:YES timeout:0 completion:nil failure:nil];
}

+ (void)launchForAPIKey:(NSString *) apiKey completion:(void(^)(void))completion {
    NSParameterAssert(apiKey);
    [self setUpForKey:apiKey isAsync:YES timeout:0 completion:completion failure:nil];
}

+ (void)launchForAPIKey:(NSString *)apiKey completion:(void(^)(void))completion failure:(void (^)(void))failureBlock {
    NSParameterAssert(apiKey);
    [self setUpForKey:apiKey isAsync:YES timeout:0 completion:completion failure:failureBlock];
}

+ (void)launchSynchronouslyForAPIKey:(NSString *) apiKey timeout:(NSTimeInterval)timeout {
    NSParameterAssert(apiKey);
    [self setUpForKey:apiKey isAsync:NO timeout:timeout completion:nil failure:nil];
}

+ (id)variationForKey:(NSString*)key {
    NSParameterAssert(key);
    return [[VWOController sharedInstance] variationForKey:key];
}

+ (id)variationForKey:(NSString*)key defaultValue:(id)defaultValue {
    NSParameterAssert(key);
    NSParameterAssert(defaultValue);
    id object = [self variationForKey:key];
    if (!object) return defaultValue;
    return object;
}

+ (void)markConversionForGoal:(NSString*)goal {
    NSParameterAssert(goal);
    [[VWOController sharedInstance] markConversionForGoal:goal withValue:nil];
}

+ (void)markConversionForGoal:(NSString*)goal withValue:(double)value {
    NSParameterAssert(goal);
    [[VWOController sharedInstance] markConversionForGoal:goal withValue:[NSNumber numberWithDouble:value]];
}

+ (void)setCustomVariable:(NSString *)key withValue:(NSString *)value {
    NSParameterAssert(key);
    NSParameterAssert(value);
    [VWOController.sharedInstance setCustomVariable:key withValue:value];
}

+ (NSString*)version {
    return VWOSDK.version;
}
@end
