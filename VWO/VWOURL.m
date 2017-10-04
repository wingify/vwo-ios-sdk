//
//  VWOURL.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 15/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWOURL.h"
#import "VWOSDK.h"
#import "VWOActivity.h"
#import <UIKit/UIKit.h>
#import "NSDictionary+VWO.h"
#import "VWOCampaign.h"
#import "VWOGoal.h"

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

+ (NSDictionary *)extraParametersWithDate:(NSDate *)date {
    return @{@"lt" : [NSString stringWithFormat:@"%f", date.timeIntervalSince1970],
             @"v"  : VWOSDK.version,
             @"i"  : VWOSDK.appKey,
             @"av" : NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"],
             @"dt" : UIDevice.currentDevice.name,
             @"os" : UIDevice.currentDevice.systemVersion
             };
}

#pragma mark - Public Methods

+ (NSURL *)forFetchingCampaigns {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:kScheme];
    [components setHost:kHost];
    [components setPath:@"/mobile"];
    NSDictionary *paramDict =
    @{@"api-version": @"2",
      @"a"          : VWOSDK.accountID,
      @"dt"         : UIDevice.currentDevice.name,
      @"i"          : VWOSDK.appKey,
      @"k"          : VWOActivity.campaignVariationPairs.toString,
      @"os"         : UIDevice.currentDevice.systemVersion,
      @"r"          : [self randomNumber],
      @"u"          : VWOActivity.UUID,
      @"v"          : VWOSDK.version
      };
    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

+ (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign dateTime:(NSDate *)date {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:kScheme];
    [components setHost:kHost];
    [components setPath:@"/l.gif"];
    NSDictionary *paramDict =
    @{@"experiment_id": [NSString stringWithFormat:@"%d", campaign.iD],
      @"account_id"   : VWOSDK.accountID,
      @"combination"  : [NSString stringWithFormat:@"%d", campaign.variation.iD],
      @"u"            : VWOActivity.UUID,
      @"s"            : [NSString stringWithFormat:@"%lu", (unsigned long)VWOActivity.sessionCount],
      @"random"       : [self randomNumber],
      @"ed"           : [self extraParametersWithDate:date].toString
      };
    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

+ (NSURL *)forMarkingGoal:(VWOCampaign *)campaign goal:(VWOGoal *)goal dateTime:(NSDate *)date withValue:(NSNumber *)goalValue {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:kScheme];
    [components setHost:kHost];
    [components setPath:@"/c.gif"];

    NSDictionary *paramDict =
    @{@"experiment_id": [NSString stringWithFormat:@"%d", campaign.iD],
      @"account_id"   : VWOSDK.accountID,
      @"combination"  : [NSString stringWithFormat:@"%d", campaign.variation.iD],
      @"u"            : VWOActivity.UUID,
      @"s"            : [NSString stringWithFormat:@"%lu", (unsigned long)VWOActivity.sessionCount],
      @"random"       : [self randomNumber],
      @"ed"           : [self extraParametersWithDate:date].toString,
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

