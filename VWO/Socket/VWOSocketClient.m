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

@implementation VWOSocketClient{
    VWOSIOSocket *socket;
}

+ (instancetype)sharedInstance{
    static VWOSocketClient *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)launch {
    [VWOSIOSocket socketWithHost:kSocketIP response: ^(VWOSIOSocket *remoteSocket) {
        socket = remoteSocket;
        [self initMethods];
    }];
}

-(void)initMethods {
    __weak id socket_ = socket;
    socket.onConnect = ^{
        NSDictionary *dict  = @{@"name":[[UIDevice currentDevice] name],
                                @"type": @"iOS",
                                @"appKey": VWOSDK.appKey};

        [socket_ emit:@"register_mobile" args:[NSArray arrayWithObject:dict]];
    };
    
    socket.onDisconnect = ^{
        VWOLogDebug(@"Socket disconnected");
        [VWOController.sharedInstance setPreviewMode:NO];
    };
    
    socket.onConnectError = ^(NSDictionary *error) {
        VWOLogError(@"socket.onConnectError error {%@}", error);
    };
    
    socket.onError = ^(NSDictionary *error) {
        VWOLogError(@"Socket: %@", error);
    };
    
    [socket on:@"browser_connect" callback:^(SIOParameterArray *arguments) {
        VWOLogInfo(@"Socket browser connected");
        [VWOController.sharedInstance setPreviewMode:YES];
        id object = [arguments firstObject];
        if (object && object[@"name"]) {
            VWOLogInfo(@"Preview mode: Connected with: '%@'", object[@"name"]);
        }
    }];

    [socket on:@"browser_disconnect" callback:^(SIOParameterArray *arguments) {
        VWOLogInfo(@"Preview mode Disconnected");
        [VWOController.sharedInstance setPreviewMode:NO];
    }];
    
    [socket on:@"receive_variation" callback:^(SIOParameterArray *arguments) {
        VWOLogInfo(@"Variation received: {%@}", arguments);
        id expObject = [arguments firstObject];
        
        // check for sanity of expObject
        if (!expObject || !expObject[@"variationId"]) {
            VWOLogError(@"Received variation error");
        }
        
        [socket emit:@"receive_variation_success" args:[NSArray arrayWithObject:@{@"variationId":expObject[@"variationId"]}]];
        
        if (arguments.count) {
            [VWOController.sharedInstance preview:[arguments firstObject]];
            VWOLogInfo(@"VWO: In preview mode. Variation Received: %@", [arguments firstObject][@"json"]);
        }
    }];
}

- (void)goalTriggered:(NSString *)identifier withValue:(NSNumber *)value {
    VWOLogInfo(@"Goal '%@' triggered for Socket with value %@", identifier, value);
    NSMutableDictionary *dict = [@{ @"goal" : identifier } mutableCopy];
    dict[@"value"] = value;//Does not set if value is nil
    [socket emit:@"goal_triggered" args:[NSArray arrayWithObject:dict]];
}

@end
