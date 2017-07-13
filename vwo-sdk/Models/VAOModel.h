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
- (void)trackUserForCampaign:(VAOCampaign *)campaign;
- (void)markGoalConversion:(VAOGoal *)goal inCampaign:(VAOCampaign *)campaign withValue:(NSNumber *) number;
- (void)updateCampaignListFromDictionary:(NSArray *)allCampaignDict;
- (NSArray *)loadMessagesFromFile;

- (NSMutableDictionary*)getCampaignInfo;
- (void)saveMessages:(NSArray *)messages;

@end
