//
//  VAOLogger.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VAOLogger.h"

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

+ (void)error:(NSString *) error {
    NSLog(@"ERROR: %@", error);
    //Send to sentry
}

@end
