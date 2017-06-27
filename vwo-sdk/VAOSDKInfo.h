//
//  VAOSDKInfo.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import <Foundation/Foundation.h>

//Any information that is related to VWO will be handled by this class
@interface VAOSDKInfo : NSObject

@property (class) NSString *appKey;
@property (class) NSString *vwoAccountId;
@property (class, readonly) NSString *sdkVersion;


+ (void)setAppKeyAndID:(NSString *) key;
+ (void)incrementSessionCount;
+ (int)sessionCount;
+ (BOOL)isNewUser;

@end
