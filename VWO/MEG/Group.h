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

- (instancetype)init;
- (NSMutableArray<NSString *> *)getPriorityCampaigns;
- (void)addPriority:(NSString *)p;
- (int)getEt;
- (void)addEt:(int)et;
- (NSUInteger) getCampaignSize;
- (NSString *)getPriorityCampaign;
- (BOOL)isNotAdvanceMEGAllocation;
- (void)createWeightMap;
- (void)createWeightMapFromProvidedValues;
- (void) createEquallyDistributedWeightMap;
- (void)addWeight:(NSString *)campaign weight:(NSInteger)weight;
- (NSString *) getCampaignForRespectiveWeight: (NSNumber *) weight;
- (NSMutableArray<NSString *> *) getCampaigns;
- (NSString *) getNameOnlyIfPresent: (NSString *) toSearch;
- (NSString *) getOnlyIfPresent: (NSString *) toSearch;
- (void) addCampaign: (NSString *) campaign;
- (BOOL)hasInPriority:(NSString *)campaign;
- (BOOL)doesNotHaveInPriority:(NSString *)campaign;
@end

NS_ASSUME_NONNULL_END
