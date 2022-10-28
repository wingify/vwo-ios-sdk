//
//  VWOCampaign.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import <Foundation/Foundation.h>
#import "VWOGoal.h"
#import "VWOVariation.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CampaignStatus) {
    CampaignStatusRunning,
    CampaignStatusExcluded,
    CampaignStatusPaused
};

@interface VWOCampaign : NSObject

@property (nonatomic, assign) int iD;
@property (atomic) NSString *name;
@property (atomic) NSString *testKey;
@property (nonatomic, assign) BOOL trackUserOnLaunch;
@property (nonatomic, assign) CampaignStatus status;
@property VWOVariation *variation;
@property NSArray<VWOGoal *> *goals;
@property (nullable) NSDictionary *segmentObject;

- (nullable instancetype)initWithDictionary:(NSDictionary *)campaignDict;
- (nullable id)variationForKey:(NSString *)key;
- (nullable id)testKey:(NSString *)testKey;
- (nullable VWOGoal *)goalForIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
