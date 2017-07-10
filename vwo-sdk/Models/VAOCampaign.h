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

typedef NS_ENUM(NSInteger, CampaignStatus) {
    CampaignStatusRunning,
    CampaignStatusExcluded
};
NS_ASSUME_NONNULL_BEGIN
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
- (nullable VAOGoal *)goalForidentifier:(NSString *)identifier;
@end
NS_ASSUME_NONNULL_END