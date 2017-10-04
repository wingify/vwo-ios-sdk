//
//  VWOSocketClient.m
//  VWO
//
//  Created by Wingify on 10/02/14.
//  Copyright (c) 2014 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VWOSocketClient.h"
#import "VWOSIOSocket.h"
#import "VWOController.h"
#import "VWOSDK.h"
#import "VWOLogger.h"
#import <UIKit/UIKit.h>

#define kSocketIP @"https://mobilepreview.vwo.com:443"

@interface VWOSocketClient()

@property VWOSIOSocket *socket;

@end

@implementation VWOSocketClient

+ (instancetype)shared {
    static VWOSocketClient *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
        instance.enabled = NO;
    });
    return instance;
}

- (void)launch {
    [VWOSIOSocket socketWithHost:kSocketIP response: ^(VWOSIOSocket *remoteSocket) {
        _socket = remoteSocket;
        [self startListeners];
    }];
}

- (void)startListeners {
    __weak id socket_ = _socket;
    _socket.onConnect = ^{
        NSDictionary *dict  = @{@"name":[[UIDevice currentDevice] name],
                                @"type": @"iOS",
                                @"appKey": VWOSDK.appKey};

        [socket_ emit:@"register_mobile" args:[NSArray arrayWithObject:dict]];
    };
    
    _socket.onDisconnect = ^{
        VWOLogDebug(@"Socket disconnected");
        _enabled = NO;
    };
    
    _socket.onConnectError = ^(NSDictionary *error) {
        VWOLogError(@"socket.onConnectError error {%@}", error);
    };
    
    _socket.onError = ^(NSDictionary *error) {
        VWOLogError(@"Socket: %@", error);
    };
    
    [_socket on:@"browser_connect" callback:^(SIOParameterArray *arguments) {
        VWOLogInfo(@"Socket browser connected");
        _enabled = YES;
        id object = [arguments firstObject];
        if (object && object[@"name"]) {
            VWOLogInfo(@"Preview mode: Connected with: '%@'", object[@"name"]);
        }
    }];

    [_socket on:@"browser_disconnect" callback:^(SIOParameterArray *arguments) {
        VWOLogInfo(@"Preview mode Disconnected");
        _enabled = NO;
    }];
    
    [_socket on:@"receive_variation" callback:^(SIOParameterArray *arguments) {
        VWOLogInfo(@"Variation received: {%@}", arguments);
        id expObject = [arguments firstObject];
        
        // check for sanity of expObject
        if (!expObject || !expObject[@"variationId"]) {
            VWOLogError(@"Received variation error");
        }
        
        [_socket emit:@"receive_variation_success" args:[NSArray arrayWithObject:@{@"variationId":expObject[@"variationId"]}]];
        
        if (arguments.count > 0) {
            NSDictionary *changes = ((NSDictionary *)arguments.firstObject)[@"json"];
            VWOController.sharedInstance.previewInfo = changes;
            VWOLogInfo(@"VWO: In preview mode. Variation Received: %@", [arguments firstObject][@"json"]);
        }
    }];
}

- (void)goalTriggered:(NSString *)identifier withValue:(NSNumber *)value {
    VWOLogInfo(@"Goal '%@' triggered for Socket with value %@", identifier, value);
    NSMutableDictionary *dict = [@{ @"goal" : identifier } mutableCopy];
    dict[@"value"] = value;//Does not set if value is nil
    [_socket emit:@"goal_triggered" args:[NSArray arrayWithObject:dict]];
}

@end
