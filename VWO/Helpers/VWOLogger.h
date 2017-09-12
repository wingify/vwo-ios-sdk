//
//  VWOLogger.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VWOLogLevel) {
    VWOLogLevelDebug,
    VWOLogLevelInfo,
    VWOLogLevelWarning,
    VWOLogLevelError,
    VWOLogLevelNone,
};

/// Debug logs
void VWOLogDebug(NSString *format, ...);

/// General Information Logs
void VWOLogInfo(NSString *format, ...);

/// Warnings. Execution is not halted
void VWOLogWarning(NSString *format, ...);

/// Error. Execution will be halted
void VWOLogError(NSString *format, ...);

/// Logic error. This must not go in release
/// Would crash in development mode.
/// Print in release mode.
void VWOLogException(NSString *format, ...);
