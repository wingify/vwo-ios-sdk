//
//  VWOMakeURL.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 15/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import "VWOMakeURL.h"
#import "VWOSDK.h"
#import "VWODeviceInfo.h"
#import "VWOPersistantStore.h"
#import <UIKit/UIKit.h>
#import "NSDictionary+VWO.h"
#import "VWOCampaign.h"
#import "VWOGoal.h"

static NSString *const kScheme = @"https";
static NSString *const kHost = @"dacdn.visualwebsiteoptimizer.com";

@implementation VWOMakeURL

+ (NSString *) randomNumber {
    return [NSString stringWithFormat:@"%f", ((double)arc4random_uniform(0xffffffff))/(0xffffffff - 1)];
}

+ (NSDictionary *)extraParameters:(NSDate *)date {
    return @{@"lt" : [NSString stringWithFormat:@"%f", date.timeIntervalSince1970],
             @"v"  : VWOSDK.version,
             @"i"  : VWOSDK.appKey,
             @"av" : NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"],
             @"dt" : VWODeviceInfo.platformName,
             @"os" : UIDevice.currentDevice.systemVersion
             };
}

#pragma mark - Public Methods

+ (NSURL *)forFetchingCampaigns {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:kScheme];
    [components setHost:kHost];
    [components setPath:@"/mobile"];
    [components
     setQueryItems:@[[NSURLQueryItem queryItemWithName:@"a" value:VWOSDK.accountID],
                     [NSURLQueryItem queryItemWithName:@"dt" value:VWODeviceInfo.platformName],
                     [NSURLQueryItem queryItemWithName:@"i" value:VWOSDK.appKey],
                     [NSURLQueryItem queryItemWithName:@"k" value:VWOPersistantStore.campaignVariationPairs.toString],
                     [NSURLQueryItem queryItemWithName:@"os" value:UIDevice.currentDevice.systemVersion],
                     [NSURLQueryItem queryItemWithName:@"r" value: [self randomNumber]],
                     [NSURLQueryItem queryItemWithName:@"u" value:VWOPersistantStore.UUID],
                     [NSURLQueryItem queryItemWithName:@"v" value:VWOSDK.version],
                     ]];
    return components.URL;
}

+ (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign dateTime:(NSDate *)date {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:kScheme];
    [components setHost:kHost];
    [components setPath:@"/l.gif"];
    [components
     setQueryItems:@[
                     [NSURLQueryItem queryItemWithName:@"experiment_id" value:VWOSDK.accountID],
                     [NSURLQueryItem queryItemWithName:@"account_id" value:VWOSDK.accountID],
                     [NSURLQueryItem queryItemWithName:@"combination" value:[NSString stringWithFormat:@"%d", campaign.variation.iD]],
                     [NSURLQueryItem queryItemWithName:@"u" value:VWOPersistantStore.UUID],
                     [NSURLQueryItem queryItemWithName:@"s" value: [NSString stringWithFormat:@"%u", VWOPersistantStore.sessionCount]],
                     [NSURLQueryItem queryItemWithName:@"random" value: [self randomNumber]],
                     [NSURLQueryItem queryItemWithName:@"ed" value: [self extraParameters:date].toString],
                     ]];
    return components.URL;
}

+ (NSURL *)forMarkingGoal:(VWOCampaign *)campaign goal:(VWOGoal *)goal dateTime:(NSDate *)date withValue:(NSNumber *)goalValue {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:kScheme];
    [components setHost:kHost];
    [components setPath:@"/c.gif"];


    [components
     setQueryItems:@[
                     [NSURLQueryItem queryItemWithName:@"experiment_id" value:VWOSDK.accountID],
                     [NSURLQueryItem queryItemWithName:@"account_id" value:VWOSDK.accountID],
                     [NSURLQueryItem queryItemWithName:@"combination" value:[NSString stringWithFormat:@"%d", campaign.variation.iD]],
                     [NSURLQueryItem queryItemWithName:@"u" value:VWOPersistantStore.UUID],
                     [NSURLQueryItem queryItemWithName:@"s" value: [NSString stringWithFormat:@"%u", VWOPersistantStore.sessionCount]],
                     [NSURLQueryItem queryItemWithName:@"random" value: [self randomNumber]],
                     [NSURLQueryItem queryItemWithName:@"ed" value: [self extraParameters:date].toString],
                     [NSURLQueryItem queryItemWithName:@"goal_id" value: [NSString stringWithFormat:@"%d", goal.iD]],
                     ]];

    if (goalValue != nil) {
        NSMutableArray *queryItems = [components mutableCopy];
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"r" value: [NSString stringWithFormat:@"%@", goalValue]]];
        components.queryItems = queryItems;
    }

    return components.URL;
}

@end
