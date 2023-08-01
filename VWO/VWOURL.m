//
//  VWOURL.m
//  VWO
//
//  Created by Kaunteya Suryawanshi on 15/09/17.
//  Copyright © 2017-2022 vwo. All rights reserved.
//

#import "VWOURL.h"
#import "VWOCampaign.h"
#import "VWOGoal.h"
#import "VWODevice.h"
#import "VWOUserDefaults.h"
#import "VWO.h"
#import "NSDictionary+VWO.h"
#import "NSString+MD5.h"
#import "VWOConstants.h"

@implementation NSURLComponents (VWO)
    /// Creates URL component with scheme host and path. Eg: https://dacdn.visual.com/path
+ (instancetype)vwoComponentForPath:(NSString *)path isChinaCDN:(BOOL)isChinaCDN {
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:ConstNetworkScheme];
    if (isChinaCDN) {
        [components setHost:ConstChinaCDNBaseURL];
    } else {
        [components setHost:ConstBaseURL];
    }
    [components setPath:path];
    return components;
}
@end

static NSString *kSDKversionNumber = @"19";

@interface VWOURL()

@property NSString *appKey;
@property NSString *accountID;
@property BOOL isChinaCDN;

@end

@implementation VWOURL

+ (instancetype)urlWithAppKey:(NSString *)appKey accountID:(NSString *)accountID isChinaCDN:(BOOL)isChinaCDN {
    return [[self alloc] initWithAppKey:appKey accountID:accountID isChinaCDN:isChinaCDN];
}

- (instancetype)initWithAppKey:(NSString *)appKey accountID:(NSString *)accountID isChinaCDN:(BOOL)isChinaCDN {
    NSParameterAssert(appKey != nil);
    NSParameterAssert(accountID != nil);
    self = [self init];
    if (self) {
        _appKey = appKey;
        _accountID = accountID;
        _isChinaCDN = isChinaCDN;
    }
    return self;
}

- (NSString *) randomNumber {
    return [NSString stringWithFormat:@"%f", ((double)arc4random_uniform(0xffffffff))/(0xffffffff - 1)];
}

- (NSDictionary *)extraParametersWithDate:(NSDate *)date {
    NSString *appVersion = NSBundle.mainBundle.infoDictionary[ConstKeyBundleAppVersion];
    if (appVersion == nil) { appVersion = ConstNotAvailable; }
    return @{KeyTimeStampExtraData          : [NSString stringWithFormat:@"%f", date.timeIntervalSince1970],
             KeySDKVersionNumberExtraData   : kSDKversionNumber,
             KeyAppKeyExtraData             : _appKey,
             KeyAppVersionExtraData         : appVersion,
             KeyDeviceNameExtraData         : VWODevice.deviceName,//Device Type
             KeyIOSVersionExtraData         : VWODevice.iOSVersion
             };
}

#pragma mark - Public Methods

- (NSURL *)forFetchingCampaigns:(nullable NSString *)userID {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:ConstFetchingCampaignsEndpoint isChinaCDN:_isChinaCDN];
    NSMutableDictionary *paramDict =
    [@{KeyAPIVersionFetchingCampaign: ConstAPIVersion,
      KeyAccountIDFetchingCampaign              : _accountID,
      KeyDeviceNameFetchingCampaign             : VWODevice.deviceName,
      KeyAppKeyFetchingCampaign                 : _appKey,
      KeyCampaignVariationPairsFetchingCampaign : VWOUserDefaults.campaignVariationPairs.toString,
      KeyIOSVersionFetchingCampaign             : VWODevice.iOSVersion,
      KeyRandomNumberFetchingCampaign           : [self randomNumber],
      KeyUUIDFetchingCampaign                   : VWOUserDefaults.UUID,
      KeySDKversionNumberFetchingCampaign       : kSDKversionNumber
      } mutableCopy];
    if (userID) {
        NSString * uHash = userID.generateMD5;
        paramDict[keyUHashFetchingCampaign] = uHash;
        [VWOUserDefaults updateUUID:uHash];
    }
    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

- (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign
                              dateTime:(NSDate *)date
                              config:(VWOConfig *) config {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:ConstTrackUserEndpoint isChinaCDN:_isChinaCDN];
    if(VWOUserDefaults.CollectionPrefix != NULL && VWOUserDefaults.CollectionPrefix.length != 0){
        NSString *path = [NSString stringWithFormat: @"%@%@", VWOUserDefaults.CollectionPrefix, ConstTrackUserEndpoint];
        components = [NSURLComponents vwoComponentForPath:path isChinaCDN:_isChinaCDN];
    }
    
    NSMutableDictionary *paramDict =
    [@{KeyExperimentID  : [NSString stringWithFormat:@"%d", campaign.iD],
       KeyAccountID     : _accountID,
       KeyCombination   : [NSString stringWithFormat:@"%d", campaign.variation.iD],
       KeyUUID          : VWOUserDefaults.UUID,
       KeySessionCount  : [NSString stringWithFormat:@"%lu", (unsigned long)VWOUserDefaults.sessionCount],
       KeyRandom        : [self randomNumber],
       KeyTimeStamp     : [NSString stringWithFormat:@"%lu", (unsigned long)date.timeIntervalSince1970],
       KeyExtraData     : [self extraParametersWithDate:date].toString
      } mutableCopy];
    if (config.customDimension != nil) {
        paramDict[KeyCustomDimension] = config.customDimension;
    }
    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

- (NSURL *)forMakingUserPartOfCampaignEventArch:(VWOCampaign *)campaign
                              dateTime:(NSDate *)date
                              config:(VWOConfig *) config{
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:ConstEventArchEndpoint isChinaCDN:_isChinaCDN];
    if(VWOUserDefaults.CollectionPrefix != NULL && VWOUserDefaults.CollectionPrefix.length != 0){
        NSString *path = [NSString stringWithFormat: @"%@%@", VWOUserDefaults.CollectionPrefix, ConstEventArchEndpoint];
        components = [NSURLComponents vwoComponentForPath:path isChinaCDN:_isChinaCDN];
    }
    
    unsigned long currentTimeInSec = (unsigned long)date.timeIntervalSince1970;
    unsigned long currentTimeInMilli = (unsigned long)(date.timeIntervalSince1970 * 1000);
    
    NSMutableDictionary *paramDict =
    [@{APIEventName         : TrackUserEventName,
       AccountID            : _accountID,
       APIKey               : [NSString stringWithFormat:@"%@-%@", _appKey, _accountID],
       CurrentTimeInMillis  : [NSString stringWithFormat:@"%lu", currentTimeInMilli],
       Random               : [self randomNumber]
     } mutableCopy];
    
    components.queryItems = [paramDict toQueryItems];
    
    NSMutableDictionary *EventArchDict = @{
        D: @{
            MessageID: [NSString stringWithFormat:@"%@-%lu", VWOUserDefaults.UUID, currentTimeInMilli],
            VisitorID: VWOUserDefaults.UUID,
            SessionID: [NSNumber numberWithUnsignedLong : currentTimeInSec],
            Event: @{
                EventProps: @{
                    SDKName: SDKNameValue,
                    SDKVersion: kSDKversionNumber,
                    CampaignID: [NSNumber numberWithInt : campaign.iD],
                    VariationID: [NSNumber numberWithInt : campaign.variation.iD],
                    IsFirst: @1 //always 1
                },
                Data360EventName: TrackUserEventName,
                EventTime: [NSNumber numberWithUnsignedLong : currentTimeInMilli]
            }
        }
    };
    
    NSString *urlString = [components.URL absoluteString];
    [VWOUserDefaults updateEventArchData:urlString valueDict:EventArchDict];
    
    return components.URL;
}

- (NSURL *)forMarkingGoal:(VWOGoal *)goal
                withValue:(NSNumber *)goalValue
                 campaign:(VWOCampaign *)campaign
                 dateTime:(NSDate *)date {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath: ConstTrackGoalEndpoint isChinaCDN:_isChinaCDN];
    if(VWOUserDefaults.CollectionPrefix != NULL && VWOUserDefaults.CollectionPrefix.length != 0){
        NSString *path = [NSString stringWithFormat: @"%@%@", VWOUserDefaults.CollectionPrefix, ConstTrackGoalEndpoint];
        components = [NSURLComponents vwoComponentForPath:path isChinaCDN:_isChinaCDN];
    }
    
    NSMutableDictionary <NSString *, NSString *> *paramDict = [NSMutableDictionary new];
    paramDict[KeyExperimentID]  = [NSString stringWithFormat:@"%d", campaign.iD];
    paramDict[KeyAccountID]     = _accountID;
    paramDict[KeyCombination]   = [NSString stringWithFormat:@"%d", campaign.variation.iD];
    paramDict[KeyUUID]          = VWOUserDefaults.UUID;
    paramDict[KeySessionCount]  = [NSString stringWithFormat:@"%lu", (unsigned long)VWOUserDefaults.sessionCount];
    paramDict[KeyRandom]        = [self randomNumber];
    paramDict[KeyTimeStamp]     = [NSString stringWithFormat:@"%f", date.timeIntervalSince1970];
    paramDict[KeyExtraData]     = [self extraParametersWithDate:date].toString;
    paramDict[KeyGoalID]        = [NSString stringWithFormat:@"%d", goal.iD];

    if (goalValue != nil) {
        paramDict[KeyGoalRevenue] = [NSString stringWithFormat:@"%@", goalValue];
    }
    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

- (NSURL *)forMarkingGoalEventArch:(VWOGoal *)goal
                          withValue:(NSNumber *)goalValue
                          campaign:(VWOCampaign *)campaign
                          dateTime:(NSDate *)date {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:ConstEventArchEndpoint isChinaCDN:_isChinaCDN];
    if(VWOUserDefaults.CollectionPrefix != NULL && VWOUserDefaults.CollectionPrefix.length != 0){
        NSString *path = [NSString stringWithFormat: @"%@%@", VWOUserDefaults.CollectionPrefix, ConstEventArchEndpoint];
        components = [NSURLComponents vwoComponentForPath:path isChinaCDN:_isChinaCDN];
    }
    
    unsigned long currentTimeInSec = (unsigned long)date.timeIntervalSince1970;
    unsigned long currentTimeInMilli = (unsigned long)(date.timeIntervalSince1970 * 1000);
    
    NSMutableDictionary *paramDict =
    [@{APIEventName         : goal.identifier,
       AccountID            : _accountID,
       APIKey               : [NSString stringWithFormat:@"%@-%@", _appKey, _accountID],
       CurrentTimeInMillis  : [NSString stringWithFormat:@"%lu", currentTimeInMilli],
       Random               : [self randomNumber]
     } mutableCopy];
    
    components.queryItems = [paramDict toQueryItems];
    
    NSString *goalID = [NSString stringWithFormat:@"g_%d", goal.iD];
    NSArray *goalIDArray = @[goalID];
    NSDictionary *VWOMetaDict = @{
        Metric: @{
            [NSString stringWithFormat:@"id_%d", campaign.iD]: goalIDArray
        }
    };
    
    if (goalValue != nil && goal.revenueProp != nil) {
        VWOMetaDict = @{
            Metric: @{
                [NSString stringWithFormat:@"id_%d", campaign.iD]: goalIDArray
            },
            goal.revenueProp : goalValue
        };
    }
    
    NSMutableDictionary *EventArchDict = @{
        D: @{
            MessageID: [NSString stringWithFormat:@"%@-%lu", VWOUserDefaults.UUID, currentTimeInMilli],
            VisitorID: VWOUserDefaults.UUID,
            SessionID: [NSNumber numberWithUnsignedLong : currentTimeInSec],
            Event: @{
                EventProps: @{
                    SDKName: SDKNameValue,
                    SDKVersion: kSDKversionNumber,
                    IsCustomEvent: @((BOOL)true),
                    VWOMeta: VWOMetaDict
                },
                Data360EventName: goal.identifier,
                EventTime: [NSNumber numberWithUnsignedLong : currentTimeInMilli]
            }
        }
    };
    
    NSString *urlString = [components.URL absoluteString];
    [VWOUserDefaults updateEventArchData:urlString valueDict:EventArchDict];
    
    return components.URL;
}

- (NSURL *)forPushingCustomDimension:(NSString *)customDimensionKey
                            withCustomDimensionValue:(nonnull NSString *)customDimensionValue
                            dateTime:(nonnull NSDate *)date {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:ConstPushingCustomDimensionEndpoint isChinaCDN:_isChinaCDN];
    if(VWOUserDefaults.CollectionPrefix != NULL && VWOUserDefaults.CollectionPrefix.length != 0){
        NSString *path = [NSString stringWithFormat: @"%@%@", VWOUserDefaults.CollectionPrefix, ConstPushingCustomDimensionEndpoint];
        components = [NSURLComponents vwoComponentForPath:path isChinaCDN:_isChinaCDN];
    }
    NSMutableDictionary <NSString *, NSString *> *paramDict = [NSMutableDictionary new];
    paramDict[KeyAccountID]         = _accountID;
    paramDict[KeyUUID]              = VWOUserDefaults.UUID;
    paramDict[KeySessionCount]      = [NSString stringWithFormat:@"%lu", (unsigned long)VWOUserDefaults.sessionCount];
    paramDict[KeyRandom]            = [self randomNumber];
    paramDict[KeyTimeStamp]         = [NSString stringWithFormat:@"%f", date.timeIntervalSince1970];
    paramDict[KeyCustomDimension]   = [NSString stringWithFormat:@"{\"u\":{\"%@\":\"%@\"}}", customDimensionKey, customDimensionValue];

    components.queryItems = [paramDict toQueryItems];
    return components.URL;
}

- (NSURL *)forPushingCustomDimensionEventArch:(NSString *)customDimensionKey
                                withCustomDimensionValue:(nonnull NSString *)customDimensionValue
                                dateTime:(nonnull NSDate *)date {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:ConstEventArchEndpoint isChinaCDN:_isChinaCDN];
    if(VWOUserDefaults.CollectionPrefix != NULL && VWOUserDefaults.CollectionPrefix.length != 0){
        NSString *path = [NSString stringWithFormat: @"%@%@", VWOUserDefaults.CollectionPrefix, ConstEventArchEndpoint];
        components = [NSURLComponents vwoComponentForPath:path isChinaCDN:_isChinaCDN];
    }
    
    unsigned long currentTimeInSec = (unsigned long)date.timeIntervalSince1970;
    unsigned long currentTimeInMilli = (unsigned long)(date.timeIntervalSince1970 * 1000);
    
    NSMutableDictionary *paramDict =
    [@{APIEventName         : PushEventName,
       AccountID            : _accountID,
       APIKey               : [NSString stringWithFormat:@"%@-%@", _appKey, _accountID],
       CurrentTimeInMillis  : [NSString stringWithFormat:@"%lu", currentTimeInMilli],
       Random               : [self randomNumber]
     } mutableCopy];
    
    components.queryItems = [paramDict toQueryItems];
    
    NSMutableDictionary *EventArchDict = @{
        D: @{
            MessageID: [NSString stringWithFormat:@"%@-%lu", VWOUserDefaults.UUID, currentTimeInMilli],
            VisitorID: VWOUserDefaults.UUID,
            SessionID: [NSNumber numberWithUnsignedLong : currentTimeInSec],
            Event: @{
                EventProps: @{
                    SDKName: SDKNameValue,
                    SDKVersion: kSDKversionNumber,
                    IsCustomEvent: @((BOOL)true),
                    InternalVisitor: @{
                        VisitorProps: @{
                            customDimensionKey: customDimensionValue    ///[tagkey]: [tagValue]
                        }
                    }
                },
                Data360EventName: PushEventName,
                EventTime: [NSNumber numberWithUnsignedLong : currentTimeInMilli]
            },
            ExternalVisitor: @{
                VisitorProps: @{
                    customDimensionKey: customDimensionValue    ///[tagkey]: [tagValue]
                }
            }
        }
    };
    
    NSString *urlString = [components.URL absoluteString];
    [VWOUserDefaults updateEventArchData:urlString valueDict:EventArchDict];
    
    return components.URL;
}

- (NSURL *)forPushingCustomDimension:(NSMutableDictionary<NSString *, id> *)customDimensionDictionary
                            dateTime:(nonnull NSDate *)date {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:ConstPushingCustomDimensionEndpoint isChinaCDN:_isChinaCDN];
    if(VWOUserDefaults.CollectionPrefix != NULL && VWOUserDefaults.CollectionPrefix.length != 0){
        NSString *path = [NSString stringWithFormat: @"%@%@", VWOUserDefaults.CollectionPrefix, ConstPushingCustomDimensionEndpoint];
        components = [NSURLComponents vwoComponentForPath:path isChinaCDN:_isChinaCDN];
    }
    
    NSMutableDictionary *paramDict  = [NSMutableDictionary new];
    paramDict[KeyAccountID]         = _accountID;
    paramDict[KeyUUID]              = VWOUserDefaults.UUID;
    paramDict[KeySessionCount]      = [NSString stringWithFormat:@"%lu", (unsigned long)VWOUserDefaults.sessionCount];
    paramDict[KeyRandom]            = [self randomNumber];
    paramDict[KeyTimeStamp]         = [NSString stringWithFormat:@"%f", date.timeIntervalSince1970];
    
    components.queryItems = [paramDict toQueryItems];
    
    NSString *urlString = [components.URL absoluteString];
    [VWOUserDefaults updateNetworkHTTPMethodTypeData:urlString HTTPMethodType: @"POST"];
    
    if([customDimensionDictionary count] != 0){
        NSDictionary * customDimensionServerDictionary = @{
            KeyU : customDimensionDictionary
        };
        
        NSError *error;
        NSData *customDimensionJsonData = [NSJSONSerialization dataWithJSONObject:customDimensionServerDictionary options:0 error:&error];
        if (customDimensionJsonData) {
            NSString *customDimensionJsonString = [[NSString alloc] initWithData:customDimensionJsonData encoding:NSUTF8StringEncoding];
            
            NSCharacterSet *allowedCharacters = [NSCharacterSet URLQueryAllowedCharacterSet];
            NSString *encodedCustomDimensionString = [customDimensionJsonString stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
            NSDictionary * finalizedCustomDimensionDictionary = @{
                KeyCustomDimension : customDimensionJsonString
            };
            [VWOUserDefaults updateNonEventArchData:urlString valueDict:finalizedCustomDimensionDictionary];
        }
    }
    
    return components.URL;
}

- (NSURL *)forPushingCustomDimensionEventArch:(NSMutableDictionary<NSString *, id> *)customDimensionDictionary
                                dateTime:(nonnull NSDate *)date {
    NSURLComponents *components = [NSURLComponents vwoComponentForPath:ConstEventArchEndpoint isChinaCDN:_isChinaCDN];
    if(VWOUserDefaults.CollectionPrefix != NULL && VWOUserDefaults.CollectionPrefix.length != 0){
        NSString *path = [NSString stringWithFormat: @"%@%@", VWOUserDefaults.CollectionPrefix, ConstEventArchEndpoint];
        components = [NSURLComponents vwoComponentForPath:path isChinaCDN:_isChinaCDN];
    }
    
    unsigned long currentTimeInSec = (unsigned long)date.timeIntervalSince1970;
    unsigned long currentTimeInMilli = (unsigned long)(date.timeIntervalSince1970 * 1000);
    
    NSMutableDictionary *paramDict =
    [@{APIEventName         : PushEventName,
       AccountID            : _accountID,
       APIKey               : [NSString stringWithFormat:@"%@-%@", _appKey, _accountID],
       CurrentTimeInMillis  : [NSString stringWithFormat:@"%lu", currentTimeInMilli],
       Random               : [self randomNumber]
     } mutableCopy];
    
    components.queryItems = [paramDict toQueryItems];
    
    NSMutableDictionary *EventArchDict = @{
        D: @{
            MessageID: [NSString stringWithFormat:@"%@-%lu", VWOUserDefaults.UUID, currentTimeInMilli],
            VisitorID: VWOUserDefaults.UUID,
            SessionID: [NSNumber numberWithUnsignedLong : currentTimeInSec],
            Event: @{
                EventProps: @{
                    SDKName: SDKNameValue,
                    SDKVersion: kSDKversionNumber,
                    IsCustomEvent: @((BOOL)true),
                    InternalVisitor: @{
                        VisitorProps: customDimensionDictionary
                    }
                },
                Data360EventName: PushEventName,
                EventTime: [NSNumber numberWithUnsignedLong : currentTimeInMilli]
            },
            ExternalVisitor: @{
                VisitorProps: customDimensionDictionary
            }
        }
    };
    
    NSString *urlString = [components.URL absoluteString];
    [VWOUserDefaults updateEventArchData:urlString valueDict:EventArchDict];
    
    return components.URL;
}

@end
