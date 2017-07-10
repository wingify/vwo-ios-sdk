//
//  VAOAPIClient.h
//  VAO
//
//  Created by Wingify on 23/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//
//
//  Handler for all remote communication for VAO_RUN_MODE.
//

#import <Foundation/Foundation.h>

@interface VAOAPIClient : NSObject

+ (instancetype)sharedInstance;
- (void)schedule;
- (void)startTimer;
- (void)stopTimer;

// For App
- (void) pullABDataAsynchronously:(BOOL)isAsync
                          success:(void(^)(id))successBlock
                          failure:(void(^)(NSError *))failureBlock;

- (void)makeUserPartOfCampaign:(NSInteger)campaignID forVariation:(NSString *)variationId;

- (void) markConversionForGoalId:(NSInteger)goalId
                    experimentId:(NSInteger)experimentId
                     variationId:(NSInteger)variationId
                         revenue:(NSNumber *)revenue;

@end
