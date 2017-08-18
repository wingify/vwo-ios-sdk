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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CampaignStatus) {
    CampaignStatusRunning,
    CampaignStatusExcluded
};

@interface VAOCampaign : NSObject<NSCoding>

@property (nonatomic, assign) int iD;
@property (atomic) NSString *name;
@property (nonatomic, assign) BOOL trackUserOnLaunch;
@property (nonatomic, assign) CampaignStatus campaignStatus;
@property VAOVariation *variation;
@property NSArray<VAOGoal *> *goals;
@property (nullable) NSDictionary *segmentObject;

- (nullable instancetype)initWithDictionary:(NSDictionary *) campaignDict;
- (nullable id)variationForKey:(NSString*)key;
- (nullable VAOGoal *)goalForIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
