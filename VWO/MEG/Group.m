//
//  Group.m
//  VWO
//
//  Created by Harsh Raghav on 30/11/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import "Group.h"
#import "Weight.h"
#import "CampaignUniquenessTracker.h"
#import "MutuallyExclusiveGroups.h"

@interface Group ()

// Private instance variable
@property (nonatomic, strong) NSMutableArray<NSString *> *priorityCampaigns;

/**
* Type of allocation:
* 1 - Random
* 2 - Advance
* <p>
* DOC: https://confluence.wingify.com/pages/viewpage.action?spaceKey=VWOENG&title=Mutually+Exclusive+Weights+and+Prioritization+in+Mobile+App+Testing
*/
@property (nonatomic,assign) int et;

// Using NSMutableArray to maintain the insertion order
@property (nonatomic, strong) NSMutableArray<Weight *> *weightMapFromServer;

@end

@implementation Group

const int VALUE_ET_INVALID = -1;
const int VALUE_ET_RANDOM = 1;
const int VALUE_ET_ADVANCE = 2;
NSString *VALUE_INVALID_PRIORITY_CAMPAIGN = @"InvalidCampaign";

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Initialize private properties
        _priorityCampaigns = [[NSMutableArray<NSString *> alloc] init];
        _et= VALUE_ET_INVALID;
        _weightMapFromServer = [[NSMutableArray<Weight *> alloc] init];
    }
    return self;
}

- (NSMutableArray<NSString *> *)getPriorityCampaigns {
    return _priorityCampaigns;
}

- (void)addPriority:(NSString *)p {
    [_priorityCampaigns addObject:p];
}

- (int)getEt {
    return _et;
}

- (void)addEt:(int)et {
    _et = et;
}

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

- (NSString *)getPriorityCampaign {
    [MutuallyExclusiveGroups log:[NSString stringWithFormat:@"will try to check for priority campaign against campaign list in group -> %@", self.name]];

    // check if et is advance as priority is not
    if ([self isNotAdvanceMEGAllocation]) {
    [MutuallyExclusiveGroups log:[NSString stringWithFormat:@"et ( %d ) is not advance type, priority campaigns ( p ) will not be applicable.", self.et]];
    return VALUE_INVALID_PRIORITY_CAMPAIGN;
    }

    if (self.priorityCampaigns.count == 0) {
    [MutuallyExclusiveGroups log:@"et is advance but the priority array is empty."];
    return VALUE_INVALID_PRIORITY_CAMPAIGN;
    }

    [MutuallyExclusiveGroups log:[NSString stringWithFormat:@"there are %lu priorityCampaigns in %@", (unsigned long)self.priorityCampaigns.count, self.name]];

    for (NSString *priorityCampaign in self.priorityCampaigns) {
    if ([self.campaignList containsObject:priorityCampaign]) {
    [MutuallyExclusiveGroups log:[NSString stringWithFormat:@"priority campaign >> %@ << found in -> %@", priorityCampaign, self.name]];
    return priorityCampaign;
    } else {
    [MutuallyExclusiveGroups log:[NSString stringWithFormat:@"priority campaign >> %@ << doesn't exist in %@", priorityCampaign, self.name]];
    }
    }

    [MutuallyExclusiveGroups log:@"priority campaign not defined, caller should continue with normal MEG logic."];

    // we found nothing
    return VALUE_INVALID_PRIORITY_CAMPAIGN;
    }

- (BOOL)isNotAdvanceMEGAllocation {
    return (_et != VALUE_ET_ADVANCE);
}

- (void) calculateWeight {

    float total = 100;

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



- (void)createWeightMap {
    if ([self isNotAdvanceMEGAllocation]) {
        [MutuallyExclusiveGroups log:[NSString stringWithFormat:@"not using weight from the server, preparing EQUAL allocation because et = %d [ NOTE: et=1->Random, et=2 -> Advance ]", self.et]];
        
        [self createEquallyDistributedWeightMap];
    } else {
        [MutuallyExclusiveGroups log:@"weight is received from the server, preparing WEIGHTED allocation."];
        [self createWeightMapFromProvidedValues];
    }
}

- (void)createWeightMapFromProvidedValues {
    if (self.weightMap == nil) {
        self.weightMap = [[NSMutableDictionary alloc] init];
    }
    
    [MutuallyExclusiveGroups log:@"morphing weighted allocation data to existing MEG weight format"];
    for (int index = 0; index < [self.weightMapFromServer count]; index++) {
        Weight *weight = self.weightMapFromServer[index];
        [self.weightMap setObject:weight.getRange forKey:weight.getCampaign];
    }
}


- (void) createEquallyDistributedWeightMap {

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


- (void)addWeight:(NSString *)campaign weight:(NSInteger)weight {

    NSLog(@"adding priority weight -> %ld for campaign -> %@", (long)weight, campaign);

    NSMutableArray<NSNumber *> *weightRange = [NSMutableArray new];
    if (self.weightMapFromServer.count == 0) {
        [weightRange addObject:@(0)]; // will start at 0
        [weightRange addObject:@(weight)]; // end
    } else {
        // last weight's end will be this weight's start
        Weight *lastWeight = self.weightMapFromServer.lastObject;
        // add range
        [weightRange addObject: ([lastWeight getRangeEnd])]; // start will be the end of last entry
        NSInteger endWeight = [[lastWeight getRangeEnd] intValue] + weight;
        [weightRange addObject: [NSNumber numberWithInteger:endWeight]]; // end will be start + current weight
    }

    Weight *weightObject = [[Weight alloc] init:campaign range:weightRange];
    [self.weightMapFromServer addObject:weightObject];
    NSLog(@"campaign %@ range %@ to %@", [weightObject getCampaign], [weightObject getRangeStart], [weightObject getRangeEnd]);
}

- (BOOL)hasInPriority:(NSString *)campaign {
    for(int i=0;i<_priorityCampaigns.count;i++){
        NSString *priorityItem = [NSString stringWithFormat:@"%@", _priorityCampaigns[i]];
        if([priorityItem isEqual:campaign]){
            return TRUE;
        }
    }
    return FALSE;
}

- (BOOL)doesNotHaveInPriority:(NSString *)campaign {
    return ![self hasInPriority:campaign];
}

@end
