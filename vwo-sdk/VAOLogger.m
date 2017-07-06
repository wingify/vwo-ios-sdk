//
//  VAOLogger.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VAOLogger.h"
#import "VAORavenClient.h"

@implementation VAOLogger

+ (instancetype)sharedManager {
    static VAOLogger *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
        _sharedInstance.enabled = TRUE;
    });

    return _sharedInstance;
}

+ (void)debug: (NSString *) debug {
   NSLog(@"%@", debug);
}
+ (void)info:(NSString *) info {
    NSLog(@"%@", info);
}

+ (void)warning:(NSString *) warning {
    NSLog(@"WARNING: %@", warning);
}

+ (void)error:(NSError *) error {
    NSLog(@"ERROR: %@", error);
    //Send to sentry
}

+ (void)errorStr:(NSString *) error {
    NSLog(@"ERROR: %@", error);
    //Send to sentry
}

+ (void)exception:(NSException *)exception {
    VAORavenCaptureException(exception);
    NSException *selfException = [[NSException alloc] initWithName:NSStringFromSelector(_cmd) reason:[exception description] userInfo:exception.userInfo];
    VAORavenCaptureException(selfException);
}


@end
