//
//  VWO.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 08/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

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

/**
 Users that are not to be made part of VWO A/B testing can be opted out.
 */
@property (class, nonatomic) BOOL optOut;

/**
 VWO SDK version
 */
@property (class, nonatomic, readonly) NSString *version;

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

 @warning Completion & Failure blocks are not invoked on the main queue. It is developers responsibility to dispatch the code in the appropriate queue.
 For any UI update the completion must be explicitly dispatched on the main queue.

 @code
 [VWO launchForAPIKey:apiKey completion:^{
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
+ (void)launchForAPIKey:(NSString *)apiKey completion:(void(^)(void))completion failure:(nullable void (^)(NSString *error))failureBlock NS_SWIFT_NAME(launch(apiKey:completion:failure:));

/**
 `Synchronously` fetch campaign settings

 This method is typically invoked in your application:didFinishLaunchingWithOptions: method.

 @param apiKey Unique developer ApiKey provided by VWO.

 @param timeout Request timeout

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
+ (nullable id)variationForKey:(NSString *)key NS_SWIFT_NAME(variationFor(key:));

/**
 Fetch variation for given key

 @note If same key is present in multiple campaigns, then value is fetched from the first campaign that has the key.

 @param key key whose value is to be fetched

 @param defaultValue Value that is to be returned if key is not found

 @return variation if available else `defaultValue`
 */
+ (id)variationForKey:(NSString *)key defaultValue:(id)defaultValue NS_SWIFT_NAME(variationFor(key:defaultValue:));

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
+ (void)trackConversion:(NSString *)goal withValue:(double)value NS_SWIFT_NAME(trackConversion(_:value:));

/**
 Sets key value pair.

 Custom Variable is used in the cases where developer intends to programatically create segmentation.

 @param key Unique key

 @param value Value for the key

 */
+ (void)setCustomVariable:(NSString *)key withValue:(NSString *)value NS_SWIFT_NAME(setCustomVariable(key:value:));

@end
NS_ASSUME_NONNULL_END

