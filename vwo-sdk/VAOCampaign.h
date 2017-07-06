//
//  VAOCampaign.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import <Foundation/Foundation.h>
#import "VAOGoal.h"
#import "VAOVariation.h"


@interface VAOCampaign : NSObject

@property NSString *id;
@property NSString *name;
@property NSString *status;
@property VAOVariation *variation;
@property NSArray<VAOGoal *> *goals;

@end
