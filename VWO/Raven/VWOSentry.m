//
//  VWOSentry.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 21/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWOSentry.h"
#import "VWOSDK.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

@implementation VWOSentry {
    NSDateFormatter *_dateFormatter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:timeZone];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
    return self;
}

- (NSDictionary *)makeDictionary:(NSString *)message {
    struct utsname systemInfo;
    uname(&systemInfo);
    return @{
      @"event_id" : [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""],
      @"level" : @"fatal",
      @"message": message,
      @"platform" : @"objc",
      @"project" : @"41858",
      @"stacktrace" : @{},
      @"timestamp" : [_dateFormatter stringFromDate:[NSDate date]],
      @"tags": @{
              @"Build version" : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
              @"Device model"  : [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding],
              @"OS version"    : UIDevice.currentDevice.systemVersion,
              @"SDK Version"   : VWOSDK.version,
              @"VWO Account id": VWOSDK.accountID
              },
      @"extra" : @{
              @"BundleID" : NSBundle.mainBundle.infoDictionary[@"CFBundleIdentifier"],
              @"AppName" : NSBundle.mainBundle.infoDictionary[@"CFBundleDisplayName"]
              }
      };
}

- (void)logEvent:(NSString *)message {
    NSString *header = [NSString stringWithFormat:
                        @"Sentry sentry_version=4, sentry_client=raven-objc/0.5.0, sentry_timestamp=%ld, sentry_key=c3f6ba4cf03548f3bd90066dd182a649, sentry_secret=6d6d9593d15944849cc9f8d88ccf1fb0",
                        (long)[NSDate timeIntervalSinceReferenceDate]];

    NSDictionary *body = [self makeDictionary:message];
    NSData *data = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];

    NSURL *url = [NSURL URLWithString:@"https://sentry.io:443/api/41858/store/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];
    [request setValue:header forHTTPHeaderField:@"X-Sentry-Auth"];

    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {}
    }] resume];
}

+ (instancetype)sharedInstance {
    static VWOSentry *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end
