//
//  VAOLogger.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VWOLogLevel) {
    VWOLogLevelNone,
    VWOLogLevelDebug,
    VWOLogLevelInfo,
    VWOLogLevelWarning,
    VWOLogLevelError,
};

/// Debug logs
void VAOLogDebug(NSString *format, ...);

/// General Information Logs
void VAOLogInfo(NSString *format, ...);

/// Warnings. Execution is not halted
void VAOLogWarning(NSString *format, ...);

/// Error. Execution will be halted
void VAOLogError(NSString *format, ...);

/// Logic error. This must not go in release
/// Would crash in development mode.
/// Print in release mode.
void VAOLogException(NSString *format, ...);
