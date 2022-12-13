//
//  Group.h
//  VWO
//
//  Created by Harsh Raghav on 30/11/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Group : NSObject


@property(nonatomic,assign)int Id;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSMutableArray<NSString *> *campaignList;
@property(nonatomic,strong)NSMutableDictionary<NSString *, id> *weightMap;
@property(nonatomic,strong)NSNumber *weight;

- (NSString *) getCampaignForRespectiveWeight: (NSNumber *) weight;
- (NSMutableArray<NSString *> *) getCampaigns;
- (NSString *) getNameOnlyIfPresent: (NSString *) toSearch;
- (NSString *) getOnlyIfPresent: (NSString *) toSearch;
- (void) addCampaign: (NSString *) campaign;
@end

NS_ASSUME_NONNULL_END
