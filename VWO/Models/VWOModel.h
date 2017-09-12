//
//  VWOModel.h
//  VWO
//
//  Created by Wingify on 26/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//
//
//  Model (of MVC fame) for the whole SDK. This manages all data persistence.
//

#import <Foundation/Foundation.h>

@class VWOCampaign, VWOGoal;

NS_ASSUME_NONNULL_BEGIN

@interface VWOModel : NSObject

@property (atomic) NSMutableArray<VWOCampaign *> *campaignList;
@property NSMutableDictionary<NSString *, NSString *> *customVariables;

+ (instancetype)sharedInstance;
- (void)trackUserForCampaign:(VWOCampaign *)campaign;
- (void)markGoalConversion:(VWOGoal *)goal inCampaign:(VWOCampaign *)campaign withValue:(NSNumber *)number;
- (void)updateCampaignListFromDictionary:(NSArray *)allCampaignDict;
- (void)saveMessages:(NSArray *)messages;

@end
NS_ASSUME_NONNULL_END
