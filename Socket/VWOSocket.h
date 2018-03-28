//
//  VWOSocket.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 26/03/18.
//  Copyright © 2018 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOSocket : NSObject

//This class must be used only as a singleton
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (assign) BOOL connectedToBrowser;

+ (instancetype)shared;
- (void)launchWithAppKey:(NSString *)appKey userName:(NSString *)deviceName;
- (void)goalTriggered:(NSString *)identifier withValue:(NSNumber *)value;

@end

NS_ASSUME_NONNULL_END
