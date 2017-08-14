//
//  VAOSDKInfo.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VAOSDKInfo.h"
#import "VAOPersistantStore.h"

static NSString *appKey;
static NSString *accountId;

@implementation VAOSDKInfo

+ (NSString *)sdkVersion {
    //TODO: Put it in persistent storage or plist
    return @"2.0.0-beta1";
}

+ (void)setAppKeyID:(NSString *) key {
    NSArray<NSString *> *separatedArray = [key componentsSeparatedByString:@"-"];
    [self validateAPIKey:key];

    appKey = separatedArray[0];
    accountId = separatedArray[1];
}

///Key must be in format `[32Chars]-[NUMS]`
+ (void)validateAPIKey:(NSString * )apiKey {
    NSArray<NSString *> *key_id = [apiKey componentsSeparatedByString:@"-"];
    NSAssert(key_id.count == 2, @"Invalid key");
    NSAssert(key_id.firstObject.length == 32, @"Invalid key");
}

+ (NSString *)appKey {
    return appKey;
}

+ (NSString *)accountID {
    return accountId;
}

@end
