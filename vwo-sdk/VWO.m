//
//  VWO.m
//  VWO
//
//  Created by Wingify on 17/09/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VWO.h"
#import "VAOModel.h"
#import "VAOController.h"
#import "VAORavenClient.h"
#import "VAOSocketClient.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import "VAOSDKInfo.h"
#import "VAODeviceInfo.h"

static VWOLogLevel kLogLevel = VWOLogLevelInfo;

@implementation VWO

+ (VWOLogLevel)logLevel {
    return kLogLevel;
}

+ (void)setLogLevel:(VWOLogLevel)level {
    kLogLevel = level;
}

+ (void)setUpForKey:(NSString *) key
            isAsync:(BOOL) async
         completion:(void (^)(void))completionBlock
            failure:(void (^)(void))failureBlock {
    static VWO *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{

        instance = [[self alloc] init];
        [VAOSDKInfo setAppKeyID:key];

        // set up sentry exception handling
        [self setupSentry];

        if (VAODeviceInfo.isAttachedToDebugger) {
            [[VAOSocketClient sharedInstance] launch];
        }
        VAOLogInfo(@"Initializing VWO");
        VAOLogDebug(@"Key: %@", key);
        [VAOController initializeAsynchronously:async withCallback:completionBlock failure:failureBlock];
    });
}

+ (void)setupSentry {
    NSDictionary *tags = @{@"VWO Account id" : VAOSDKInfo.accountID,
                           @"SDK Version" : VAOSDKInfo.sdkVersion};

    //CFBundleDisplayName & CFBundleIdentifier can be nil
    NSMutableDictionary *extras = [NSMutableDictionary new];
    extras[@"App Name"] = NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"];
    extras[@"BundleID"] = NSBundle.mainBundle.infoDictionary[@"CFBundleIdentifier"];

    NSString *DSN = @"https://c3f6ba4cf03548f3bd90066dd182a649:6d6d9593d15944849cc9f8d88ccf1fb0@sentry.io/41858";
    VAORavenClient *client = [VAORavenClient clientWithDSN:DSN extra:extras tags:tags];

    [VAORavenClient setSharedClient:client];
}

+ (void)launchForAPIKey:(NSString *) apiKey {
    NSParameterAssert(apiKey);
    [self setUpForKey:apiKey isAsync:YES completion:nil failure:nil];
}

+ (void)launchForAPIKey:(NSString *) apiKey completion:(void(^)(void))completion {
    NSParameterAssert(apiKey);
    [self setUpForKey:apiKey isAsync:YES completion:completion failure:nil];
}

+ (void)launchForAPIKey:(NSString *)apiKey completion:(void(^)(void))completion failure:(void (^)(void))failureBlock {
    NSParameterAssert(apiKey);
    [self setUpForKey:apiKey isAsync:YES completion:completion failure:failureBlock];
}

+ (void)launchSynchronouslyForAPIKey:(NSString *) apiKey {
    NSParameterAssert(apiKey);
    [self setUpForKey:apiKey isAsync:NO completion:nil failure:nil];
}

+ (id)variationForKey:(NSString*)key {
    NSParameterAssert(key);
    return [[VAOController sharedInstance] variationForKey:key];
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
    [[VAOController sharedInstance] markConversionForGoal:goal withValue:nil];
}

+ (void)markConversionForGoal:(NSString*)goal withValue:(double)value {
    NSParameterAssert(goal);
    [[VAOController sharedInstance] markConversionForGoal:goal withValue:[NSNumber numberWithDouble:value]];
}

+ (void)setCustomVariable:(NSString *)key withValue:(NSString *)value {
    NSParameterAssert(key);
    NSParameterAssert(value);
    [VAOController.sharedInstance setCustomVariable:key withValue:value];
}

+ (NSString*)version {
    return [VAOSDKInfo sdkVersion];
}
@end
