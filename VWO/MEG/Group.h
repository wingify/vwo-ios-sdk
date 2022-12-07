//
//  Group.h
//  VWO
//
//  Created by Harsh Raghav on 30/11/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Group : NSObject

- (NSString *) getCampaignForRespectiveWeight: (NSNumber *) weight;
- (int) getId;

- (NSString *) getNameOnlyIfPresent: (NSString *) toSearch;
- (NSString *) getOnlyIfPresent: (NSString *) toSearch;
- (void) addCampaign: (NSString *) campaign;
- (void) setName: (NSString *) Name;
- (void) setId: (int) Id;
@end

NS_ASSUME_NONNULL_END
