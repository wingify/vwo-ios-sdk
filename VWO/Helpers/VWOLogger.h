//
//  VWOLogger.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import <Foundation/Foundation.h>
#import "VWO.h"

/// Logic error. This must not go in release
void VWOLogException(NSString *format, ...);


static NSObject *loggingLockObject;
#define MAKE_LOG_FUNCTION(FUNCTION_NAME, LEVEL, LEVEL_SHORT_NAME) \
static inline void FUNCTION_NAME(NSString *format, ...) { \
if (VWO.logLevel > LEVEL) return; \
     @synchronized(loggingLockObject) { \
        va_list argList; \
        va_start(argList, format); \
        NSString* formattedMessage = [[NSString alloc] initWithFormat: format arguments: argList]; \
        va_end(argList); \
        NSLog(@"VWO %@: %s\n", LEVEL_SHORT_NAME, [formattedMessage UTF8String]);\
    }\
}

MAKE_LOG_FUNCTION(VWOLogDebug, VWOLogLevelDebug, @"DEB")
MAKE_LOG_FUNCTION(VWOLogInfo, VWOLogLevelInfo, @"INF")
MAKE_LOG_FUNCTION(VWOLogWarning, VWOLogLevelWarning, @"WAR")
MAKE_LOG_FUNCTION(VWOLogError, VWOLogLevelError, @"ERR")

#undef MAKE_LOG_FUNCTION
