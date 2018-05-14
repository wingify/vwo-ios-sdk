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

@interface VWOCampaign : NSObject

@property (nonatomic, assign) int iD;
@property (atomic) NSString *name;
@property (nonatomic, assign) int trafficPercent;
@property (nonatomic, assign) BOOL trackUserOnLaunch;
@property (readonly) VWOVariation *variation;
@property NSArray<VWOGoal *> *goals;
@property (nullable) NSDictionary *segmentObject;

- (nullable instancetype)initWithDictionary:(NSDictionary *)campaignDict;
- (nullable VWOGoal *)goalForIdentifier:(NSString *)identifier;
- (nullable VWOVariation *)variationForID:(nullable NSNumber *)variationID;
@end

NS_ASSUME_NONNULL_END
