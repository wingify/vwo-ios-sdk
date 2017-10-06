//
//  VWOConfig.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 06/10/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOConfig : NSObject

@property (readonly) NSString *accountID;
@property (readonly) NSString *appKey;
@property (readonly) NSString *sdkVersion;

- (instancetype)initWithAccountID:(NSString *)accountID
                           appKey:(NSString *)appKey
                       sdkVersion:(NSString *)sdkVersion;

@end

NS_ASSUME_NONNULL_END
