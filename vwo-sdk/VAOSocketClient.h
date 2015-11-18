//
//  VAOSocketClient.h
//  VAO
//
//  Created by Wingify on 10/02/14.
//  Copyright (c) 2014 Wingify Software Pvt. Ltd. All rights reserved.
//
//
//  TCP Socket client for PyHub (PyHub is the mediator between vao.com editor and this VAO SDK)
//

#import <Foundation/Foundation.h>

@interface VAOSocketClient : NSObject

+ (instancetype)sharedInstance;
- (void)launch;
- (void)goalTriggeredWithName:(NSString*)goal;
- (void)goalTriggeredWithName:(NSString*)goal withValue:(double)value;
@end
