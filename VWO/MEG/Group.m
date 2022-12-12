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

- (NSUInteger) getCampaignSize {

    if(_campaignList == nil){

        self.campaignList = [NSMutableArray new];

    }

    return self.campaignList.count;

}

- (NSMutableArray<NSString *> *) getCampaigns {

    if(self.campaignList == nil){

        self.campaignList = [NSMutableArray new];

    }

    return self.campaignList;

}

- (void) calculateWeight {

    float total = 100; // because 100%

    NSUInteger totalCampaigns = self.campaignList.count;

    self.weight = @(total/totalCampaigns);

}



- (void) addCampaign: (NSString *) campaign {
    CampaignUniquenessTracker *campaignUniquenessTracker = [[CampaignUniquenessTracker alloc] init];
      if([campaignUniquenessTracker groupContainsCampaign:campaign]) {
          [MutuallyExclusiveGroups log: [NSString stringWithFormat:@"%s/%@/%s/%@/%s/%@/%s", "addCampaign: could not add campaign [ ", campaign, " ] to group [ ", self.name," ] because it already belongs to group [ ", [campaignUniquenessTracker getNameOfGroupFor:campaign]," ]"]];

        return;

    }

    [campaignUniquenessTracker addCampaignAsRegistered:campaign  group:self.name];

    if(_campaignList == nil){

        _campaignList = [NSMutableArray new];

    }

    [self.campaignList addObject:campaign];

    [self calculateWeight];

}

- (void) removeCampaign: (NSString *) campaign{

    NSMutableArray<NSString *> *campaigns = [NSMutableArray new];

    if (self.campaignList == nil) return;

    if (_campaignList.count== 0) return;

    for (int i = 0; i < _campaignList.count; i++) {

        NSString *value = _campaignList[i];

        if (value == campaign) continue;

        [campaigns addObject:value];

    }

    [_campaignList removeAllObjects];

    [_campaignList addObjectsFromArray:(campaigns)];

    [self calculateWeight];

}

- (NSNumber *) getWeight {
    return _weight;
}

- (NSString *) getOnlyIfPresent: (NSString *) toSearch{
    if (_campaignList == nil) return nil;

    if (_campaignList.count== 0) return nil;

    for (NSString *campaignId in _campaignList) {

        if([toSearch isEqual:[NSString stringWithFormat:@"%@",campaignId]]){
            return [NSString stringWithFormat:@"%d",_Id];
        }

    }

    return nil;

}



- (NSString *) getNameOnlyIfPresent: (NSString *) toSearch{

    if (_campaignList == nil) return nil;

    

    if (_campaignList.count== 0) return nil;

    for (NSString *campaignId in _campaignList) {

        if (toSearch == campaignId) return _name;

    }

    return nil;

}



- (NSString *) getCampaignForRespectiveWeight: (NSNumber *) weight{

    [self createWeightMap];

    NSArray *allKeys = [_weightMap allKeys];

    for(NSString *key in allKeys) {

        NSMutableArray<NSNumber *> *weightMaxMin = _weightMap[key];

        if (weightMaxMin == nil) continue;
        
        BOOL weightIsGreaterThanMin = false;
        int maxWeight = [weightMaxMin[0] intValue];
        if ([weight intValue] > maxWeight){
            weightIsGreaterThanMin = true;
        }
        
        BOOL weightIsLessThanMax = false;
        
        if ([weight intValue] <= [weightMaxMin[1] intValue]){
            weightIsLessThanMax = true;
        }

        if(weightIsGreaterThanMin && weightIsLessThanMax) {

            [MutuallyExclusiveGroups log:[NSString stringWithFormat:@"%s/%@/%s/%@/%s/%@/%s", "campaign [ " ,key ," ] found for the given weight [ " ,weight ," ] in group [ " ,[self getNameOnlyIfPresent: key] ," ]"]];

            return key;

        }

    }

    return nil;

}



- (void) createWeightMap {

    if (_weightMap == nil) {

        _weightMap = [NSMutableDictionary new];

    }

    

    NSNumber *weightBinValue = [NSNumber numberWithInt:0];

    

    // A 0 - 33.33 , B 33.33 - 66.33 , C 66.333, 100.0

    for (int i = 0; i < _campaignList.count; i++) {

        NSMutableArray<NSNumber *> *range = [NSMutableArray new];

        [range addObject:weightBinValue];

        weightBinValue = @(weightBinValue.intValue + _weight.intValue);

        [range addObject:weightBinValue];

        [_weightMap setObject: range forKey: _campaignList[i]];

    }

}



@end
