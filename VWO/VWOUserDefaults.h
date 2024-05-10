//
//  VWOUserDefaults.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 06/10/17.
//  Copyright © 2017-2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class  VWOCampaign, VWOGoal;

@interface VWOUserDefaults : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (class, readonly) NSDictionary *campaignVariationPairs;
@property (class) NSUInteger sessionCount;

// Returning user will be set  when session count is updated
@property (class, getter=isReturningUser, readonly) BOOL returningUser;
@property (class, readonly) NSString *UUID;
@property (class, readonly) NSString *CollectionPrefix;
@property (class, readonly) NSString *IsEventArchEnabled;
@property (class, readonly) NSMutableDictionary *EventArchData;
@property (class, readonly) NSMutableDictionary *NonEventArchData;
@property (class, readonly) NSMutableDictionary *NetworkHTTPMethodTypeData;
@property (class, readonly) NSString *PreviousAPIversion;

+ (nullable id)objectForKey:(NSString *)key;
+ (void)setObject:(nullable id)value forKey:(NSString *)key;

+ (void)setExcludedCampaign:(VWOCampaign *)campaign;

+ (BOOL)isTrackingUserForCampaign:(VWOCampaign *)campaign;
+ (void)trackUserForCampaign:(VWOCampaign *)campaign;

+ (void)markGoalConversion:(VWOGoal *)goal inCampaign:(VWOCampaign *)campaign;
+ (BOOL)isGoalMarked:(VWOGoal *)goal inCampaign:(VWOCampaign *)campaign;

+ (void)setDefaultsKey:(NSString *)key;
+ (void)updateUUID:(NSString*)uuid;
+ (void)updateCollectionPrefix:(NSString*)collectionPrefix;
+ (void)updateIsEventArchEnabled:(NSString*)isEventArchEnabled;
+ (void)updateEventArchData:(NSString *)url valueDict:(NSDictionary *)EventArchDict;
+ (void)updateNonEventArchData:(NSString *)url valueDict:(NSDictionary *)NonEventArchDict;
+ (void)updateNetworkHTTPMethodTypeData:(NSString *)url HTTPMethodType:(NSString *)HTTPMethodType;
+ (void)updatePreviousAPIversion:(NSString *)apiVersion;

+ (void)removeEventArchDataItem:(NSString *)url;
+ (void)removeNonEventArchDataItem:(NSString *)url;
+ (void)removeNetworkHTTPMethodTypeDataItem:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
