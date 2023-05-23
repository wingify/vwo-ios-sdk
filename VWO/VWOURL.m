//
//  VWOURL.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 15/09/17.
//  Copyright © 2017-2022 vwo. All rights reserved.
//

#import "VWOURL.h"
#import "VWOCampaign.h"
#import "VWOGoal.h"
#import "VWODevice.h"
#import "VWOUserDefaults.h"
#import "VWO.h"
#import "NSDictionary+VWO.h"
#import "NSString+MD5.h"
#import "VWOConstants.h"

@implementation NSURLComponents (VWO)
    /// Creates URL component with scheme host and path. Eg: https://dacdn.visual.com/path
+ (instancetype)vwoComponentForPath:(NSString *)path isChinaCDN:(BOOL)isChinaCDN {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:@"http"];
    if (isChinaCDN) {
        [components setHost:@"cdn-cn.vwo-analytics.com"];
    } else {
        [components setHost:@"dacdn.visualwebsiteoptimizer.com"];
    }
    [components setPath:path];
    return components;
}
@end

static NSString *kSDKversionNumber = @"19";

@interface VWOURL()

@property NSString *appKey;
@property NSString *accountID;
@property BOOL isChinaCDN;

@end

@implementation VWOURL

+ (instancetype)urlWithAppKey:(NSString *)appKey accountID:(NSString *)accountID isChinaCDN:(BOOL)isChinaCDN {
    return [[self alloc] initWithAppKey:appKey accountID:accountID isChinaCDN:isChinaCDN];
}

- (instancetype)initWithAppKey:(NSString *)appKey accountID:(NSString *)accountID isChinaCDN:(BOOL)isChinaCDN {
    NSParameterAssert(appKey != nil);
    NSParameterAssert(accountID != nil);
    self = [self init];
    if (self) {
        _appKey = appKey;
        _accountID = accountID;
        _isChinaCDN = isChinaCDN;
    }
    return self;
}

- (NSString *) randomNumber {
    return [NSString stringWithFormat:@"%f", ((double)arc4random_uniform(0xffffffff))/(0xffffffff - 1)];
}

- (NSDictionary *)extraParametersWithDate:(NSDate *)date {
    NSString *appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    if (appVersion == nil) { appVersion = @"NA"; }
    return @{@"lt" : [NSString stringWithFormat:@"%f", date.timeIntervalSince1970],
             @"v"  : kSDKversionNumber,
             @"i"  : _appKey,
             @"av" : appVersion,
             @"dt" : VWODevice.deviceName,//Device Type
             @"os" : VWODevice.iOSVersion
             };
}

#pragma mark - Public Methods

- (NSURL *)forFetchingCampaigns:(nullable NSString *)userID {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:@"/mobile" isChinaCDN:_isChinaCDN];
    NSMutableDictionary *paramDict =
    [@{@"api-version": ConstAPIVersion,
      @"a"          : _accountID,
      @"dt"         : VWODevice.deviceName,
      @"i"          : _appKey,
      @"k"          : VWOUserDefaults.campaignVariationPairs.toString,
      @"os"         : VWODevice.iOSVersion,
      @"r"          : [self randomNumber],
      @"u"          : VWOUserDefaults.UUID,
      @"v"          : kSDKversionNumber
      } mutableCopy];
    if (userID) {
        NSString * uHash = userID.generateMD5;
        paramDict[@"uHash"] = uHash;
        [VWOUserDefaults updateUUID:uHash];
    }
    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

- (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign
                              dateTime:(NSDate *)date
                              config:(VWOConfig *) config {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:@"/track-user" isChinaCDN:_isChinaCDN];
    if(VWOUserDefaults.CollectionPrefix != NULL && VWOUserDefaults.CollectionPrefix.length != 0){
        NSString *path = [NSString stringWithFormat: @"%@/track-user", VWOUserDefaults.CollectionPrefix];
        components = [NSURLComponents vwoComponentForPath:path isChinaCDN:_isChinaCDN];
    }
    
    NSMutableDictionary *paramDict =
    [@{@"experiment_id": [NSString stringWithFormat:@"%d", campaign.iD],
      @"account_id"   : _accountID,
      @"combination"  : [NSString stringWithFormat:@"%d", campaign.variation.iD],
      @"u"            : VWOUserDefaults.UUID,
      @"s"            : [NSString stringWithFormat:@"%lu", (unsigned long)VWOUserDefaults.sessionCount],
      @"random"       : [self randomNumber],
       @"sId"          : [NSString stringWithFormat:@"%lu", (unsigned long)date.timeIntervalSince1970],
      @"ed"           : [self extraParametersWithDate:date].toString
      } mutableCopy];
    if (config.customDimension != nil) {
        paramDict[@"tags"] = config.customDimension;
    }
    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

- (NSURL *)forMarkingGoal:(VWOGoal *)goal
                withValue:(NSNumber *)goalValue
                 campaign:(VWOCampaign *)campaign
                 dateTime:(NSDate *)date {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:@"/track-goal" isChinaCDN:_isChinaCDN];
    if(VWOUserDefaults.CollectionPrefix != NULL && VWOUserDefaults.CollectionPrefix.length != 0){
        NSString *path = [NSString stringWithFormat: @"%@/track-goal", VWOUserDefaults.CollectionPrefix];
        components = [NSURLComponents vwoComponentForPath:path isChinaCDN:_isChinaCDN];
    }
    
    NSMutableDictionary <NSString *, NSString *> *paramDict = [NSMutableDictionary new];
    paramDict[@"experiment_id"] = [NSString stringWithFormat:@"%d", campaign.iD];
    paramDict[@"account_id"]    = _accountID;
    paramDict[@"combination"]   = [NSString stringWithFormat:@"%d", campaign.variation.iD];
    paramDict[@"u"]             = VWOUserDefaults.UUID;
    paramDict[@"s"]             = [NSString stringWithFormat:@"%lu", (unsigned long)VWOUserDefaults.sessionCount];
    paramDict[@"random"]        = [self randomNumber];
    paramDict[@"sId"]           = [NSString stringWithFormat:@"%f", date.timeIntervalSince1970];
    paramDict[@"ed"]            = [self extraParametersWithDate:date].toString;
    paramDict[@"goal_id"]       = [NSString stringWithFormat:@"%d", goal.iD];

    if (goalValue != nil) {
        paramDict[@"r"] = [NSString stringWithFormat:@"%@", goalValue];
    }
    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

- (NSURL *)forPushingCustomDimension:(NSString *)customDimensionKey withCustomDimensionValue:(nonnull NSString *)customDimensionValue dateTime:(nonnull NSDate *)date {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:@"/mobile-app/push" isChinaCDN:_isChinaCDN];
    if(VWOUserDefaults.CollectionPrefix != NULL && VWOUserDefaults.CollectionPrefix.length != 0){
        NSString *path = [NSString stringWithFormat: @"%@/mobile-app/push", VWOUserDefaults.CollectionPrefix];
        components = [NSURLComponents vwoComponentForPath:path isChinaCDN:_isChinaCDN];
    }
    NSMutableDictionary <NSString *, NSString *> *paramDict = [NSMutableDictionary new];
    paramDict[@"account_id"]    = _accountID;
    paramDict[@"u"]             = VWOUserDefaults.UUID;
    paramDict[@"s"]             = [NSString stringWithFormat:@"%lu", (unsigned long)VWOUserDefaults.sessionCount];
    paramDict[@"random"]        = [self randomNumber];
    paramDict[@"sId"]           = [NSString stringWithFormat:@"%f", date.timeIntervalSince1970];
    paramDict[@"tags"]          = [NSString stringWithFormat:@"{\"u\":{\"%@\":\"%@\"}}", customDimensionKey, customDimensionValue];

    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

@end
