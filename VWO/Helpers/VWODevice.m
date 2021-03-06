//
//  VWODevice.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VWODevice.h"
#import <sys/utsname.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>

@implementation VWODevice

/// Tells if the Device is connected to Xcode
/// Taken from https://github.com/plausiblelabs/plcrashreporter/blob/2dd862ce049e6f43feb355308dfc710f3af54c4d/Source/Crash%20Demo/main.m#L96
+ (BOOL)isAttachedToDebugger {

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
            debuggerIsAttached = false;
        }

        if (!debuggerIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0)
            debuggerIsAttached = true;
    });

    return debuggerIsAttached;
}

+ (VWOAppleDeviceType)appleDeviceType {
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return VWOAppleDeviceTypeIPhone;
    }
    return VWOAppleDeviceTypeIPad;
}

+ (NSString *)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine
                                               encoding:NSUTF8StringEncoding];
    return deviceModel;
}

+ (NSString *)userName {
    return UIDevice.currentDevice.name;
}

+ (NSString *)iOSVersion {
    return UIDevice.currentDevice.systemVersion;
}

+ (int)screenWidth {
    return UIScreen.mainScreen.bounds.size.width;
}

+(int)screenHeight {
    return UIScreen.mainScreen.bounds.size.height;
}

@end
