//
//  VAO.m
//  VAO
//
//  Created by Wingify on 17/09/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VWO.h"
#import "VAOAPIClient.h"
#import "VAOUtils.h"
#import "VAOModel.h"
#import "VAOController.h"
#import "VAORavenClient.h"
#import "VAOSocketClient.h"
#import <sys/types.h>
#import <sys/sysctl.h>

@implementation VWO

/**
 * Call to this function kickstarts VAO. This should be called as early as possible in application life cycle.
 * Currently, it gets called in  application:willFinishLaunchingWithOptions:
 * See if we can call it in main(), before we call UIApplicationMain()? (see:
 * https://developer.apple.com/library/ios/documentation/iphone/conceptual/iphoneosprogrammingguide/ManagingYourApplicationsFlow/ManagingYourApplicationsFlow.html#//apple_ref/doc/uid/TP40007072-CH4-SW7 )
 */
+ (void)setupAsynchronously:(BOOL)async withCallback:(void (^)(void))completionBlock {
    static VWO *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        
        if([self isOptOut]){
            return;
        }
        
        instance = [[self alloc] init];
            
        // get values for various parameters and initialize singletons
        NSString *accountId = [VAOUtils vaoAccountId];
        if([accountId isKindOfClass:NSString.class] == NO){
            NSLog(@"|------------------------------------------------------------------------|");
            NSLog(@"|------VWO: Check if you have VWOAppKey in your info.plist file ------|");
            NSLog(@"|------------------------------------------------------------------------|");
            return;
        }
        
        NSString *accountIdStr = accountId;
        
        // check if accountId is valid or not
        if(accountIdStr.length == 0){
            return;
        }
        
        // set and increment session
        [VAOUtils incrementSessionNumber];
        
        NSString *bunldeId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        
        [[VAOAPIClient sharedInstance] schedule];

        if ([VWO isDebuggerAttached]) {
            [[VAOSocketClient sharedInstance] launch];
        }
        
        [VAOController initializeAsynchronously:async withCallback:completionBlock];
            
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:[VAOController sharedInstance]
                               selector:@selector(applicationDidEnterBackground)
                                   name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notificationCenter addObserver:[VAOController sharedInstance]
                               selector:@selector(applicationWillEnterForeground)
                                   name:UIApplicationWillEnterForegroundNotification object:nil];
        
        
        NSLog(@"|------------------------------------------------------------------------|");
        NSLog(@"|------                     VWO Initialized                        ------|");
        NSLog(@"|------------------------------------------------------------------------|");

            
        // set up Exception Handling
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSDictionary *tags = [NSDictionary dictionaryWithObjectsAndKeys:accountId, @"VAO Account Id", nil];
        NSDictionary *extra = [NSDictionary dictionaryWithObjectsAndKeys:bunldeId, @"Bundle Identifier",
                                                                        appName, @"App Name", nil];
        VAORavenClient *client = [VAORavenClient clientWithDSN:@"https://624c0b4aad0d4bf9b0831f421efdbf48:881e3ff45bc64c55bd4e59ed42e9c8eb@app.getsentry.com/41858"
                                                         extra:extra
                                                          tags:tags];
        
        [client setupExceptionHandler];
        [VAORavenClient setSharedClient:client];
        
    });
}

/**
 * Check if the debugger is attached
 *
 * Taken from https://github.com/plausiblelabs/plcrashreporter/blob/2dd862ce049e6f43feb355308dfc710f3af54c4d/Source/Crash%20Demo/main.m#L96
 *
 * @return `YES` if the debugger is attached to the current process, `NO` otherwise
 */
+ (BOOL)isDebuggerAttached {
    static BOOL debuggerIsAttached = NO;
    
    static dispatch_once_t debuggerPredicate;
    dispatch_once(&debuggerPredicate, ^{
        struct kinfo_proc info;
        size_t info_size = sizeof(info);
        int name[4];
        
        name[0] = CTL_KERN;
        name[1] = KERN_PROC;
        name[2] = KERN_PROC_PID;
        name[3] = getpid();
        
        if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
            VAOLog(@"[HockeySDK] ERROR: Checking for a running debugger via sysctl() failed: %s", strerror(errno));
            debuggerIsAttached = false;
        }
        
        if (!debuggerIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0)
            debuggerIsAttached = true;
    });
    
    return debuggerIsAttached;
}

+ (void)setOptOut:(BOOL)status {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL optOut = [[defaults objectForKey:@"vaoOptOut"] boolValue];
    if(optOut != status){
        [defaults setValue:@(status) forKey:@"vaoOptOut"];
        [defaults synchronize];

        [[VAOAPIClient sharedInstance] optOut:status];
    }
}

+ (BOOL)isOptOut {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL optOut = [[defaults objectForKey:@"vaoOptOut"] boolValue];
    return optOut;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)launchVWO {
    [self setupAsynchronously:YES withCallback:nil];
}

+ (void)launchVWOWithCallback:(void (^)(void))completionBlock {
    [self setupAsynchronously:YES withCallback:completionBlock];
}

+ (void)launchVWOSynchronously {
    [self setupAsynchronously:NO withCallback:nil];
}

+ (NSDictionary*)allObjects {
    return [[VAOController sharedInstance] allObjects];
}

+ (id)objectForKey:(NSString*)key {
    return [[VAOController sharedInstance] objectForKey:key];
}

+ (id)objectForKey:(NSString*)key defaultObject:(id)defaultObject {
    id object = [self objectForKey:key];
    if (!object) {
        object = defaultObject;
    }
    return object;
}

+ (void)markConversionForGoal:(NSString*)goal {
    [[VAOController sharedInstance] markConversionForGoal:goal withValue:nil];
}

+ (void)markConversionForGoal:(NSString*)goal withValue:(double)value {
    [[VAOController sharedInstance] markConversionForGoal:goal withValue:[NSNumber numberWithDouble:value]];
}

+ (void)setValue:(NSString*)value forCusomtorVariable:(NSString*)variable {
    [[VAOController sharedInstance] setValue:value forCusomtorVariable:variable];
}

+ (NSString*)sdkVersion {
    return VWO_SDK_VERSION;
}
@end
