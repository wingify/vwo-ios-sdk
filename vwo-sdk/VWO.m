//
//  VWO.m
//  VWO
//
//  Created by Wingify on 17/09/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VWO.h"
#import "VAOAPIClient.h"
#import "VAOModel.h"
#import "VAOController.h"
#import "VAORavenClient.h"
#import "VAOSocketClient.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import "VAOSDKInfo.h"
#import "VAODeviceInfo.h"

@implementation VWO

/**
 * Call to this function kickstarts VWO. This should be called as early as possible in application life cycle.
 * Currently, it gets called in  application:willFinishLaunchingWithOptions:
 * See if we can call it in main(), before we call UIApplicationMain()? (see:
 * https://developer.apple.com/library/ios/documentation/iphone/conceptual/iphoneosprogrammingguide/ManagingYourApplicationsFlow/ManagingYourApplicationsFlow.html#//apple_ref/doc/uid/TP40007072-CH4-SW7 )
 */
+ (void)setUpForKey:(NSString *) key isAsync:(BOOL) async completion:(void (^)(void))completionBlock {
    static VWO *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
                
        instance = [[self alloc] init];
        [VAOSDKInfo setAppKeyID:key];
        
        // set up sentry exception handling
        [self setupSentry:VAOSDKInfo.accountID];
        
        [[VAOAPIClient sharedInstance] schedule];

        if ([VAODeviceInfo isAttachedToDebugger]) {
            [[VAOSocketClient sharedInstance] launch];
        }
        
        [VAOController initializeAsynchronously:async withCallback:completionBlock];
        NSLog(@"VWO Initialized");
    });
}

+ (void)setupSentry:(NSString*)accountId {
    NSString *bunldeId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSDictionary *tags = [NSDictionary dictionaryWithObjectsAndKeys:accountId, @"VAO Account Id", nil];
    NSDictionary *extra = [NSDictionary dictionaryWithObjectsAndKeys:bunldeId, @"Bundle Identifier",
                           appName, @"App Name",
                           [self sdkVersion], @"SDK Version", nil];
    
    VAORavenClient *client = [VAORavenClient clientWithDSN:@"https://c3f6ba4cf03548f3bd90066dd182a649:6d6d9593d15944849cc9f8d88ccf1fb0@sentry.io/41858"
                                                     extra:extra
                                                      tags:tags];
    
    [VAORavenClient setSharedClient:client];
}

+ (void)launchForAPIKey:(NSString *) key {
    [self setUpForKey:key isAsync:YES completion:nil];
}

+ (void)launchForAPIKey:(NSString *) key completion:(void(^)(void))completionBlock {
    [self setUpForKey:key isAsync:YES completion:completionBlock];
}

+ (void)launchSynchronouslyForAPIKey:(NSString *) key {
    [self setUpForKey:key isAsync:NO completion:nil];
}

+ (id)variationForKey:(NSString*)key {
    return [[VAOController sharedInstance] variationForKey:key];
}

+ (id)variationForKey:(NSString*)key defaultObject:(id)defaultObject {
    id object = [self variationForKey:key];
    if (!object) {
        return defaultObject;
    }
    return object;
}

+ (void)markConversionForGoal:(NSString*)goal {
    [[VAOController sharedInstance] markConversionForGoal:goal withValue:nil];
}

+ (void)markConversionForGoal:(NSString*)goal withValue:(double)value {
    [[VAOController sharedInstance] markConversionForGoal:goal withValue:[NSNumber numberWithDouble:value]];
}

+ (void)trackUserManually {
    [[VAOController sharedInstance] trackUserManually];
}

+ (void)trackUserInCampaign:(NSString*)key {
    [[VAOController sharedInstance] trackUserInCampaign:key];
}

+ (void)setValue:(NSString*)value forCustomVariable:(NSString*)variable {
    [[VAOController sharedInstance] setValue:value forCustomVariable:variable];
}

+ (NSString*)sdkVersion {
    return [VAOSDKInfo sdkVersion];
}
@end
