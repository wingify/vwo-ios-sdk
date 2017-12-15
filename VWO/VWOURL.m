//
//  VWOURL.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 15/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWOURL.h"
#import "VWOCampaign.h"
#import "VWOGoal.h"
#import "VWODevice.h"
#import "VWOConfig.h"
#import "VWO.h"

@implementation NSDictionary (NSURLQueryItem)
- (nullable NSString *)toString {
    NSError *error;
    NSData *currentData = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (!error) {
        return [[NSString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSArray<NSURLQueryItem *> *)toQueryItems {
    NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray new];
    for (NSString *key in self) {
        NSAssert([self[key] isKindOfClass:[NSString class]], @"Query item can only have string");
        NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:self[key]];
        [queryItems addObject:item];
    }
    return queryItems;
}
@end

@implementation NSURLComponents (VWO)
    /// Creates URL component with scheme host and path. Eg: https://dacdn.visual.com/path
+ (instancetype)vwoComponentForPath:(NSString *)path {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:@"https"];
    [components setHost:@"dacdn.visualwebsiteoptimizer.com"];
    [components setPath:path];
    return components;
}
@end

static NSString *kSDKversionNumber = @"3";

@implementation VWOURL

+ (NSString *) randomNumber {
    return [NSString stringWithFormat:@"%f", ((double)arc4random_uniform(0xffffffff))/(0xffffffff - 1)];
}

+ (NSDictionary *)extraParametersWithDate:(NSDate *)date config:(VWOConfig *)config {
    return @{@"lt" : [NSString stringWithFormat:@"%f", date.timeIntervalSince1970],
             @"v"  : kSDKversionNumber,
             @"i"  : config.appKey,
             @"av" : NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"],//App version //TODO: Handle for nil case
             @"dt" : VWODevice.deviceName,//Device Type
             @"os" : VWODevice.iOSVersion
             };
}

#pragma mark - Public Methods

+ (NSURL *)forFetchingCampaignsConfig:(VWOConfig *)config {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:@"/mobile"];
    NSDictionary *paramDict =
    @{@"api-version": @"2",
      @"a"          : config.accountID,
      @"dt"         : VWODevice.deviceName,
      @"i"          : config.appKey,
      @"k"          : config.campaignVariationPairs.toString,
      @"os"         : VWODevice.iOSVersion,
      @"r"          : [self randomNumber],
      @"u"          : config.UUID,
      @"v"          : kSDKversionNumber
      };
    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

+ (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign
                                config:(VWOConfig *)config
                              dateTime:(NSDate *)date {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:@"/track-user"];
    NSDictionary *paramDict =
    @{@"experiment_id": [NSString stringWithFormat:@"%d", campaign.iD],
      @"account_id"   : config.accountID,
      @"combination"  : [NSString stringWithFormat:@"%d", campaign.variation.iD],
      @"u"            : config.UUID,
      @"s"            : [NSString stringWithFormat:@"%lu", (unsigned long)config.sessionCount],
      @"random"       : [self randomNumber],
      @"ed"           : [self extraParametersWithDate:date config:config].toString
      };
    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

+ (NSURL *)forMarkingGoal:(VWOGoal *)goal
                withValue:(NSNumber *)goalValue
                 campaign:(VWOCampaign *)campaign
                 dateTime:(NSDate *)date
                   config:(VWOConfig *)config {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:@"/track-goal"];
    NSMutableDictionary <NSString *, NSString *> *paramDict = [NSMutableDictionary new];
    paramDict[@"experiment_id"] = [NSString stringWithFormat:@"%d", campaign.iD];
    paramDict[@"account_id"]    = config.accountID;
    paramDict[@"combination"]   = [NSString stringWithFormat:@"%d", campaign.variation.iD];
    paramDict[@"u"]             = config.UUID;
    paramDict[@"s"]             = [NSString stringWithFormat:@"%lu", (unsigned long)config.sessionCount];
    paramDict[@"random"]        = [self randomNumber];
    paramDict[@"ed"]            = [self extraParametersWithDate:date config:config].toString;
    paramDict[@"goal_id"]       = [NSString stringWithFormat:@"%d", goal.iD];

    if (goalValue != nil) {
        paramDict[@"r"] = [NSString stringWithFormat:@"%@", goalValue];
    }
    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

@end
