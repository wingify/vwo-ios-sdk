//
//  CampaignGroupMapper.m
//  VWO
//
//  Created by Harsh Raghav on 30/11/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import "CampaignGroupMapper.h"
#import "VWOLogger.h"
#import "VWOCampaign.h"
#import "Group.h"

@implementation CampaignGroupMapper

static NSString * const KEY_CAMPAIGN_GROUPS = @"campaignGroups";
static NSString * const KEY_GROUPS = @"groups";
static NSString * const KEY_NAME = @"name";
static NSString * const KEY_CAMPAIGNS = @"campaigns";
static NSString * const KEY_PRIORITY = @"p";
static NSString * const KEY_ET = @"et";
static NSString * const KEY_WEIGHT = @"wt";

float m = 1.0;

//months,

+ (NSDictionary *)getCampaignGroups: (NSDictionary *)jsonObject{
    
    NSDictionary* jsonCampaignGroups = nil;
    @try {
        jsonCampaignGroups = jsonObject[KEY_CAMPAIGN_GROUPS];
    }
    @catch (NSException *exception) {
        VWOLogDebug(@"MutuallyExclusive  %@", exception);
        
    }
    return jsonCampaignGroups;
}


+ (NSDictionary *)createAndGetGroups: (NSDictionary *)jsonObject{
    NSMutableDictionary<NSString*, Group*> *groups = [NSMutableDictionary new];
    @try{
        NSDictionary *jsonGroups = [self getGroups:jsonObject];
        
        if(jsonGroups == nil) return groups;
        
        NSArray<NSString*> *itrJsonGroups = [jsonGroups allKeys];
        int index=0;
        while (index < itrJsonGroups.count) {
            NSString *key = itrJsonGroups[index];
            
            NSDictionary *objGroup = jsonGroups[key];
            
            NSString *groupName = objGroup[KEY_NAME];
            
            Group *group = [[Group alloc]init];
            group.name = groupName;
            group.Id = key.intValue;
            
            [self prepareWeight:objGroup destination:group];
            [self prepareCampaigns:objGroup destination:group];
            [self prepareEt:objGroup destination:group];
            [self preparePriority:objGroup destination:group];
            
            VWOLogDebug(@"MutuallyExclusive  Added Group Id %d", group.Id);
            VWOLogDebug(@"MutuallyExclusive  Added Group Campaign %@", group.getCampaigns);

            [groups setObject:group forKey:groupName];
            index++;
        }
    }
    
    @catch (NSException *exception) {
        VWOLogDebug(@"MutuallyExclusive  error while adding groups %@", exception);
    }
    return groups;
}

+ (void)preparePriority: (NSDictionary *)source destination:(Group *)destination {
    if (![source objectForKey:KEY_PRIORITY]) return;

    NSArray *priority = [source objectForKey:KEY_PRIORITY];
    NSLog(@"priority should be given to these campaigns -> %@", priority);
    for (int pIndex = 0; pIndex < priority.count; ++pIndex) {
        [destination addPriority:[priority objectAtIndex:pIndex]];
    }
}

+ (void)prepareEt:(NSDictionary *)source destination:(Group *)destination {
    if (![source objectForKey:KEY_ET]) return;

    int et = [[source objectForKey:KEY_ET] intValue];
    [destination addEt:et];
}

+ (void)prepareCampaigns:(NSDictionary *)source destination:(Group *)destination {
    if (![source objectForKey:KEY_CAMPAIGNS]) return;

    NSArray *arrCampaigns = [source objectForKey:KEY_CAMPAIGNS];
    for (int index = 0; index < arrCampaigns.count; index++) {
        [destination addCampaign:[arrCampaigns objectAtIndex:index]];
    }
}

+ (void)prepareWeight:(NSDictionary *)source destination:(Group *)destination {
    if (![source objectForKey:KEY_WEIGHT]) return;

    NSLog(@"------------------------------------------------------------");
    NSLog(@"preparing for -> %@", destination.name);
    NSLog(@"found weight sent from server, preparing the weight value for later usage.");
    NSLog(@"NOTE: these weight will only be applied if no priority campaign exist.");

    NSDictionary *weights = [source objectForKey:KEY_WEIGHT];
    NSEnumerator *enumerator = [weights keyEnumerator];
    NSString *campaign;
    while ((campaign = [enumerator nextObject])) {
        NSNumber *weightNumber = [weights objectForKey:campaign];
        int weight = [weightNumber intValue];
        [destination addWeight:campaign weight:weight];
    }

    NSLog(@"------------------------------------------------------------");
}

+ (NSDictionary *)getGroups: (NSDictionary *)jsonObject{
    NSDictionary *jsonGroups = nil;
    
    @try {
        VWOCampaign *groupDict = [jsonObject objectForKey:KEY_GROUPS] ;
        jsonGroups =  groupDict.group.groups;  
    }
    @catch (NSException *exception) {
        VWOLogDebug(@"MutuallyExclusive  %@", exception);
    }
    return jsonGroups;
}

@end
