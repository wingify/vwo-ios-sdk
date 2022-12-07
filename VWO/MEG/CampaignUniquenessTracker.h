//
//  CampaignUniquenessTracker.h
//  VWO
//
//  Created by Harsh Raghav on 30/11/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CampaignUniquenessTracker : NSObject {
    
}

- (BOOL)groupContainsCampaign:(NSString *) campaign;
- (NSString *)getNameOfGroupFor:(NSString *) campaign;
- (void)addCampaignAsRegistered:(NSString *) campaign group:(NSString *) group;
@end

NS_ASSUME_NONNULL_END
