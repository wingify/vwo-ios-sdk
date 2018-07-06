//
//  VWO.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 08/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWOConfig.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const VWOUserStartedTrackingInCampaignNotification;

typedef NS_ENUM(NSInteger, VWOLogLevel) {
    VWOLogLevelDebug,
    VWOLogLevelInfo,
    VWOLogLevelWarning,
    VWOLogLevelError,
    VWOLogLevelNone,
};

@interface VWO : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
  Set logLevel for the VWO. Default VWOLogLevelError
 */
@property (class, nonatomic) VWOLogLevel logLevel;

@property (class, nonatomic) BOOL optOut __deprecated_msg("Use optOt from VWOUserConfig instead");

/**
 VWO SDK version
 */
@property (class, nonatomic, readonly) NSString *version;

/**
 Asynchronously to fetch campaign settings

 This method is typically invoked in your application:didFinishLaunchingWithOptions: method.

 @note Use launchForAPIKey:completion:failure method instead

 @param apiKey Unique developer ApiKey provided by VWO.
 */
+ (void)launchForAPIKey:(NSString *)apiKey NS_SWIFT_NAME(launch(apiKey:)) __deprecated_msg("Use launchForAPIKey:config:completion:failure instead");

+ (void)launchForAPIKey:(NSString *)apiKey
             completion:(void(^)(void))completion
                failure:(nullable void (^)(NSString *error))failureBlock
NS_SWIFT_NAME(launch(apiKey:completion:failure:))
__deprecated_msg("Use launchForAPIKey:config:completion:failure instead");

/**
 Asynchronously fetch campaign settings

 This method is typically invoked in your application:didFinishLaunchingWithOptions: method.

 @param apiKey Unique developer ApiKey provided by VWO.

 @param config A VWOConfig object can be passed for configuring the launch

 @param completion A block object to be executed when campaign settings are fetched successfully.

 @warning Completion & Failure blocks are not invoked on the main queue. It is developers responsibility to dispatch the code in the appropriate queue.
 For any UI update the completion must be explicitly dispatched on the main queue.

 @code
 [VWO launchForAPIKey:apiKey config:nil completion:^{
    dispatch_async(dispatch_get_main_queue(), ^{
        [activityIndicator stopAnimating];
        uiLabel.text = "New Value";
    });
    } failure:^(NSString * _Nonnull error) {
        NSLog(@"Error %@", error);
 }];
 @endcode

 @param failureBlock A block object to be executed when there was error while fetching campaign settings
 */

+ (void)launchForAPIKey:(NSString *)apiKey
                 config:(nullable VWOConfig *)config
             completion:(void(^)(void))completion
                failure:(nullable void (^)(NSString *error))failureBlock
NS_SWIFT_NAME(launch(apiKey:config:completion:failure:));

+ (void)launchSynchronouslyForAPIKey:(NSString *)apiKey
                             timeout:(NSTimeInterval)timeout
NS_SWIFT_NAME(launchSynchronously(apiKey:timeout:))
__deprecated_msg("Use launchSynchronouslyForAPIKey:config:timeout");


/**
 `Synchronously` fetch campaign settings

 This method is typically invoked in your application:didFinishLaunchingWithOptions: method.

 @param apiKey Unique developer ApiKey provided by VWO.

 @param config Launch configuration

 @param timeout Request timeout

 @warning  Use of this method should be avoided as it blocks the main thread, which would freeze your UI.

 @see launchForAPIKey:
 */

+ (void)launchSynchronouslyForAPIKey:(NSString *)apiKey
                             timeout:(NSTimeInterval)timeout
                              config:(VWOConfig *)config
NS_SWIFT_NAME(launchSynchronously(apiKey:timeout:config:));


+ (nullable id)variationForKey:(NSString *)key
         defaultValue:(nullable id)defaultValue NS_SWIFT_NAME(variationFor(key:defaultValue:))
__deprecated_msg("Use objectForKey:defaultValue instead");

/**
 Fetch variation for given key

 @param key key whose value is to be fetched

 @param defaultValue Value that is to be returned if key is not found

 @return variation if available else `defaultValue`
 */
+ (nullable id)objectForKey:(NSString *)key defaultValue:(nullable id)defaultValue NS_SWIFT_NAME(objectFor(key:defaultValue:));

/**
 Fetch variation for given key

 @param key key whose value is to be fetched

 @param defaultValue Value that is to be returned if key is not found

 @return variation if available else `defaultValue`
 */
+ (BOOL)boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue NS_SWIFT_NAME(boolFor(key:defaultValue:));

/**
 Fetch variation for given key

 @param key key whose value is to be fetched

 @param defaultValue Value that is to be returned if key is not found

 @return variation if available else `defaultValue`
 */
+ (int)intForKey:(NSString *)key defaultValue:(int)defaultValue NS_SWIFT_NAME(intFor(key:defaultValue:));

/**
 Fetch variation for given key

 @param key key whose value is to be fetched

 @param defaultValue Value that is to be returned if key is not found

 @return variation if available else `defaultValue`
 */
+ (double)doubleForKey:(NSString *)key defaultValue:(double)defaultValue NS_SWIFT_NAME(doubleFor(key:defaultValue:));

/**
 Fetch variation for given key

 @param key key whose value is to be fetched

 @param defaultValue Value that is to be returned if key is not found

 @return variation if available else `defaultValue`
 */
+ (nullable NSString *)stringForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue NS_SWIFT_NAME(stringFor(key:defaultValue:));


/**
 Fetch variation name for given campaign.

 @note It is recommend to copy the code snippet from dashboard to avoid errors.

 @param campaignTestKey Unique campaign test key
 @return Variation name
 */
+ (nullable NSString *)variationNameForTestKey:(NSString *)campaignTestKey NS_SWIFT_NAME(variationNameFor(testKey:));

/**
 Triggers goal for given identifier

 @param goal identifier against which goal is to be marked

 @note Every goal is marked once
 */
+ (void)trackConversion:(NSString *)goal NS_SWIFT_NAME(trackConversion(_:));

/**
 Triggers goal with a Value for given identifier

 @param goal identifier against which user is to be marked

 @param value Value of goal

 @note Every goal is marked once
 */
+ (void)trackConversion:(NSString *)goal
              withValue:(double)value NS_SWIFT_NAME(trackConversion(_:value:));

/**
 Set Custom Variable
*/
+ (void)setCustomVariable:(NSString *)key
                withValue:(NSString *)value NS_SWIFT_NAME(setCustomVariable(key:value:));

@end
NS_ASSUME_NONNULL_END

