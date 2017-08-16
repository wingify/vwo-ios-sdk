//
//  VAOSDKInfo.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//TODO: Rename to VAOSDK
@interface VAOSDKInfo : NSObject

//TODO: Rename to version
@property (class, readonly) NSString *sdkVersion;
@property (class, readonly) NSString *appKey;
@property (class, readonly) NSString *accountID;

+ (void)setAppKeyID:(NSString *) key;

@end

NS_ASSUME_NONNULL_END
