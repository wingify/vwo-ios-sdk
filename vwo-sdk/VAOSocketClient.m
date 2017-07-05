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
#import "VAOUtils.h"
#import "VAOSDKInfo.h"

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
        [VAOLogger info:[NSString stringWithFormat:@"[[UIDevice currentDevice] name] = %@", [[UIDevice currentDevice] name]]];
        NSDictionary *dict  = @{@"name":[[UIDevice currentDevice] name],
                                @"type": @"iOS",
                                @"appKey": VAOSDKInfo.appKey};

        [socket_ emit:@"register_mobile" args:[NSArray arrayWithObject:dict]];
    };
    
    socket.onDisconnect = ^{
        [VAOLogger info:@"Socket disconnected"];
        [[VAOController sharedInstance] applicationDidExitPreviewMode];
    };
    
    socket.onConnectError = ^(NSDictionary *error) {
        [VAOLogger errorStr:[NSString stringWithFormat:@"error in connection = %@", error]];
    };
    
    socket.onError = ^(NSDictionary *error) {
        [VAOLogger errorStr:[NSString stringWithFormat:@"error = %@", error]];
    };
    
    [socket on:@"browser_connect" callback:^(SIOParameterArray *arguments) {
        [VAOLogger info:@"In browser connect"];
        [[VAOController sharedInstance] applicationDidEnterPreviewMode];
        id object = [arguments firstObject];
        if (object && object[@"name"]) {
            NSLog(@"VWO: In preview mode. Connected with:%@", object[@"name"]);
        }
    }];

    [socket on:@"browser_disconnect" callback:^(SIOParameterArray *arguments) {
        [VAOLogger info:@"In preview mode. Disconnected"];
        [[VAOController sharedInstance] applicationDidExitPreviewMode];
    }];
    
    [socket on:@"receive_variation" callback:^(SIOParameterArray *arguments) {
        [VAOLogger info:[NSString stringWithFormat:@"receive_variation arugments = %@", arguments]];
        id expObject = [arguments firstObject];
        
        // check for sanity of expObject
        if (!expObject || !expObject[@"variationId"]) {
            [VAOLogger info:@"Received variation error"];
        }
        
        [socket emit:@"receive_variation_success" args:[NSArray arrayWithObject:@{@"variationId":expObject[@"variationId"]}]];
        
        if (arguments.count) {
            [[VAOController sharedInstance] preview:[arguments firstObject]];
            
            NSLog(@"VWO: In preview mode. Variation Received :%@", [arguments firstObject][@"json"]);
        }
    }];
}

- (void)goalTriggeredWithName:(NSString*)goal {
    NSDictionary *dict = @{@"goal":goal};
    [socket emit:@"goal_triggered" args:[NSArray arrayWithObject:dict]];
}

- (void)goalTriggeredWithName:(NSString*)goal withValue:(double)value {
    NSDictionary *dict = @{@"goal":goal,
                           @"value":@(value)};
    [socket emit:@"goal_triggered" args:[NSArray arrayWithObject:dict]];
}

@end
