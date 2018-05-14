//
//  VWOURL.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 15/09/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VWOCampaign, VWOGoal, VWOUserDefaults;

/**
 VWOURL creates URLs required for DACDN communication
 It stores API key and account id.

 @note: Do store NSURL in variables, that are created from VWOURL methods.
 These methods always generate different URL since there is a random component to it
 */
@interface VWOURL : NSObject

+ (instancetype)urlWithAppKey:(NSString *)appKey accountID:(NSString *)accountID;

- (NSURL *)forFetchingCampaigns;

- (NSURL *)forMakingUserPartOfCampaign:(VWOCampaign *)campaign
                              date:(NSDate *)date;

- (NSURL *)forMarkingGoal:(VWOGoal *)goal
                withValue:(nullable NSNumber *)goalValue
                 campaign:(VWOCampaign *)campaign
                 date:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
