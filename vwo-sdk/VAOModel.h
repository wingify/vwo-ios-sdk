//
//  VAOModel.h
//  VAO
//
//  Created by Wingify on 26/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//
//
//  Model (of MVC fame) for the whole SDK. This manages all data persistence.
//

#import <Foundation/Foundation.h>
#import "VAOCampaign.h"

@interface VAOModel : NSObject

@property (atomic) NSMutableArray<VAOCampaign *> *campaignList;

+ (instancetype)sharedInstance;
- (void)updateCampaignList:(NSArray *)allCampaignDict;
- (NSArray *)loadMessages;
- (void)saveCampaignInfo:(NSDictionary *)campaignInfo;
- (NSMutableDictionary*)getCampaignInfo;
- (void)saveMessages:(NSArray *)messages;
- (BOOL)hasBeenPartOfExperiment:(NSString*)experimentId;
- (void)checkAndMakePartOfExperiment:(NSString*)experimentId variationId:(NSString*)variationId;
- (BOOL)shouldTriggerGoal:(NSString*)goalId forExperiment:(NSString*)experimentId;
- (NSMutableDictionary*)getCurrentExperimentsVariationPairs;
@end
