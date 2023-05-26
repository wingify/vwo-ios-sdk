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
#import "PriorityQualificationWinnerResult.h"
#import "VWOSegmentEvaluator.h"
#import "VWOController.h"

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

    
    
    VWOCampaignArray * campaignsArray = [VWOController.shared getCampaignData];
    if(campaignsArray.count==0) return nil;
    
    for (int i = 0; i < campaignsArray.count; i++) {

        VWOCampaign *groupData = campaignsArray[i];
        NSLog(@"Testing MEG Priority groupCamp%@",groupData);
//        VWOCampaign *groupData = [[VWOCampaign alloc] initWithDictionary:groupDataItem];
        
        @try {

            
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

    
    VWOCampaignArray * campaignsArray = [VWOController.shared getCampaignData];
    if(campaignsArray.count==0) return nil;
    
    for (int i = 0; i < campaignsArray.count; i++) {

        @try {
            VWOCampaign *groupData = campaignsArray[i];
//            VWOCampaign *groupData = [[VWOCampaign alloc] initWithDictionary:groupDataItem];
            
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

    VWOLogDebug(@"MutuallyExclusive  Normalized value for user with userID -> %@ is  %@",userId,normalizedValue);

     Group *interestedGroup = CAMPAIGN_GROUPS[groupName];

      if (interestedGroup == nil) return nil;
    
    // evaluate all the priority campaigns
        NSLog(@"----------- { BEGIN } Priority Campaign Evaluation -----------");
        NSArray<NSString *> *priorityCampaignsInGroup = [interestedGroup getPriorityCampaigns];
        if (priorityCampaignsInGroup.count == 0) {
            NSLog(@"> there are 0 priority campaigns");
        }
        for (int i = 0; i < priorityCampaignsInGroup.count; i++) {
            NSString *priorityCampaign = priorityCampaignsInGroup[i];
            NSLog(@"now evaluating priority campaign ( p ) @ index %d -> %@", i, priorityCampaign);
            PriorityQualificationWinnerResult *result = [self isQualifiedAsWinner:priorityCampaign isGroupPassedByUser:YES];
            if ([result isQualified]) {
                NSLog(@"found a winner campaign from the priority campaign list -> %@", priorityCampaign);
                return priorityCampaign;
            }
        }
        NSLog(@"----------- { END } Priority Campaign Evaluation -----------");

        NSLog(@"none of the priority campaigns are qualified as winners, next will try to check for weighted campaign.");
    return [interestedGroup getCampaignForRespectiveWeight:normalizedValue];
}

- (PriorityQualificationWinnerResult *)isQualifiedAsWinner:(NSString *)priorityCampaignId isGroupPassedByUser:(BOOL)isGroupPassedByUser {
    
    BOOL priorityIsNull = ([priorityCampaignId isEqual: @""]);
    if (priorityIsNull) {
        VWOLogDebug(@"the passed priority campaign id is null, will not qualify.");
        
        PriorityQualificationWinnerResult *result = [[PriorityQualificationWinnerResult alloc] init];
        result.qualified = NO;
        result.groupInPriority = isGroupPassedByUser;
        result.priorityCampaignFound = NO;
        return result;
    }
    
    @try {
        
        VWOCampaignArray * vwoData = [VWOController.shared getCampaignData];
        if (vwoData == nil || [vwoData count] == 0){
            VWOLogDebug(@"INCONSISTENT STATE detected, local data for VWO is not present.");
            
            PriorityQualificationWinnerResult *result = [[PriorityQualificationWinnerResult alloc] init];
            result.qualified = NO;
            result.groupInPriority = isGroupPassedByUser;
            result.priorityCampaignFound = NO;
            return result;
            
        }
        
        VWOLogDebug(@"> evaluating each campaign from campaign list to check if they are qualified");
        BOOL isPriorityCampaignFoundLocally = NO;
        for (int i = 0; i < vwoData.count; i++) {
            VWOCampaign *campaign = vwoData[i];
            
            BOOL isPriorityCampaignValid = [self isPriorityValid:campaign priorityCampaignId:priorityCampaignId];
            
            if (!isGroupPassedByUser && !isPriorityCampaignValid) {
                // skip
                VWOLogDebug(@"will not evaluate -> %d as it is redundant to do so", [campaign iD]);
                continue;
            }
            
            if (isPriorityCampaignValid) {
                // avoid assigning false once it is true because we want to know that
                // if campaignId and priorityCampaignId matched at some point
                isPriorityCampaignFoundLocally = YES;
            }
            
            if ([self isSegmentationValid:campaign] && [self isVariationValid:campaign] && isPriorityCampaignValid) {
                
                PriorityQualificationWinnerResult *result = [[PriorityQualificationWinnerResult alloc] init];
                result.qualified = YES;
                result.groupInPriority = isGroupPassedByUser;
                result.priorityCampaignFound = YES;
                return result;
            }
            
            // at this point the campaign did not qualify so if no group was passed then we can stop this loop
            // this optimizes our runtime cost as { null } will be returned after loop cases are exhausted
//            if (!isGroupPassedByUser) {
//                break;
//            }
//
//            PriorityQualificationWinnerResult *result = [[PriorityQualificationWinnerResult alloc] init];
//            result.qualified = NO;
//            result.groupInPriority = isGroupPassedByUser;
//            result.priorityCampaignFound = isPriorityCampaignFoundLocally;
//            return result;
        }
    }
    @catch (NSException *exception)  {
        PriorityQualificationWinnerResult *result = [[PriorityQualificationWinnerResult alloc] init];
        result.qualified = NO;
        result.groupInPriority = isGroupPassedByUser;
        result.priorityCampaignFound = NO;
        return result;
    }
    PriorityQualificationWinnerResult *result = [[PriorityQualificationWinnerResult alloc] init];
    result.qualified = NO;
    result.groupInPriority = isGroupPassedByUser;
    result.priorityCampaignFound = NO;
    return result;
}

- (BOOL) isVariationValid:(VWOCampaign *)campaign {
    BOOL isVariationNotNull = [campaign variation] != nil;
    BOOL isVariationValid = (isVariationNotNull && [[campaign variation] iD] > 0);
    if (isVariationValid) {
        VWOLogDebug(@"VALID | variation id -> %ld", [[campaign variation] iD]);
    } else {
        if (isVariationNotNull) {
            VWOLogDebug(@"INVALID | variation id -> %ld", [[campaign variation] iD]);
        }
    }
    return isVariationValid;
}

- (BOOL) isSegmentationValid:(VWOCampaign *)campaign {
    if([campaign segmentObject] == nil){
        VWOLogDebug(@"VALID | segmentation checks");
        return TRUE;
    }
    
    BOOL isSegmentationValid = TRUE;
    VWOSegmentEvaluator *segmentEvaluator = [VWOSegmentEvaluator makeEvaluator:[VWOController.shared customVariables]];
        
    NSArray *partialSegment = (NSArray *)[campaign segmentObject][@"partialSegments"];
    VWOSegment *segmentObject = [[VWOSegment alloc] initWithDictionary:partialSegment[0]];
    
    if(segmentObject){
        isSegmentationValid = [segmentEvaluator evaluate:segmentObject];
    }
    else{
        VWOLogDebug(@"INVALID | segmentation segmentObject not created");
        return FALSE;
    }
    
    if (isSegmentationValid) {
        VWOLogDebug(@"VALID | segmentation checks");
    } else {
        VWOLogDebug(@"INVALID | segmentation checks");
        return FALSE;
    }
    return isSegmentationValid;
}

- (BOOL)isPriorityValid:(VWOCampaign *)campaign priorityCampaignId:(NSString *)priorityCampaignId {
    NSLog(@"Testing MEG Priority %d %lld",[campaign iD],[priorityCampaignId longLongValue]);
    BOOL isSameAsPriority = ([campaign iD] == [priorityCampaignId intValue]);
    return isSameAsPriority;
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

    
    if (interestedGroup == nil) return nil; // basic null check because NSDictionary is being used

    // check if this campaign is in priority list
    // if not found there's no point in evaluating the list
    if ([interestedGroup hasInPriority:campaign]) {

        VWOLogDebug(@"%@ found in priority campaign list.", campaign);

        // evaluate priority campaigns
        // here the campaign is the priorityCampaign because we are targeting the specific campaign
        PriorityQualificationWinnerResult *result = [self isQualifiedAsWinner:campaign isGroupPassedByUser:NO];
        if ([result isQualified]) {
            VWOLogDebug(@"winner campaign found from the priority campaign list -> %@", campaign);
            return campaign;
        }

        // check if we found the related campaign and still unqualified
        if ([result isPriorityCampaignFound] && [result isNotQualified]) {
            VWOLogDebug(@"priority campaign was found but was not qualified for winning, will simply return { null } from this point.");
            return nil;
        }
    } else {
        VWOLogDebug(@"priority campaigns does not have campaign -> %@, skipping redundant checks for optimization.", campaign);
    }

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

//        NSLog(TAG, message);

    }

}


@end
