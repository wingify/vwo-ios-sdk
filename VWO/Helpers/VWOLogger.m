//
//  VWOLogger.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VWOLogger.h"
#import "VWORavenClient.h"
#import "VWOController.h"
#import "VWOConfig.h"
#import "VWODevice.h"

@interface GrayLog: NSObject
+ (void)sendMessage:(NSString *)message;
@end

void VWOLogException(NSString *format, ...) {
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
#ifdef VWO_DEBUG
    // NSAssert will only work for objective c files. Hence NSCAssert
    NSCAssert(false, @"VWO EXCEPTION: %s\n", [formattedMessage UTF8String]);//Stops execution
#else
    [GrayLog sendMessage:formattedMessage];
#endif
}

@implementation GrayLog: NSObject
+ (void)sendMessage:(NSString *)message {
    VWOConfig *config = VWOController.shared.config;
    if (config == nil) { return;}

    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    if (bundleIdentifier == nil) { bundleIdentifier = @"-"; }

    NSURL *url = [NSURL URLWithString:@"https://postman-echo.com/post"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

        //Header -> "App-Key", "Account-ID", "Device-Type"
    [request setValue:config.appKey forHTTPHeaderField:@"App-Key"]; // Left part of API Key
    [request setValue:config.accountID forHTTPHeaderField:@"Account-ID"]; //Right part of API Key
    [request setValue:@"iOS" forHTTPHeaderField:@"Device-Type"]; //
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];

    NSDictionary *dict = @{
                           @"Date" : NSDate.date,
                           @"Message" : message,
                           @"iOS-Model" : @"",
                           @"SDK Version" : kSDKversion,
                           @"UUID" : config.UUID,
                           @"iOS Version" : VWODevice.iOSVersion,
                           @"App Bundle" : bundleIdentifier
                           };
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (error != nil) { return;}
    [request setHTTPBody:postData];
    [[NSURLSession.sharedSession dataTaskWithRequest:request] resume];
}
@end
