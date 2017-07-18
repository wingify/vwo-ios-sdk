/*!
 @header    VWO.h
 @abstract  VWO iOS SDK Header
 @copyright Copyright 2015 Wingify Software Pvt. Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface VWO : NSObject
/**
 *  Launch VWO
 *  Call VWO's server asynchronously to fetch settings
 */
+ (void)launchForAPIKey:(NSString *) key NS_SWIFT_NAME(launch(apiKey:));

/**
 *  Launch VWO
 *  Call VWO's server Asynchronously
 *  It will call passed in code block on completion (success or error)
 */
+ (void)launchForAPIKey:(NSString *) key completion:(void(^)(void))completionBlock NS_SWIFT_NAME(launch(apiKey:completion:));

/**
 *  Launch VWO
 *  Call VWO's server Synchronously
 *  Application will pause until settings are fetched or timed out
 */
+ (void)launchSynchronouslyForAPIKey: (NSString *) key NS_SWIFT_NAME(launchSynchronously(apiKey:));

/**
 *  It searches all the available campaigns, identifies the campaign and returns object for the specified key
 *  By default user is made part of the identified campaign, unless you call 'trackUserManually' method BEFORE initialisation.
 */
+ (nullable id)variationForKey:(NSString*)key NS_SWIFT_NAME(variationFor(key:));

/**
 *  Behaves in the same manner as 'objectForKey', it returns defaultObject instead of nil when:
 *  - an object for the specified key cannot be found,
 *  - an invalid key is specified
 *  - if internet connection is not available
 *  - in case of any error
 */
+ (nullable id)variationForKey:(NSString*)key defaultValue:(id)defaultValue NS_SWIFT_NAME(variationFor(key:defaultValue:));

/**
 *  Triggers goal for the specified goal string
 *  Each goal is only counted once
 */
+ (void)markConversionForGoal:(NSString*)goal NS_SWIFT_NAME(markConversionFor(goal:));

/**
 *  Triggers goal with the value for the specified goal string
 *  Each goal is only counted once
 */
+ (void)markConversionForGoal:(NSString*)goal withValue:(double)value NS_SWIFT_NAME(markConversionFor(goal:value:));

/**
 *  Set Value for custom variable defined on VWO
 */
+ (void)setCustomVariable:(NSString *)variable withValue:(NSString *)value NS_SWIFT_NAME(setCustomVariable(key:value:));

/**
 *  Returns VWO SDK version
 */
+ (NSString*)version;

@end
NS_ASSUME_NONNULL_END
