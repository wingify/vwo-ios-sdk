//
//  VWOSocketClient.h
//  VWO
//
//  Created by Wingify on 10/02/14.
//  Copyright (c) 2014 Wingify Software Pvt. Ltd. All rights reserved.
//
//
//  TCP Socket client for PyHub (PyHub is the mediator between VWO.com editor and this VWO SDK)
//

#import <Foundation/Foundation.h>

@interface VWOSocketClient : NSObject

+ (instancetype)sharedInstance;
- (void)launch;
- (void)goalTriggered:(NSString *)identifier withValue:(NSNumber *)value;

@end
