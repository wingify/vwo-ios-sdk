//
//  MEGManager.m
//  VWO
//
//  Created by Harsh Raghav on 15/05/23.
//

#import <Foundation/Foundation.h>
#import "MEGManager.h"
#import "MutuallyExclusiveGroups.h"
#import "VWOLogger.h"
#import "VWOCampaign.h"
#import "Group.h"
#import "CampaignGroupMapper.h"
#import "VWOConstants.h"
#import "VWOUserDefaults.h"
#import "WinnerManager.h"
#import "Response.h"
#import "VWOController.h"
#import "VWOConstants.h"

@implementation MEGManager

- (instancetype)init{
    if (self = [super init]) {
        self.winnerManager = [[WinnerManager alloc] init];
    }
    return self;
}

- (void)iLog:(NSString *)message {
//    [MutuallyExclusiveGroups log:message];
}
- (NSString *)getCampaign:(NSString *)userId args:(NSDictionary *)args {
    
    [self iLog:@"trying to figure out MEG winner campaign."];
    
    if (userId == nil || [userId length]==0) {
        userId = [VWOController.shared getUserId];
    }
    
    NSMutableDictionary *megGroupsData = [[NSMutableDictionary alloc] init];
    if (megGroupsData == nil) return nil; // MEG data not found
    
    VWOCampaignArray * campaignsData = [VWOController.shared getCampaignData];
    if (campaignsData == nil || [campaignsData count] == 0) return nil; // MEG data not found

    if (campaignsData != nil && campaignsData.count > 0) {
        for (int i = 0; i < campaignsData.count; i++) {
            @try {
                VWOCampaign *groupDataItem = campaignsData[i];
                if ([groupDataItem type] == ConstGroups) {
                    [megGroupsData setObject:groupDataItem forKey:@"groups"];
                   break;
                }
            }
            @catch (NSException *exception)  {
                VWOLogDebug(@"MutuallyExclusive  %@", exception);
           
            }
        }
    }
    
    WinnerManager *winnerManager = [[WinnerManager alloc] init];
    Response *localResponse = [winnerManager getSavedDetailsFor:userId args:args];
    if ([localResponse shouldServePreviousWinnerCampaign]) {
        // user doesn't exist, should continue processing
        NSString *savedWinnerCampaign = [localResponse winnerCampaign];
        return savedWinnerCampaign;
    }
    
    NSDictionary<NSString *, Group*> *mappedData = [CampaignGroupMapper createAndGetGroups: megGroupsData];
    
    MutuallyExclusiveGroups *meg = [[MutuallyExclusiveGroups alloc] initMutuallyExclusiveGroups:userId];
    [meg addGroups:mappedData];
    
    NSString *winner = [meg getCampaign:args jsonData:campaignsData];
    [winnerManager save:userId winnerCampaign:winner args:args];
    return winner;
}

- (NSDictionary *)getMEGData:(NSArray *)campaignsData {
    NSMutableDictionary *megGroupsData = [[NSMutableDictionary alloc] init];
    
    // last item is always the MEG data
    NSInteger campaignDataLastIndex = campaignsData.count - 1;
    for (NSInteger i = campaignDataLastIndex; i >= 0; i--) {
        @try {
            NSDictionary *groupDataItem = campaignsData[i];
            
            if (![groupDataItem objectForKey:@"campaign_type"]) {
                return nil;
            }
            
            NSString *cType = [groupDataItem objectForKey:@"campaign_type"] ?: @"";
            if ([ConstGroups isEqualToString:cType]) {
                megGroupsData = [NSMutableDictionary dictionaryWithDictionary:groupDataItem];
                break;
            }
        }
        @catch (NSException *exception) {
//            [VWOLog eWithMessage:[NSString stringWithFormat:@"%@ %@", VWOLog.DATA_LOGS, exception.description] printLogs:YES];
        }
    }
    
    return megGroupsData;
}

@end
