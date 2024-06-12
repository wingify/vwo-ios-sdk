//
//  VWOConstants.h
//  VWO
//
//  Created by Harsh Raghav on 04/04/23.
//

#import <Foundation/Foundation.h>

@interface VWOConstants : NSObject

extern NSString const *ConstGroups;
extern NSString const *ConstCampaignGroups;
extern NSString const *ConstType;
extern NSString const *ConstCampaigns;
extern NSString const *ConstCollectionPrefix;
extern NSString const *ConstIsEventArchEnabled;
extern NSString const *ConstIsMobile360Enabled;
extern NSString const *ConstAPIVersion;
extern NSString const *ConstRevenueTracking;
extern NSString *ConstNotAvailable;
extern NSString *ConstKeyBundleAppVersion;

extern NSString const *KEY_GROUP;
extern NSString const *KEY_TEST_KEY;
extern NSString const *KEY_WINNER_CAMPAIGN;
extern NSString const *KEY_USER;
extern NSString const *KEY_MAPPING;
extern NSString const *ID_GROUP;

@end

@interface VWONetworkCallConstants : NSObject

extern NSString *ConstNetworkScheme;
extern NSString *ConstBaseURL;
extern NSString *ConstChinaCDNBaseURL;

//endpoints
extern NSString *ConstFetchingCampaignsEndpoint;
extern NSString *ConstTrackUserEndpoint;
extern NSString *ConstTrackGoalEndpoint;
extern NSString *ConstPushingCustomDimensionEndpoint;
extern NSString *ConstEventArchEndpoint;

//extra data constants
extern NSString const *KeyTimeStampExtraData;
extern NSString const *KeySDKVersionNumberExtraData;
extern NSString const *KeyAppKeyExtraData;
extern NSString const *KeyAppVersionExtraData;
extern NSString const *KeyDeviceNameExtraData;
extern NSString const *KeyIOSVersionExtraData;

//common network constants
extern NSString const *KeyExperimentID;
extern NSString const *KeyApplicationVersion;
extern NSString const *KeyAccountID;
extern NSString const *KeyCombination;
extern NSString const *KeyUUID;
extern NSString const *KeySessionCount;
extern NSString const *KeyRandom;
extern NSString const *KeyTimeStamp;
extern NSString const *KeyExtraData;
extern NSString const *KeyCustomDimension;
extern NSString const *KeyGoalID;
extern NSString const *KeyGoalRevenue;
extern NSString const *KeyU;

//fetching campaign specific keywords
extern NSString const *KeyAPIVersionFetchingCampaign;
extern NSString const *KeyAccountIDFetchingCampaign;
extern NSString const *KeyDeviceNameFetchingCampaign;
extern NSString const *KeyAppKeyFetchingCampaign;
extern NSString const *KeyCampaignVariationPairsFetchingCampaign;
extern NSString const *KeyIOSVersionFetchingCampaign;
extern NSString const *KeyRandomNumberFetchingCampaign;
extern NSString const *KeyUUIDFetchingCampaign;
extern NSString const *KeySDKversionNumberFetchingCampaign;
extern NSString const *keyUHashFetchingCampaign;
@end

@interface VWOData360Constants : NSObject

extern NSString const *ConstGroups;

extern NSString *ConstUserAgentValue;
extern NSString *ConstEventArchEnabled;
extern NSString *ConstEventArchDisabled;

// MARK: - QueryParamsEventArchEnabled
extern NSString const *APIEventName;
extern NSString const *VWO_ApplicationVersion;
extern NSString const *TrackUserEventName;
extern NSString const *PushEventName;
extern NSString const *VWO_AccountID;
extern NSString const *VWO_APIKey;
extern NSString const *CurrentTimeInMillis;
extern NSString const *Random;

// MARK: - Data360PayloadParams
extern NSString const *D;
extern NSString const *VWO_MessageID;// uuid-currentTimeStamp in seconds
extern NSString const *VisitorID;//uuid
extern NSString const *VWO_SessionID;//current timestamp in seconds
extern NSString const *Event;
extern NSString const *EventProps;
extern NSString const *VWO_SDKName;//name of the sdk
extern NSString const *VWO_SDKNameValue;
extern NSString const *VWO_SDKVersion;//version of the sdk
extern NSString const *CampaignID;//id of the campaign
extern NSString const *VariationID;//id of the variation
extern NSString const *IsFirst;//this will be sent as 1 always
extern NSString const *IsCustomEvent;//this will always be sent as true
extern NSString const *VWOMeta;
extern NSString const *Metric;
extern NSString const *InternalVisitor;
extern NSString const *ExternalVisitor;
extern NSString const *VisitorProps;
extern NSString const *Data360EventName;//event name
extern NSString const *EventTime;//current timestamp in milliseconds
@end
