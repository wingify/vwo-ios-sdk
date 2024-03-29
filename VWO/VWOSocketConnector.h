//
//  VWOSocketConnector.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 28/03/18.
//  Copyright © 2018-2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 This class deals with the cases where Socket library is not imported
 It handles the case where only the core of VWO is installed
 */
@interface VWOSocketConnector : NSObject

@property (class, readonly) BOOL isConnectedToBrowser;
@property (class, readonly) BOOL isSocketLibraryAvailable;

+ (void)launchWithAppKey:(NSString *)appKey;
+ (void)goalTriggered:(NSString *)identifier withValue:(NSNumber *)value;

@end

NS_ASSUME_NONNULL_END
