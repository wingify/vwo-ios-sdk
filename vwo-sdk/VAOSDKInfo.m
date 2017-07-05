//
//  VAOSDKInfo.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 27/06/17.
//
//

#import "VAOSDKInfo.h"

static NSString *kDefSessionCount = @"VWOSessionCount";
static NSString *kDefReturningVisitor = @"VWOReturningVisitor";

static NSString *appKey;
static NSString *accountId;

@implementation VAOSDKInfo

+ (NSString *)sdkVersion {
    //TODO: Put it in persistent storage or plist
    return @"1.5.0";
}

+ (void)setAppKeyID:(NSString *) key {
    NSArray<NSString *> *separatedArray = [key componentsSeparatedByString:@"-"];
    if ([separatedArray count] != 2) {
        //TODO: Log Error - invalid key
        return;
    }
    appKey = separatedArray[0];
    accountId = separatedArray[1];
    [self incrementSessionCount];
}

+ (NSString *)appKey {
    return appKey;
}

+ (NSString *)accountID {
    return accountId;
}

+ (void)incrementSessionCount {
    NSInteger sessionCount = [[NSUserDefaults standardUserDefaults] integerForKey:kDefSessionCount];
    sessionCount += 1;
    [[NSUserDefaults standardUserDefaults] setInteger:sessionCount forKey: kDefSessionCount];
}

+ (NSNumber *)sessionCount {
    NSInteger num = [[NSUserDefaults standardUserDefaults] integerForKey: kDefSessionCount];
    return [NSNumber numberWithInteger:num];
}

+ (void) setReturningVisitor:(BOOL) isReturningVisitor {
    return [[NSUserDefaults standardUserDefaults] setBool:isReturningVisitor forKey: kDefReturningVisitor];
}

+ (BOOL)isReturningVisitor {
    return [[NSUserDefaults standardUserDefaults] boolForKey: kDefReturningVisitor];
};

@end
