//
//  VWOSocketConnector.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 28/03/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

#import "VWOSocketConnector.h"
#import "VWODevice.h"

#if __has_include("VWOSocket.h")
#import "VWOSocket.h"
#endif

#define SOCKET_AVAILABLE __has_include("VWOSocket.h")

@implementation VWOSocketConnector

+ (BOOL)isConnectedToBrowser {
    #if SOCKET_AVAILABLE
    return VWOSocket.shared.connectedToBrowser;
    #endif

    return NO;
}

+ (BOOL)isSocketLibraryAvailable {
    #if SOCKET_AVAILABLE
    return YES;
    #else
    return NO;
    #endif
}

+ (void)launchWithAppKey:(NSString *)appKey {
    #if SOCKET_AVAILABLE
    [VWOSocket.shared launchWithAppKey:appKey
                              userName:VWODevice.userName];
    #endif
}

+ (void)goalTriggered:(NSString *)identifier withValue:(NSNumber *)value {
    #if SOCKET_AVAILABLE
    [VWOSocket.shared goalTriggered:identifier withValue:value];
    #endif
}

@end
