/*!
 @header    VWO.h
 @abstract  VWO iOS SDK Header
 @copyright Copyright 2015 Wingify Software Pvt. Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface VWO : NSObject
/**
 *  Launch VWO
 *  Call VWO's server asynchronously to fetch settings
 */
+ (void)launchForAPIKey:(NSString *) key;

/**
 *  Launch VWO
 *  Call VWO's server Asynchronously
 *  It will call passed in code block on completion (success or error)
 */
+ (void)launchForAPIKey:(NSString *) key completion:(void(^)(void))completionBlock;

/**
 *  Launch VWO
 *  Call VWO's server Synchronously
 *  Application will pause until settings are fetched or timed out
 */
+ (void)launchSynchronouslyForAPIKey: (NSString *) key;

/**
 *  It searches all the available campaigns, identifies the campaign and returns object for the specified key
 *  By default user is made part of the identified campaign, unless you call 'trackUserManually' method BEFORE initialisation.
 */
+ (id)variationForKey:(NSString*)key;

/**
 *  Behaves in the same manner as 'objectForKey', it returns defaultObject instead of nil when:
 *  - an object for the specified key cannot be found,
 *  - an invalid key is specified
 *  - if internet connection is not available
 *  - in case of any error
 */
+ (id)variationForKey:(NSString*)key defaultObject:(id)defaultObject;

/**
 *  Triggers goal for the specified goal string
 *  Each goal is only counted once
 */
+ (void)markConversionForGoal:(NSString*)goal;

/**
 *  Triggers goal with the value for the specified goal string
 *  Each goal is only counted once
 */
+ (void)markConversionForGoal:(NSString*)goal withValue:(double)value;

/**
 *  If you call 'trackUserManually' before calling launch method then
 *  a user IS NOT automatically made part of campaign.
 *  You should call 'trackUserInCampaign' when you want to include a user in a campaign.
 */
+ (void)trackUserManually;

/**
 *  It searches all the available campaigns, identifies the campaign and make user part of that campaign.
 *  A user is counted only once for a particular campaign.
 */
+ (void)trackUserInCampaign:(NSString*)key;

/**
 *  Set Value for custom variable defined on VWO
 */
+ (void)setValue:(NSString*)value forCustomVariable:(NSString*)variable;

/**
 *  Retruns VWO SDK version
 */
+ (NSString*)sdkVersion;

@end
