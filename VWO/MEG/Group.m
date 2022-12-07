//
//  Group.m
//  VWO
//
//  Created by Harsh Raghav on 30/11/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import "Group.h"
#import "CampaignUniquenessTracker.h"
#import "MutuallyExclusiveGroups.h"

@implementation Group
static int ID = INT_MIN;
/**

 * Name of the group

 */

NSString *name = nil;
/**

 * The list of campaigns assigned for this group.

 */

NSMutableArray<NSString *> *campaignList;
/**

 * A simple key value based mechanism to check where our weight belongs to.

 */

NSMutableDictionary<NSString *, id> *weightMap = nil;
NSNumber *weight;

- (int)getId {

    return ID;

}

- (NSString *) getName {

    return name;

}

- (void) setName: (NSString *) Name {

    name = Name;

}

- (void) setId: (int) Id {

    ID = Id;

}

+ (NSUInteger) getCampaignSize {

    if(campaignList == nil){

        campaignList = [NSMutableArray new];

    }

    return campaignList.count;

}

+ (NSMutableArray<NSString *> *) getCampaigns {

    if(campaignList == nil){

        campaignList = [NSMutableArray new];

    }

    return campaignList;

}



- (void) calculateWeight {

    float total = 100; // because 100%

    NSUInteger totalCampaigns = campaignList.count;

    weight = @(total/totalCampaigns);

}



- (void) addCampaign: (NSString *) campaign {
    CampaignUniquenessTracker *campaignUniquenessTracker = [[CampaignUniquenessTracker alloc] init];
      if([campaignUniquenessTracker groupContainsCampaign:campaign]) {
          [MutuallyExclusiveGroups log: [NSString stringWithFormat:@"%s/%@/%s/%@/%s/%@/%s", "addCampaign: could not add campaign [ ", campaign, " ] to group [ ", [self getName]," ] because it already belongs to group [ ", [campaignUniquenessTracker getNameOfGroupFor:campaign]," ]"]];

        return;

    }

    [campaignUniquenessTracker addCampaignAsRegistered:campaign  group:[self getName]];

    if(campaignList == nil){

        campaignList = [NSMutableArray new];

    }

    [campaignList addObject:campaign];

    [self calculateWeight];

}

- (void) removeCampaign: (NSString *) campaign{

    NSMutableArray<NSString *> *campaigns = [NSMutableArray new];

    if (campaignList == nil) return;

    if (campaignList.count== 0) return;

    for (int i = 0; i < campaignList.count; i++) {

        NSString *value = campaignList[i];

        if (value == campaign) continue;

        [campaigns addObject:value];

    }

    [campaignList removeAllObjects];

    [campaignList addObjectsFromArray:(campaigns)];

    [self calculateWeight];

}

+ (NSNumber *) getWeight {
    return weight;
}

- (NSString *) getOnlyIfPresent: (NSString *) toSearch{
    if (campaignList == nil) return nil;

    if (campaignList.count== 0) return nil;

    for (NSString *campaignId in campaignList) {

        if (toSearch == campaignId) return [NSString stringWithFormat:@"%d",ID];

    }

    return nil;

}



- (NSString *) getNameOnlyIfPresent: (NSString *) toSearch{

    if (campaignList == nil) return nil;

    

    if (campaignList.count== 0) return nil;

    for (NSString *campaignId in campaignList) {

        if (toSearch == campaignId) return name;

    }

    return nil;

}



- (NSString *) getCampaignForRespectiveWeight: (NSNumber *) weight{

    [self createWeightMap];

    NSArray *allKeys = [weightMap allKeys];

    for(NSString *key in allKeys) {

        NSMutableArray<NSNumber *> *weightMaxMin = weightMap[key];

        if (weightMaxMin == nil) continue;

        BOOL weightIsGreaterThanMin = (weight > weightMaxMin[0]);

        BOOL weightIsLessThanMax = (weight <= weightMaxMin[1]);

        if(weightIsGreaterThanMin && weightIsLessThanMax) {

            [MutuallyExclusiveGroups log:[NSString stringWithFormat:@"%s/%@/%s/%@/%s/%@/%s", "campaign [ " ,key ," ] found for the given weight [ " ,weight ," ] in group [ " ,[self getNameOnlyIfPresent: key] ," ]"]];

            return key;

        }

    }

    return nil;

}



- (void) createWeightMap {

    if (weightMap == nil) {

        weightMap = [NSMutableDictionary new];

    }

    

    NSNumber *weightBinValue = 0;

    

    // A 0 - 33.33 , B 33.33 - 66.33 , C 66.333, 100.0

    for (int i = 0; i < campaignList.count; i++) {

        NSMutableArray<NSNumber *> *range = [NSMutableArray new];

        [range addObject:weightBinValue];

        weightBinValue = @(weightBinValue.intValue + weight.intValue);

        [range addObject:weightBinValue];

        [weightMap setObject: range forKey: campaignList[i]];

    }

}



@end
