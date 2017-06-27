//
//  VAODeviceInfo.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VAODeviceInfo.h"
#import <sys/utsname.h>
#import <sys/types.h>
#import <sys/sysctl.h>

static NSString *kDefUUID = @"vaoUUID";

@implementation VAODeviceInfo

// Eg: @"iPhone7,2" on iPhone 6
// Eg: @"iPad3,4" - Wifi (model A1458)
+ (NSString *)deviceType {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}


/// Taken from https://github.com/plausiblelabs/plcrashreporter/blob/2dd862ce049e6f43feb355308dfc710f3af54c4d/Source/Crash%20Demo/main.m#L96
+ (BOOL)isAttachedToDebugger {

    //TODO: Make this local variable
    static BOOL debuggerIsAttached = NO;

    static dispatch_once_t debuggerPredicate;
    dispatch_once(&debuggerPredicate, ^{
        struct kinfo_proc info;
        size_t info_size = sizeof(info);
        int name[4];

        name[0] = CTL_KERN;
        name[1] = KERN_PROC;
        name[2] = KERN_PROC_PID;
        name[3] = getpid();

        if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
//            VAOLog(@"ERROR: Checking for a running debugger via sysctl() failed: %s", strerror(errno));
            debuggerIsAttached = false;
        }

        if (!debuggerIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0)
            debuggerIsAttached = true;
    });

    return debuggerIsAttached;
}


//Fetches UUID from persistent storage. If not available creates one
+ (NSString *)getUUID {
    //TODO: Make UUID persistant and return the same one
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:kDefUUID];
    if (uuid == nil) {
        NSString *newUuid = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [[NSUserDefaults standardUserDefaults] setObject:newUuid forKey:kDefUUID];
        return newUuid;
    }
    return uuid;
}

@end
