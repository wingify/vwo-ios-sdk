/*!
 @header    VWO.h
 @abstract  VWO iOS SDK Header
 @copyright Copyright 2017 Wingify Software Pvt. Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "VAOLogger.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const VWOUserStartedTrackingInCampaignNotification;

@interface VWO : NSObject

/**
 * Set logLevel for the VWO. Default VWOLogLevelError
 */
@property (class, nonatomic) VWOLogLevel logLevel;

/**
 Asynchronously to fetch campaign settings

 This method is typically invoked in your application:didFinishLaunchingWithOptions: method.

 @param apiKey Unique developer ApiKey provided by VWO.
 */
+ (void)launchForAPIKey:(NSString *)apiKey NS_SWIFT_NAME(launch(apiKey:));

/**
 Asynchronously fetch campaign settings

 This method is typically invoked in your application:didFinishLaunchingWithOptions: method.

 @param apiKey Unique developer ApiKey provided by VWO.
 
 @param completion A block object to be executed when campaign settings are fetched successfully.
 */
+ (void)launchForAPIKey:(NSString *)apiKey completion:(void(^)(void))completion NS_SWIFT_NAME(launch(apiKey:completion:));

/**
 Asynchronously fetch campaign settings

 This method is typically invoked in your application:didFinishLaunchingWithOptions: method.

 @param apiKey Unique developer ApiKey provided by VWO.

 @param completion A block object to be executed when campaign settings are fetched successfully.
 
 @param failureBlock A block object to be executed when there was error while fetching campaign settings
 */
+ (void)launchForAPIKey:(NSString *)apiKey completion:(void(^)(void))completion failure:(void (^)(void))failureBlock NS_SWIFT_NAME(launch(apiKey:completion:failure:));

/**
 `Synchronously` fetch campaign settings

 This method is typically invoked in your application:didFinishLaunchingWithOptions: method.

 @param apiKey Unique developer ApiKey provided by VWO.

 @warning  Use of this method should be avoided as it blocks the main thread, which would freeze your UI.
 
 @see launchForAPIKey:
 */
+ (void)launchSynchronouslyForAPIKey:(NSString *) apiKey timeout:(NSTimeInterval)timeout NS_SWIFT_NAME(launchSynchronously(apiKey:timeout:));

/**
 Fetches variation for given key
 
 @note If same key is present in multiple campaigns, then value is fetched from the first campaign that has the key.

 @param key key whose value is to be fetched

 @return variation if available else `null`

 @see variationForKey:defaultValue:
 */
+ (nullable id)variationForKey:(NSString*)key NS_SWIFT_NAME(variationFor(key:));

/**
 Fetch variation for given key

 @note If same key is present in multiple campaigns, then value is fetched from the first campaign that has the key.

 @param key key whose value is to be fetched

 @param defaultValue Value that is to be returned if key is not found
 
 @return variation if available else `defaultValue`
*/
+ (id)variationForKey:(NSString*)key defaultValue:(id)defaultValue NS_SWIFT_NAME(variationFor(key:defaultValue:));

/**
  Triggers goal for given identifier

 @param goal identifier against which goal is to be marked

 @note Every goal is marked once
 */
+ (void)markConversionForGoal:(NSString*)goal NS_SWIFT_NAME(markConversionFor(goal:));

/**
 Triggers goal with a Value for given identifier

 @param goal identifier against which user is to be marked

 @param value Value of goal
 
 @note Every goal is marked once
 */
+ (void)markConversionForGoal:(NSString*)goal withValue:(double)value NS_SWIFT_NAME(markConversionFor(goal:value:));

/**
 Sets key value pair.
 
 Custom Variable is used in the cases where developer intends to programatically create segmentation.

 @param key Unique key
 
 @param value Value for the key
 
 */
+ (void)setCustomVariable:(NSString *)key withValue:(NSString *)value NS_SWIFT_NAME(setCustomVariable(key:value:));

/**
 *  VWO SDK version
 */
+ (NSString*)version;

@end
NS_ASSUME_NONNULL_END
