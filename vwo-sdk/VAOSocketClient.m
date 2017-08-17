//
//  VAOSocketClient.m
//  VAO
//
//  Created by Wingify on 10/02/14.
//  Copyright (c) 2014 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOSocketClient.h"
#import "VAOSIOSocket.h"
#import "VAOController.h"
#import "VAOSDKInfo.h"
#import "VAOLogger.h"

#define kSocketIP @"https://mobilepreview.vwo.com:443"

@implementation VAOSocketClient{
    VAOSIOSocket *socket;
}

+ (instancetype)sharedInstance{
    static VAOSocketClient *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)launch {
    [VAOSIOSocket socketWithHost:kSocketIP response: ^(VAOSIOSocket *remoteSocket) {
        socket = remoteSocket;
        [self initMethods];
    }];
}

-(void)initMethods {
    __weak id socket_ = socket;
    socket.onConnect = ^{
        NSDictionary *dict  = @{@"name":[[UIDevice currentDevice] name],
                                @"type": @"iOS",
                                @"appKey": VAOSDKInfo.appKey};

        [socket_ emit:@"register_mobile" args:[NSArray arrayWithObject:dict]];
    };
    
    socket.onDisconnect = ^{
        VAOLogDebug(@"Socket disconnected");
        [[VAOController sharedInstance] setPreviewMode:NO];
    };
    
    socket.onConnectError = ^(NSDictionary *error) {
        VAOLogError(@"socket.onConnectError error {%@}", error);
    };
    
    socket.onError = ^(NSDictionary *error) {
        VAOLogError(@"Socket: %@", error);
    };
    
    [socket on:@"browser_connect" callback:^(SIOParameterArray *arguments) {
        VAOLogInfo(@"Socket browser connected");
        [[VAOController sharedInstance] setPreviewMode:YES];
        id object = [arguments firstObject];
        if (object && object[@"name"]) {
            VAOLogInfo(@"Preview mode: Connected with: '%@'", object[@"name"]);
        }
    }];

    [socket on:@"browser_disconnect" callback:^(SIOParameterArray *arguments) {
        VAOLogInfo(@"Preview mode Disconnected");
        [[VAOController sharedInstance] setPreviewMode:NO];
    }];
    
    [socket on:@"receive_variation" callback:^(SIOParameterArray *arguments) {
        VAOLogInfo(@"Variation received: {%@}", arguments);
        id expObject = [arguments firstObject];
        
        // check for sanity of expObject
        if (!expObject || !expObject[@"variationId"]) {
            VAOLogError(@"Received variation error");
        }
        
        [socket emit:@"receive_variation_success" args:[NSArray arrayWithObject:@{@"variationId":expObject[@"variationId"]}]];
        
        if (arguments.count) {
            [[VAOController sharedInstance] preview:[arguments firstObject]];
            VAOLogInfo(@"VWO: In preview mode. Variation Received: %@", [arguments firstObject][@"json"]);
        }
    }];
}

- (void)goalTriggered:(NSString *)identifier withValue:(NSNumber *)value {
    VAOLogInfo(@"Goal '%@' triggered for Socket with value %@", identifier, value);
    NSMutableDictionary *dict = [@{ @"goal" : identifier } mutableCopy];
    dict[@"value"] = value;//Does not set if value is nil
    [socket emit:@"goal_triggered" args:[NSArray arrayWithObject:dict]];
}

@end
