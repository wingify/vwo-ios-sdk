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

extern NSString const *KEY_GROUP;
extern NSString const *KEY_TEST_KEY;
extern NSString const *KEY_WINNER_CAMPAIGN;
extern NSString const *KEY_USER;
extern NSString const *KEY_MAPPING;
extern NSString const *ID_GROUP;

@end

@interface VWOData360Constants : NSObject

extern NSString const *ConstGroups;

extern NSString const *UserAgentValue;
extern NSString const *EventArchEnabled;
extern NSString const *EventArchDisabled;

// MARK: - QueryParamsEventArchEnabled
extern NSString const *APIEventName;
extern NSString const *TrackUserEventName;
extern NSString const *PushEventName;
extern NSString const *AccountID;
extern NSString const *APIKey;
extern NSString const *CurrentTimeInMillis;
extern NSString const *Random;

// MARK: - Data360PayloadParams
extern NSString const *D;
extern NSString const *MessageID;// uuid-currentTimeStamp in seconds
extern NSString const *VisitorID;//uuid
extern NSString const *SessionID;//current timestamp in seconds
extern NSString const *Event;
extern NSString const *EventProps;
extern NSString const *SDKName;//name of the sdk
extern NSString const *SDKNameValue;
extern NSString const *SDKVersion;//version of the sdk
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
