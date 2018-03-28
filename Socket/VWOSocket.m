//
//  VWOSocket.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 26/03/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import "VWOSocket.h"
#import "VWOController.h"
#import "VWOLogger.h"

@import SocketIO;

@implementation VWOSocket {
    SocketManager* manager;
}

+ (instancetype)shared {
    static VWOSocket *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
        instance.connectedToBrowser = NO;
    });
    return instance;
}

- (void)launchWithAppKey:(NSString *)appKey userName:(NSString *)deviceName {
    if (manager.defaultSocket.status == SocketIOStatusConnected ||
        manager.defaultSocket.status == SocketIOStatusConnecting) {
        VWOLogWarning(@"Already connected or connecting");
        return;
    }
    
    NSURL* url = [[NSURL alloc] initWithString:@"https://mobilepreview.vwo.com:443"];
    manager = [[SocketManager alloc] initWithSocketURL:url config:nil];
    SocketIOClient *socket = manager.defaultSocket;
    NSDictionary *dict = @{@"name" : deviceName,//[[UIDevice currentDevice] name],
                           @"type" : @"iOS",
                           @"appKey" : appKey};

    [socket on:@"connect" callback:^(NSArray *data, SocketAckEmitter *ack) {
        [socket emit:@"register_mobile" with:@[dict]];
        VWOLogDebug(@"socket connected");
    }];

    [socket on:@"browser_connect" callback:^(NSArray *data, SocketAckEmitter *ack) {
        self.connectedToBrowser = YES;
        VWOLogInfo(@"socket connected to browser %@", data.firstObject);
    }];

    [socket on:@"browser_disconnect" callback:^(NSArray *data, SocketAckEmitter *ack) {
        self.connectedToBrowser = NO;
        VWOLogInfo(@"Browser disconnected ");
    }];

    [socket on:@"receive_variation" callback:^(NSArray *data, SocketAckEmitter *ack) {
        VWOLogInfo(@"Variation received: {%@}", data);
        id variationData = data.firstObject;

        NSDictionary *changes = ((NSDictionary *)data.firstObject)[@"json"];
        if (changes) {
            VWOController.shared.previewInfo = changes;
        }

        [socket emit:@"receive_variation_success" with:@[@{@"variationId":variationData[@"variationId"]}]];
    }];

    [socket connect];
}

- (void)goalTriggered:(NSString *)identifier withValue:(NSNumber *)value {
    VWOLogDebug(@"Goal '%@' triggered for socket connection with value %@", identifier, value);
    NSMutableDictionary *dict = [@{ @"goal" : identifier } mutableCopy];
    dict[@"value"] = value;//Does not set if value is nil
    [manager.defaultSocket emit:@"goal_triggered" with:@[dict]];
}

@end
