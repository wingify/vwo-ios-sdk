//
//  CampaignGroupMapper.h
//  VWO
//
//  Created by Harsh Raghav on 30/11/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CampaignGroupMapper : NSObject

+ (NSDictionary *)getCampaignGroups: (NSDictionary *)jsonObject;
+ (NSDictionary *)createAndGetGroups: (NSDictionary *)jsonObject;
@end

NS_ASSUME_NONNULL_END
