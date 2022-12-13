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
            NSArray *arrCampaigns = objGroup[KEY_CAMPAIGNS];
            
            NSString *groupName = objGroup[KEY_NAME];
            
            Group *group = [[Group alloc]init];
            group.name = groupName;
            group.Id = key.intValue;
            
            for (int i = 0; i < arrCampaigns.count; i++) {
                [group addCampaign:arrCampaigns[i]];
            }
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
