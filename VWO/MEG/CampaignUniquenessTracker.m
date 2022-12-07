//
//  CampaignUniquenessTracker.m
//  VWO
//
//  Created by Harsh Raghav on 30/11/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import "CampaignUniquenessTracker.h"

@implementation CampaignUniquenessTracker

-(id) init
{
    self = [super init];
    if(self)
    {
       //do something
    }
    return self;
}

static NSMutableDictionary<NSString *, NSString *> * CAMPAIGNS;

- (BOOL)groupContainsCampaign:(NSString *) campaign{
    
    if (CAMPAIGNS == nil) {
        CAMPAIGNS = [NSMutableDictionary new];
    }
    return (CAMPAIGNS[campaign] != nil);
}

- (NSString *)getNameOfGroupFor:(NSString *) campaign{
    if (CAMPAIGNS == nil) {
        CAMPAIGNS = [NSMutableDictionary new];
    }
    return CAMPAIGNS[campaign];
}
- (void)addCampaignAsRegistered:(NSString *) campaign group:(NSString *) group
{
    if (CAMPAIGNS == nil) {
        CAMPAIGNS = [NSMutableDictionary new];
    }
    [CAMPAIGNS setObject:campaign forKey:group];
}

@end
