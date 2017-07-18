//
//  VAOGoogleAnalytics.h
//  VAO
//
//  Created by Swapnil on 11/06/15.
//  Copyright (c) 2015 Wingify Software Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VAOCampaign, VAOGoal;

@interface VAOGoogleAnalytics : NSObject

+ (id)sharedInstance;
- (void)markGoalConversion:(VAOGoal *)goal inCampaign:(VAOCampaign *)campaign withValue:(NSNumber *) number;
- (void)makeUserPartOfCampaign:(VAOCampaign *) campaign;

@end

NS_ASSUME_NONNULL_END
