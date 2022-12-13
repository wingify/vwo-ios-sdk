//
//  VWOGroup.m
//  VWO
//
//  Created by Harsh Raghav on 07/12/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import "VWOGroup.h"
@implementation VWOGroup
static NSString * kGroups = @"groups";
static NSString * kCampaignGroups = @"campaignGroups";

- (instancetype)initWithDictionary:(NSDictionary *)groupDict {
  NSParameterAssert(groupDict);
 // NSArray *missingKeys = [goalDict keysMissingFrom:@[kId, kIdentifier]];
//  if (missingKeys.count > 0) {
//    VWOLogException(@"Keys missing [%@] for Goal JSON {%@}", [missingKeys componentsJoinedByString:@", "], goalDict);
//    return nil;
//  }
  self.campaignGroups = groupDict[kCampaignGroups] ;
    self.groups = groupDict[kGroups] ;
    return self;
}

@end
