//
//  VWOLogger.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VWOLogger.h"
#import "VWORavenClient.h"
#import "VWO.h"

void VWOLogDebug(NSString *format, ...) {
    if (VWO.logLevel > VWOLogLevelDebug) return;
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
    NSLog(@"VWO debug: %s\n", [formattedMessage UTF8String]);
}

void VWOLogInfo(NSString *format, ...) {
    if (VWO.logLevel > VWOLogLevelInfo) return;
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
    NSLog(@"VWO info: %s\n", [formattedMessage UTF8String]);
}

void VWOLogWarning(NSString *format, ...) {
    if (VWO.logLevel > VWOLogLevelWarning) return;
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
    NSLog(@"VWO WARN: %s\n", [formattedMessage UTF8String]);
}

void VWOLogError(NSString *format, ...) {
    if (VWO.logLevel > VWOLogLevelError) return;
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
    NSLog(@"VWO ERR: %s\n", [formattedMessage UTF8String]);
}

void VWOLogException(NSString *format, ...) {
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
    [VWORavenClient.sharedClient captureMessage:formattedMessage];
    NSLog(@"VWO EXCEPTION: %s\n", [formattedMessage UTF8String]);
    assert(false);//Stops execution
}
