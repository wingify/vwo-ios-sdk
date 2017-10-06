//
//  VWOConfig.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 06/10/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWOConfig.h"

@implementation VWOConfig

- (instancetype)initWithAccountID:(NSString *)accountID
                           appKey:(NSString *)appKey
                       sdkVersion:(NSString *)sdkVersion {
    if (self = [super init]) {
        _accountID = accountID;
        _appKey = appKey;
        sdkVersion = sdkVersion;
    }
    return self;
}
@end
