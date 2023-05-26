//
//  MutuallyExclusiveGroups.h
//  VWO
//
//  Created by Harsh Raghav on 30/11/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PriorityQualificationWinnerResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface MutuallyExclusiveGroups : NSObject {
    
}

- (id)initMutuallyExclusiveGroups:(NSString *)userId;
- (void)addGroups:(NSDictionary *)groupHashMap;
- (NSString *)getCampaign: (NSDictionary *)args jsonData: (NSArray *)campaignsData;
- (NSString *)calculateTheWinnerCampaign: (NSDictionary *)args jsonData: (NSArray *)campaignsData;
- (NSString *)getCampaignIdFromTestKey: (NSString *)testKey campaignsData: (NSArray *)campaignsData;
- (NSString *)getTestKeyFromCampaignId: (NSString *)campaignId campaignsData: (NSArray *)campaignsData;
- (NSString *)getCampaignFromSpecificGroup: (NSString *)groupName;
- (NSString *)getGroupNameFromGroupId: (int)groupId;
- (PriorityQualificationWinnerResult *)isQualifiedAsWinner:(NSString *)priorityCampaignId isGroupPassedByUser:(BOOL)isGroupPassedByUser;
- (NSString *)getCampaignFromCampaignId: (NSString *)userId campaign: (NSString *)campaign;
- (NSString *)getCampaignIfPresent: (NSString *)campaignKey;
- (NSNumber *)getNormalizedValue: (NSNumber *)murmurHash;
- (NSNumber *)getMurMurHash: (NSString *)userId;
+ (void)log: (NSString *)message;

@end

NS_ASSUME_NONNULL_END
