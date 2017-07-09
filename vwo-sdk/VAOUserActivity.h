//
//  VAOUserActivity.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 09/07/17.
//
//

#import <Foundation/Foundation.h>
#import "VAOCampaign.h"

@interface VAOUserActivity : NSObject

+ (void)trackUserForCampaign:(VAOCampaign *)campaign;
+ (void)markGoalConversion:(VAOGoal *)goal forCampaign:(VAOCampaign *)campaign;
+ (void)log;

@end
