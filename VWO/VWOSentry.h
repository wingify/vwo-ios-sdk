//
//  VWOSentry.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 21/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VWOSentry : NSObject

+ (instancetype)sharedInstance;
- (void)logEvent:(NSString *)message;

@end
