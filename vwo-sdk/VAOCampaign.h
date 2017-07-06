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

typedef enum {
    CampaignStatusRunning,
    CampaignStatusExcluded
} CampaignStatus;

@interface VAOCampaign : NSObject

@property(nonatomic, assign) int id;
@property(nonatomic, assign) BOOL trackUserOnLaunch;
@property(atomic) NSString *name;
@property (nonatomic, assign) CampaignStatus status;
@property VAOVariation *variation;
@property NSMutableArray<VAOGoal *> *goals;

- (instancetype)initWithDictionary:(NSDictionary *) campaignDict;

@end
