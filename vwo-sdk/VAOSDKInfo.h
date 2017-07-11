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

@property (class, readonly) NSString *sdkVersion;
@property (class, readonly) NSString *appKey;
@property (class, readonly) NSString *accountID;

+ (void)setAppKeyID:(NSString *) key;

@end
