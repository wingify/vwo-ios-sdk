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
        VAOLog(@"print this on successful connection");
        VAOLog(@"[[UIDevice currentDevice] name] = %@", [[UIDevice currentDevice] name] );
        NSDictionary *dict  = @{@"name":[[UIDevice currentDevice] name],
                                @"type": @"iOS",
                                @"appKey": [VAOUtils vaoAppKey]};
        
        [socket_ emit:@"register_mobile" args:[NSArray arrayWithObject:dict]];
    };
    
    socket.onDisconnect = ^{
        VAOLog(@"socket disconnected");
        [[VAOController sharedInstance] applicationDidExitPreviewMode];
    };
    
    socket.onConnectError = ^(NSDictionary *error) {
        VAOLog(@"error in connection = %@", error);
    };
    
    socket.onError = ^(NSDictionary *error) {
        VAOLog(@"error = %@", error);
    };
    
    [socket on:@"browser_connect" callback:^(SIOParameterArray *arguments) {
        VAOLog(@"in browser_connect");
        [[VAOController sharedInstance] applicationDidEnterPreviewMode];
        id object = [arguments firstObject];
        if (object && object[@"name"]) {
            NSLog(@"|------------------------------------------------------------------------|");
            NSLog(@"|------         VWO: In preview mode. Connected with:%@            ------|", object[@"name"]);
            NSLog(@"|------------------------------------------------------------------------|");
        }
    }];

    [socket on:@"browser_disconnect" callback:^(SIOParameterArray *arguments) {
        VAOLog(@"in browser_disconnect");
        NSLog(@"|------------------------------------------------------------------------|");
        NSLog(@"|------         VWO: In preview mode. DIS Connected                ------|");
        NSLog(@"|------------------------------------------------------------------------|");
        [[VAOController sharedInstance] applicationDidExitPreviewMode];
    }];
    
    [socket on:@"receive_variation" callback:^(SIOParameterArray *arguments) {
        
        VAOLog(@"receive_variation arugments = %@", arguments);
        id expObject = [arguments firstObject];
        
        // check for sanity of expObject
        if (!expObject || !expObject[@"variationId"]) {
            VAOLog(@"receive_variation ERROR");
        }
        
        [socket emit:@"receive_variation_success" args:[NSArray arrayWithObject:@{@"variationId":expObject[@"variationId"]}]];
        
        if (arguments.count) {
            [[VAOController sharedInstance] previewMeta:[arguments firstObject]];
            
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
