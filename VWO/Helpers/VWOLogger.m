//
//  VWOLogger.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VWOLogger.h"
#import "VWORavenClient.h"

void VWOLogException(NSString *format, ...) {
    va_list argList;
    va_start(argList, format);
    NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList];
    va_end(argList);
#ifdef VWO_DEBUG
    // NSAssert will only work for objective c files. Hence NSCAssert
    NSCAssert(false, @"VWO EXCEPTION: %s\n", [formattedMessage UTF8String]);//Stops execution
#else
    [VWORavenClient.sharedClient captureMessage:formattedMessage];
#endif
}
