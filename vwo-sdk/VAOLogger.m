//
//  VAOLogger.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VAOLogger.h"
#import "VAORavenClient.h"

//enum LogLevel {
//    case none, info, warning, error
//};

void VAOLogInfo(NSString *format, ...) {
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
    printf("VWO info: %s\n", [formattedMessage UTF8String]);
}

void VAOLogWarning(NSString *format, ...) {
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
    printf("VWO WARN: %s\n", [formattedMessage UTF8String]);
}

void VAOLogError(NSString *format, ...) {
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
    printf("VWO ERR: %s\n", [formattedMessage UTF8String]);
}

void VAOLogException(NSString *format, ...) {
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
    [VAORavenClient.sharedClient captureMessage:formattedMessage];
    assert(false);//Stops execution
}
