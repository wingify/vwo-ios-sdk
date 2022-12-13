//
//  MutuallyExclusiveGroups.m
//  VWO
//
//  Created by Harsh Raghav on 30/11/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import "MutuallyExclusiveGroups.h"
#import "MurmurHash.h"
#import "VWOCampaign.h"
#include <math.h>
#import "Group.h"
#import "VWOLogger.h"

@implementation MutuallyExclusiveGroups

static const BOOL IS_LOGS_SHOWN = true;

static const NSString *TYPE_VISUAL_AB = @"VISUAL_AB";

static const NSString *ID_GROUP = @"groupId";

static const NSString *ID_CAMPAIGN = @"campaignKey";

static NSString * const CAMPAIGN_TEST_KEY = @"test_key";

static NSString * const CAMPAIGN_TYPE = @"type";

static NSString * const CAMPAIGN_ID = @"id";

static const NSString *TAG = @"MutuallyExclusiveGroups";

static NSString *userId;

NSMutableDictionary<NSString *, Group *> *CAMPAIGN_GROUPS;

NSMutableDictionary<NSString *, NSString *> *USER_CAMPAIGN;

- (id)initMutuallyExclusiveGroups:(NSString *)UserId

{
    self = [super init];

    if (self) {
        userId = UserId;
    }

    return self;
}

- (void)addGroups:(NSDictionary *)groupHashMap{

    if (CAMPAIGN_GROUPS == nil) {
        CAMPAIGN_GROUPS = [NSMutableDictionary new];
    }

    [CAMPAIGN_GROUPS removeAllObjects];
    [CAMPAIGN_GROUPS addEntriesFromDictionary:groupHashMap];
}

- (NSString *)getCampaign: (NSDictionary *)args jsonData: (NSArray *)campaignsData{
    return [self calculateTheWinnerCampaign:args jsonData: campaignsData];
}

- (NSString *)calculateTheWinnerCampaign: (NSDictionary *)args jsonData: (NSArray *)campaignsData{
    if (args == nil) {
        return nil;
    }

    NSString  *groupId = args[ID_GROUP];
    
    NSString *testKey = args[CAMPAIGN_TEST_KEY];
    
    NSString *campaignId = [self getCampaignIdFromTestKey: testKey campaignsData : campaignsData];

    if(groupId == nil && campaignId == nil) {
        
        // there must be at least one type of id
        // either GROUP or CAMPAIGN
        VWOLogDebug(@"MutuallyExclusive The groupId and campaignId both are null");

        return nil;
    }

    NSString *campaign;

    NSString *TestKey;

    NSString *groupName;

    BOOL groupIdIsNotPresentInArgs = (groupId == nil || groupId.length == 0);

    if(groupIdIsNotPresentInArgs) {
        VWOLogDebug(@"MutuallyExclusive The groupId was not found in the mapping so just picking the specific campaign [ %@ ]",campaignId);


       // if there is no sign of group we can simply use the campaign matching logic

              campaign = [self getCampaignFromCampaignId: userId campaign: campaignId];
        
        VWOLogDebug(@"MutuallyExclusive Campaign selected from the mutually exclusive group is [ %@ ]",campaign);


        TestKey = [self getTestKeyFromCampaignId: campaign campaignsData:campaignsData];
        VWOLogDebug(@"MutuallyExclusive Test-key of the campaign selected from the mutually exclusive group is [ %@ ]",TestKey);
        

        return TestKey;

    }
    VWOLogDebug(@"MutuallyExclusive Because there was groupId present, we are going to prioritize it and get a campaign from that group");

    @try{

        groupName = [self getGroupNameFromGroupId: groupId.intValue];

    }

    @catch(NSException *exception) {
        VWOLogDebug(@"MutuallyExclusive %@",exception);

        return nil;

    }

    

    campaign = [self getCampaignFromSpecificGroup:groupName];
    VWOLogDebug(@"MutuallyExclusive Selected campaign from [ %@ ] is [ %@ ]",groupName,campaign);

    TestKey = [self getTestKeyFromCampaignId:campaign campaignsData:campaignsData];
    VWOLogDebug(@"MutuallyExclusive Test-key of the campaign selected from the mutually exclusive group is [ %@ ]",TestKey);

    return TestKey;

}



- (NSString *)getCampaignIdFromTestKey: (NSString *)testKey campaignsData: (NSArray *)campaignsData{

    

    if (campaignsData == nil) return nil;

    

    if (campaignsData.count== 0) return nil;

    

    for (int i = 0; i < campaignsData.count; i++) {

        @try {

            NSDictionary *groupDataItem = campaignsData[i];
            VWOCampaign *groupData = groupDataItem; //[groupDataItem objectForKey:CAMPAIGN_TYPE] ;
            
            if([[groupData type] isEqual:TYPE_VISUAL_AB]){
                if([[groupData  testKey] isEqual: testKey]){
                    return  [NSString stringWithFormat:@"%d",[groupData iD]];
                }
            }


        }

        @catch(NSException *exception) {
            VWOLogDebug(@"MutuallyExclusive  %@ ",exception);

        }

    }

    return nil;

}



- (NSString *)getTestKeyFromCampaignId: (NSString *)campaignId campaignsData: (NSArray *)campaignsData{

    

    if (campaignsData == nil) return nil;

    

    if (campaignsData.count== 0) return nil;

    

    for (int i = 0; i < campaignsData.count; i++) {

        @try {
            NSDictionary *groupDataItem = campaignsData[i];
            VWOCampaign *groupData = groupDataItem;
            
            if([[groupData type] isEqual:TYPE_VISUAL_AB]){
                if([[NSString stringWithFormat:@"%d",[groupData iD]] isEqual: [NSString stringWithFormat:@"%@",campaignId]]){
                    return  [groupData testKey];
                }
            }
        

        }

        @catch(NSException *exception) {
            VWOLogDebug(@"MutuallyExclusive  %@ ",exception);
            

        }

        

    }

    return nil;

}



- (NSString *)getCampaignFromSpecificGroup: (NSString *)groupName{

    

    if (groupName == nil) {

        // this should never happen unless the id of the group that doesn't exist is passed

        return nil;

    }

    

    NSNumber *murmurHash = [self getMurMurHash:userId];
    
    NSLog(@"Murmur hash value %@",murmurHash);

    // If the campaign-user mapping is present in the App storage, get the decision from there. Otherwise, go to the next step

    NSString *murmurHashString = [NSString stringWithFormat: @"%@", murmurHash];

    if ([USER_CAMPAIGN objectForKey: murmurHashString]) return USER_CAMPAIGN[murmurHashString];

    NSNumber *normalizedValue = [self getNormalizedValue:murmurHash];

    VWOLogDebug(@"MutuallyExclusive  Normalized value for user with userID -> %@ is  ",userId,normalizedValue);

     Group *interestedGroup = CAMPAIGN_GROUPS[groupName];

      if (interestedGroup == nil) return nil;

     return [interestedGroup getCampaignForRespectiveWeight:normalizedValue];

}

-(NSString *)getGroupNameFromGroupId: (int)groupId{
    
    NSArray *allKeys = [CAMPAIGN_GROUPS allKeys];
    
    for(NSString *key in allKeys){
        Group *group = CAMPAIGN_GROUPS[key];
        
        if(group == nil)return nil;
        if(groupId == group.Id){
            return key;
        }
    }
    return nil;
}

- (NSString *)getCampaignFromCampaignId: (NSString *)userId campaign: (NSString *)campaign{

    NSString *campaignFoundInGroup = [self getCampaignIfPresent:campaign];

    if (campaignFoundInGroup == nil) {
        VWOLogDebug(@"MutuallyExclusive  The campaign key [ %@ ] is not present in any of the mutually exclusive groups ",campaign);

        return campaign;

    }

    else {
        
        VWOLogDebug(@"MutuallyExclusive  Found campaign [ %@ ] in mutually exclusive group [ %@ ] ",campaign,campaignFoundInGroup);

    }

    // Generate a random number/murmurhash corresponding to the User ID

    NSNumber *murmurHash = [self getMurMurHash:userId];

    // If the campaign-user mapping is present in the App storage, get the decision from there. Otherwise, go to the next step
    VWOLogDebug(@"MutuallyExclusive  Murmur hash for [%@] -> [%@]",userId,murmurHash);
    NSString *murmurHashString = [NSString stringWithFormat: @"%@", murmurHash];

    if ([USER_CAMPAIGN objectForKey: murmurHashString]) return USER_CAMPAIGN[murmurHashString];

    NSNumber *normalizedValue = [self getNormalizedValue:murmurHash];
    
    VWOLogDebug(@"MutuallyExclusive  Normalized value for user with userID [%@] -> [%@]",userId,normalizedValue);

    Group *interestedGroup = CAMPAIGN_GROUPS[campaignFoundInGroup];

    
    if (interestedGroup == nil)

        return nil; // basic null check because NSDictionary is being used

    

    NSString *finalCampaign = [interestedGroup getCampaignForRespectiveWeight: normalizedValue];

    
    if([campaign isEqual:[NSString stringWithFormat:@"%@",finalCampaign]]){
        VWOLogDebug(@"MutuallyExclusive  Campaign [%@] found for given weight [%@]",finalCampaign,normalizedValue);
        return finalCampaign;

    }

    else {
        VWOLogDebug(@"MutuallyExclusive  Passed campaign : [%@] does not match calculated campaign [%@]",campaign,finalCampaign);

    }


    return nil;

}



- (NSString *)getCampaignIfPresent: (NSString *)campaignKey{

    NSArray *allKeys = [CAMPAIGN_GROUPS allKeys];

    for (NSString *key in allKeys) {

        Group *group = CAMPAIGN_GROUPS[key];

        if (group == nil) return nil;

        NSString *foundCampaign = [group getOnlyIfPresent:campaignKey];

        if (foundCampaign != nil) {

            // we should return name of the group

            // the reason being we need to use the weightage of the campaigns later on

            return key;

        }

    }

    return nil;

}



- (NSNumber *)getNormalizedValue: (NSNumber *)murmurHash{

    int max = 100;

    double ratio = murmurHash.intValue /  pow(2,31);

    double multipliedValue = (max * ratio) + 1;

    int value = abs((int) floor(multipliedValue));

    return [NSNumber numberWithInt:value];

}



- (NSNumber *)getMurMurHash: (NSString *)userId{
    int hash = abs([MurmurHash hash32:userId]);

    return [NSNumber numberWithInt:hash];

}



+ (void)log: (NSString *)message{

    if (IS_LOGS_SHOWN) {

        NSLog(TAG, message);

    }

}


@end
