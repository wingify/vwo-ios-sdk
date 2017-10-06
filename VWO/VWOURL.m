//
//  VWOURL.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 15/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWOURL.h"
#import "NSDictionary+VWO.h"
#import "VWOCampaign.h"
#import "VWOGoal.h"
#import "VWODevice.h"
#import "VWOConfig.h"

static NSString *const kScheme = @"https";
static NSString *const kHost = @"dacdn.visualwebsiteoptimizer.com";

@implementation NSDictionary (NSURLQueryItem)
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

@implementation VWOURL

+ (NSString *) randomNumber {
    return [NSString stringWithFormat:@"%f", ((double)arc4random_uniform(0xffffffff))/(0xffffffff - 1)];
}

+ (NSDictionary *)extraParametersWithDate:(NSDate *)date config:(VWOConfig *)config {
    return @{@"lt" : [NSString stringWithFormat:@"%f", date.timeIntervalSince1970],
             @"v"  : config.sdkVersion,
             @"i"  : config.appKey,
             @"av" : NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"],//App version
             @"dt" : VWODevice.deviceName,//Device Type
             @"os" : VWODevice.iOSVersion
             };
}

#pragma mark - Public Methods

+ (NSURL *)forFetchingCampaignsConfig:(VWOConfig *)config {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:kScheme];
    [components setHost:kHost];
    [components setPath:@"/mobile"];
    NSDictionary *paramDict =
    @{@"api-version": @"2",
      @"a"          : config.accountID,
      @"dt"         : VWODevice.deviceName,
      @"i"          : config.appKey,
      @"k"          : config.campaignVariationPairs.toString,
      @"os"         : VWODevice.iOSVersion,
      @"r"          : [self randomNumber],
      @"u"          : config.UUID,
      @"v"          : config.sdkVersion
      };
    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

+ (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign
                                config:(VWOConfig *)config
                              dateTime:(NSDate *)date {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:kScheme];
    [components setHost:kHost];
    [components setPath:@"/track-user"];

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
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:kScheme];
    [components setHost:kHost];
    [components setPath:@"/track-goal"];

    NSDictionary *paramDict =
    @{@"experiment_id": [NSString stringWithFormat:@"%d", campaign.iD],
      @"account_id"   : config.accountID,
      @"combination"  : [NSString stringWithFormat:@"%d", campaign.variation.iD],
      @"u"            : config.UUID,
      @"s"            : [NSString stringWithFormat:@"%lu", (unsigned long)config.sessionCount],
      @"random"       : [self randomNumber],
      @"ed"           : [self extraParametersWithDate:date config:config].toString,
      @"goal_id"      : [NSString stringWithFormat:@"%d", goal.iD],
      };
    components.queryItems = [paramDict toQueryItems];

    if (goalValue != nil) {
        NSMutableArray<NSURLQueryItem *> *queryItems = [components.queryItems mutableCopy];
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"r" value: [NSString stringWithFormat:@"%@", goalValue]]];
        components.queryItems = queryItems;
    }

    return components.URL;
}

@end

