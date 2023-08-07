//
//  VWOConstants.m
//  VWO
//
//  Created by Harsh Raghav on 04/04/23.
//

#import <Foundation/Foundation.h>
#import <VWOConstants.h>

@implementation VWOConstants: NSObject

NSString const *ConstGroups = @"groups";

NSString const *ConstCampaignGroups = @"campaignGroups";

NSString const *ConstType = @"type";

NSString const *ConstCampaigns = @"campaigns";

NSString const *ConstCollectionPrefix = @"collectionPrefix";

NSString const *ConstIsEventArchEnabled = @"isEventArchEnabled";

NSString const *ConstIsMobile360Enabled = @"isMobile360Enabled";

NSString const *ConstRevenueTracking = @"REVENUE_TRACKING";

NSString *ConstNotAvailable = @"NA";

NSString *ConstKeyBundleAppVersion = @"CFBundleShortVersionString";

//for making API calls
NSString const *ConstAPIVersion = @"3";

//for MEG
NSString const *KEY_GROUP = @"group";
NSString const *KEY_TEST_KEY = @"test_key";
NSString const *KEY_WINNER_CAMPAIGN = @"winner_campaign";
NSString const *KEY_USER = @"user";
NSString const *KEY_MAPPING = @"mapping";
NSString const *ID_GROUP = @"groupId";

@end

@implementation VWONetworkCallConstants: NSObject

NSString *ConstNetworkScheme = @"http";

NSString *ConstBaseURL = @"dacdn.visualwebsiteoptimizer.com";

NSString *ConstChinaCDNBaseURL = @"cdn-cn.vwo-analytics.com";

//endpoints
NSString const *ConstFetchingCampaignsEndpoint       = @"/mobile";
NSString const *ConstTrackUserEndpoint               = @"/track-user";
NSString const *ConstTrackGoalEndpoint               = @"/track-goal";
NSString const *ConstPushingCustomDimensionEndpoint  = @"/mobile-app/push";
NSString const *ConstEventArchEndpoint               = @"/events/t";

//extra data constants
NSString const *KeyTimeStampExtraData           = @"lt";
NSString const *KeySDKVersionNumberExtraData    = @"v";
NSString const *KeyAppKeyExtraData              = @"i";
NSString const *KeyAppVersionExtraData          = @"av";
NSString const *KeyDeviceNameExtraData          = @"dt";
NSString const *KeyIOSVersionExtraData          = @"os";

//common network constants
NSString const *KeyExperimentID     = @"experiment_id";
NSString const *KeyAccountID        = @"account_id";
NSString const *KeyCombination      = @"combination";
NSString const *KeyUUID             = @"u";
NSString const *KeySessionCount     = @"s";
NSString const *KeyRandom           = @"random";
NSString const *KeyTimeStamp        = @"sId";
NSString const *KeyExtraData        = @"ed";
NSString const *KeyCustomDimension  = @"tags";
NSString const *KeyGoalID           = @"goal_id";
NSString const *KeyGoalRevenue      = @"r";
NSString const *KeyU                = @"u";

//fetching campaign specific keywords
NSString const *KeyAPIVersionFetchingCampaign               = @"api-version";
NSString const *KeyAccountIDFetchingCampaign                = @"a";
NSString const *KeyDeviceNameFetchingCampaign               = @"dt";
NSString const *KeyAppKeyFetchingCampaign                   = @"i";
NSString const *KeyCampaignVariationPairsFetchingCampaign   = @"k";
NSString const *KeyIOSVersionFetchingCampaign               = @"os";
NSString const *KeyRandomNumberFetchingCampaign             = @"r";
NSString const *KeyUUIDFetchingCampaign                     = @"u";
NSString const *KeySDKversionNumberFetchingCampaign         = @"v";
NSString const *keyUHashFetchingCampaign                    = @"uHash";
@end

@implementation VWOData360Constants: NSObject

//for enabling EventArch
NSString *ConstEventArchEnabled = @"eventArchEnabled";

//for disabling EventArch
NSString *ConstEventArchDisabled = @"eventArchDisabled";

NSString *ConstUserAgentValue = @"iOSVwoAb";

//query params
NSString const *APIEventName = @"en";// value changes based on the current API call
NSString const *TrackUserEventName = @"vwo_variationShown";
NSString const *PushEventName = @"vwo_syncVisitorProp";
NSString const *AccountID = @"a";
NSString const *APIKey = @"env";
NSString const *CurrentTimeInMillis = @"eTime";
NSString const *Random = @"random";

//payloads params
NSString const *D = @"d";
NSString const *MessageID = @"msgId";// uuid-currentTimeStamp in seconds
NSString const *VisitorID = @"visId";//uuid
NSString const *SessionID = @"sessionId";//current timestamp in seconds
NSString const *Event = @"event";
NSString const *EventProps = @"props";
NSString const *SDKName = @"sdkName";//name of the sdk
NSString const *SDKNameValue = @"vwo-ios-sdk";
NSString const *SDKVersion = @"sdkVersion";//version of the sdk
NSString const *CampaignID = @"id";//id of the campaign
NSString const *VariationID = @"variation";//id of the variation
NSString const *IsFirst = @"isFirst";//this will be sent as 1 always
NSString const *IsCustomEvent = @"isCustomEvent";//this will always be sent as true
NSString const *VWOMeta = @"vwoMeta";
NSString const *Metric = @"metric";
NSString const *InternalVisitor = @"$visitor";
NSString const *ExternalVisitor = @"visitor";
NSString const *VisitorProps = @"props";
NSString const *Data360EventName = @"name";//event name
NSString const *EventTime = @"time";//current timestamp in milliseconds
@end
